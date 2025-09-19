# 📊 Progressbar.sh  

Un script Bash permettant d’afficher une **barre de progression** ou un **spinner** lors de l’exécution de commandes, copies, archivages et extractions.  

## 🚀 Installation  

```bash
git clone <repo-url>
cd <repo>
chmod +x progressbar.sh test_progressbar.sh
```

## 🛠 Utilisation  

### 1. Barre de progression simulée  
```bash
./progressbar.sh <steps> <width> <delay>
```

Exemple :  
```bash
./progressbar.sh 20 30 0.05
```

➡️ Affiche une barre de progression sur 30 caractères, en 20 étapes, avec 0.05s de délai entre chaque étape.  

---

### 2. Suivi d’une commande avec spinner  
```bash
./progressbar.sh -- <commande>
```

Exemple :  
```bash
./progressbar.sh -- sleep 5
```

➡️ Affiche un spinner pendant 5 secondes.  

---

### 3. Suivi de transfert avec `pv`  
```bash
./progressbar.sh --pv source dest
```

Exemple :  
```bash
./progressbar.sh --pv fichier.iso /dev/null
```

➡️ Affiche une barre pendant la copie de `fichier.iso`.  

---

### 4. Archivage avec barre de progression  
```bash
./progressbar.sh --pv-archive <dossier> <archive.tar[.gz]> [--verbose]
```

Exemples :  
```bash
./progressbar.sh --pv-archive dossier archive.tar
./progressbar.sh --pv-archive dossier archive.tar.gz --verbose
```

---

### 5. Extraction avec barre de progression  
```bash
./progressbar.sh --pv-extract <archive.tar[.gz]> <dossier> [--verbose]
```

Exemple :  
```bash
./progressbar.sh --pv-extract archive.tar.gz extrait --verbose
```

---

## 🔍 Mode Verbose  

- L’option `--verbose` peut être placée **n’importe où** dans les arguments.  
- Les logs défilent **au-dessus de la barre de progression**.  

---

## 🧪 Script de tests  

Un script dédié (`test_progressbar.sh`) permet de valider toutes les fonctionnalités.  

### Exécution normale (auto-nettoyant)  
```bash
./test_progressbar.sh
```

➡️ Lance les tests dans un dossier temporaire `progressbar_test/` qui sera supprimé automatiquement.  

### Exécution avec conservation des fichiers  
```bash
./test_progressbar.sh --keep
```

➡️ Les fichiers de test sont conservés, avec un résumé final :  
- Nombre de fichiers  
- Taille totale du dossier extrait  

---

## ✅ Tests inclus  

- Barre simulée  
- Spinner sur commande  
- Copie avec `pv`  
- Archivage/extraction (`.tar`, `.tar.gz`)  
- Gestion du mode `--verbose`  
- Vérification des erreurs :  
  - Dossier inexistant  
  - Archive inexistante  
  - Mauvaise extension  

---

## 📌 Dépendances  

- `bash`  
- `pv` (Pipe Viewer)  
- `tar`  
