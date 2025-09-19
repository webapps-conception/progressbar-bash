#!/bin/bash
# Script de tests pour progressbar.sh (auto-nettoyant avec option --keep + tests d'erreurs)

set -euo pipefail

# Détection automatique du chemin absolu du script progressbar.sh
PROGRESS="$(realpath ./progressbar.sh)"

WORKDIR="progressbar_test"
KEEP=0

# Vérifie si --keep est passé en argument
if [[ "${1:-}" == "--keep" ]]; then
    KEEP=1
    shift
fi

mkdir -p "$WORKDIR"
cd "$WORKDIR"

cleanup() {
    if [[ $KEEP -eq 0 ]]; then
        echo
        echo "=== Nettoyage ==="
        cd ..
        rm -rf "$WORKDIR"
        echo "✅ Répertoire de test supprimé."
    else
        echo
        echo "=== Nettoyage désactivé (--keep) ==="
        echo "Les fichiers restent dans : $WORKDIR"
        echo
        echo "📊 Résumé du contenu extrait :"
        echo " - Nombre de fichiers : $(find extracted -type f | wc -l)"
        echo " - Taille totale      : $(du -sh extracted | cut -f1)"
        echo
        echo "👉 Tu peux explorer les fichiers avec :"
        echo "   cd $WORKDIR && ls -lh extracted"
    fi
}
trap cleanup EXIT

echo "=== Génération données de test ==="
mkdir -p testdir
dd if=/dev/zero of=testdir/file1 bs=1M count=10 status=none
dd if=/dev/zero of=testdir/file2 bs=1M count=20 status=none
dd if=/dev/zero of=testfile bs=1M count=5 status=none

echo
echo "=== Test 1 : barre simulée ==="
"$PROGRESS" 20 30 0.05

echo
echo "=== Test 2 : commande avec spinner ==="
"$PROGRESS" -- sleep 2

echo
echo "=== Test 3 : copie simple avec pv ==="
"$PROGRESS" --pv testfile /dev/null

echo
echo "=== Test 4 : archivage avec pv (.tar, verbose) ==="
"$PROGRESS" --pv-archive testdir archive.tar --verbose

echo
echo "=== Test 5 : extraction avec pv (verbose) ==="
mkdir -p extracted
"$PROGRESS" --pv-extract archive.tar extracted --verbose

echo
echo "=== Test 6 : archivage compressé (.tar.gz, non-verbose) ==="
"$PROGRESS" --pv-archive testdir archive.tar.gz

echo
echo "=== Test 7 : extraction compressée (.tar.gz, verbose) ==="
rm -rf extracted
mkdir -p extracted
"$PROGRESS" --pv-extract archive.tar.gz extracted --verbose

echo
echo "=== Vérification contenu ==="
ls -lh extracted

echo
echo "=== Test 8 (erreur attendue) : dossier inexistant ==="
if "$PROGRESS" --pv-archive dossier_inexistant bad.tar 2>/dev/null; then
    echo "❌ ERREUR : l’archivage aurait dû échouer !"
else
    echo "✅ OK : erreur correctement détectée (dossier inexistant)"
fi

echo
echo "=== Test 9 (erreur attendue) : archive inexistante ==="
if "$PROGRESS" --pv-extract fichier_inexistant.tar /tmp/extract 2>/dev/null; then
    echo "❌ ERREUR : l’extraction aurait dû échouer !"
else
    echo "✅ OK : erreur correctement détectée (archive inexistante)"
fi

echo
echo "=== Test 10 (erreur attendue) : mauvais suffixe de fichier ==="
if "$PROGRESS" --pv-archive testdir archive.badext 2>/dev/null; then
    echo "❌ ERREUR : l’archivage aurait dû échouer !"
else
    echo "✅ OK : erreur correctement détectée (extension invalide)"
fi

echo
echo "✅ Tous les tests se sont terminés avec succès."

