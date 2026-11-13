#!/usr/bin/env bash
# учебный прототип анализатора паролей

# ==============================================================================
# ЭТАП 1 (01.11 – 15.11)
# Базовый анализ (длина, типы символов, простые последовательности).
# скрипт выдаёт оценку стойкости и рекомендации.
# ==============================================================================

analyze_strength() {
  local pwd="$1"
  local length="${#pwd}"
  local has_upper=0 has_lower=0 has_digit=0 has_special=0 seq_found=0

  # Проверка наличия символов
  [[ "$pwd" =~ [A-Z] ]] && has_upper=1
  [[ "$pwd" =~ [a-z] ]] && has_lower=1
  [[ "$pwd" =~ [0-9] ]] && has_digit=1
  [[ "$pwd" =~ [^a-zA-Z0-9] ]] && has_special=1

  # Поиск простых последовательностей
  if echo "$pwd" | grep -qiE '123|abc|qwerty|password'; then
    seq_found=1
  fi

  # Подсчёт баллов (простая эвристика)
  local score=0
  if (( length >= 8 ));  then (( score += 2 )) || true; fi
  if (( length >= 12 )); then (( score += 2 )) || true; fi
  (( score += has_upper + has_lower + has_digit + has_special )) || true
  if (( seq_found == 1 )); then (( score -= 2 )) || true; fi

  if (( score <= 3 )); then
    echo "СЛАБЫЙ"
  elif (( score <= 5 )); then
    echo "СРЕДНИЙ"
  else
    echo "СИЛЬНЫЙ"
  fi

  # Рекомендации
  echo "--- Рекомендации ---"
  if (( length < 8 )); then
    echo "- Увеличьте длину пароля: сейчас $length символов, минимум — 8, лучше — 12."
  elif (( length < 12 )); then
    echo "- Пароль можно сделать длиннее: сейчас $length символов, рекомендуемая длина — 12 и более."
  fi
  if (( has_upper == 0 )); then
    echo "- Добавьте заглавные буквы (A-Z)."
  fi
  if (( has_lower == 0 )); then
    echo "- Добавьте строчные буквы (a-z)."
  fi
  if (( has_digit == 0 )); then
    echo "- Добавьте цифры (0-9)."
  fi
  if (( has_special == 0 )); then
    echo "- Добавьте специальные символы (!, @, # и т.п.)."
  fi
  if (( seq_found == 1 )); then
    echo "- Уберите простые последовательности (123, abc, qwerty и т.п.) — их первыми пробуют злоумышленники."
  fi
}

# ===========================================================================

usage() {
  cat <<EOF
Usage: $0 <password>

Пример: $0 "Cat123!"
EOF
  exit 1
}

if [[ $# -ne 1 ]]; then
  usage
fi

PASSWORD="$1"
STRENGTH="$(analyze_strength "$PASSWORD")"

echo "=== Анализ пароля (MiniPass CLI, этап 1) ==="
echo "Исходный пароль: $PASSWORD"
echo "Стойкость: $STRENGTH"
echo ""
