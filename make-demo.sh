#!/usr/bin/env bash
set -euo pipefail

echo "⚠️ Cette démo suppose que ttyrec/ttygif ou asciinema est installé."
echo "Enregistrement de la démo..."

asciinema rec -y demo.cast -c "./progressbar.sh --verbose"
asciinema play demo.cast
