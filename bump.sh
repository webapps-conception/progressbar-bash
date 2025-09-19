#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 [patch|minor|major] [--dry-run|--no-git|--interactive]"
  exit 1
}

RELEASE_TYPE="${1:-}"
OPTION="${2:-}"

if [[ "$RELEASE_TYPE" == "--interactive" ]]; then
  echo "Choisir le type de release :"
  echo "  1) patch"
  echo "  2) minor"
  echo "  3) major"
  read -rp "> " choice
  case "$choice" in
    1) RELEASE_TYPE="patch" ;;
    2) RELEASE_TYPE="minor" ;;
    3) RELEASE_TYPE="major" ;;
    *) echo "❌ Choix invalide"; exit 1 ;;
  esac
  OPTION="${2:-}"
fi

if [[ -z "$RELEASE_TYPE" ]]; then
  RELEASE_TYPE="patch"
  echo "ℹ️ Aucun type fourni → bump par défaut en patch"
fi

LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
VERSION="${LAST_TAG#v}"

IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION"

case "$RELEASE_TYPE" in
  major)
    MAJOR=$((MAJOR+1)); MINOR=0; PATCH=0 ;;
  minor)
    MINOR=$((MINOR+1)); PATCH=0 ;;
  patch)
    PATCH=$((PATCH+1)) ;;
  *)
    usage ;;
esac

NEW_VERSION="v$MAJOR.$MINOR.$PATCH"
DATE=$(date +'%Y-%m-%d')

echo "➡️ Dernière version : $LAST_TAG"
echo "➡️ Nouvelle version : $NEW_VERSION"

if [[ "$OPTION" == "--dry-run" ]]; then
  echo "🔎 Mode simulation activé, aucun fichier ne sera modifié."
  exit 0
fi

if [[ -f CHANGELOG.md ]]; then
  sed -i "0,/## \[Unreleased\]/s//## [Unreleased]\n\n## [${NEW_VERSION#v}] - $DATE/" CHANGELOG.md
else
  echo "# Changelog" > CHANGELOG.md
  echo -e "## [Unreleased]\n\n## [${NEW_VERSION#v}] - $DATE\n- 🚀 Première release" >> CHANGELOG.md
fi

if [[ -f README.md ]]; then
  sed -i "s/v[0-9]\+\.[0-9]\+\.[0-9]\+/$NEW_VERSION/g" README.md || true
fi

if [[ "$OPTION" == "--no-git" ]]; then
  echo "✏️ Fichiers mis à jour mais aucun commit/tag n'a été créé (--no-git)."
  exit 0
fi

git add CHANGELOG.md README.md || true
git commit -m "🔖 Bump version to $NEW_VERSION"
git tag -a "$NEW_VERSION" -m "Release $NEW_VERSION"

echo "✅ Version mise à jour localement : $NEW_VERSION"
echo "👉 N'oublie pas de pousser :"
echo "   git push origin main --tags"
