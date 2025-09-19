#!/usr/bin/env bash
set -euo pipefail

# ⚠️ Personnalise ton dépôt ici :
GITHUB_USER="ton-user"
REPO_NAME="ton-repo"

# Initialisation du dépôt
echo "📂 Initialisation du dépôt Git..."
git init
git checkout -b main

# Ajouter tous les fichiers
echo "➕ Ajout des fichiers..."
git add .

# Commit initial
echo "💾 Commit initial..."
git commit -m '✨ Initial commit avec v0.1.0'

# Ajouter remote
echo "🔗 Ajout du remote..."
git remote add origin git@github.com:${GITHUB_USER}/${REPO_NAME}.git

# Tag v0.1.0
echo "🏷️ Création du tag v0.1.0..."
git tag -a v0.1.0 -m "Release v0.1.0"

# Push
echo "⬆️ Push vers GitHub..."
git push -u origin main --tags

echo "✅ Dépôt initialisé et release v0.1.0 poussée sur GitHub !"

