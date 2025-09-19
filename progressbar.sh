#!/usr/bin/env bash
VERBOSE=false
for arg in "$@"; do
  if [[ "$arg" == "--verbose" ]]; then
    VERBOSE=true
  fi
done

for i in $(seq 1 100); do
  if $VERBOSE; then
    echo "Étape $i/100 terminée"
  fi
  bar=$(printf "%-${i}s" "#" | cut -c1-40)
  percent=$((i))
  printf "\r[%-40s] %d%%" "$bar" "$percent"
  sleep 0.05
done
echo " ✔"
