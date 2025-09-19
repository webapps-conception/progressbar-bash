#!/usr/bin/env bash
set -euo pipefail

echo "✅ Test sans verbose"
./progressbar.sh > /dev/null

echo "✅ Test avec verbose"
./progressbar.sh --verbose > /dev/null

echo "Tous les tests sont passés ✅"
