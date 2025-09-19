#!/bin/bash
#
# Progression avec barre ou spinner
# Usage :
#   progressbar <total> [largeur] [vitesse]
#   progressbar -- <commande> [args...]
#   progressbar --pv <src> <dest>
#   progressbar --pv-archive [--verbose] <dir> <file>
#   progressbar --pv-extract [--verbose] <file> <dir>

# --------- Options globales ---------
VERBOSE=0
ARGS=()

for arg in "$@"; do
    if [[ "$arg" == "--verbose" ]]; then
        VERBOSE=1
    else
        ARGS+=("$arg")
    fi
done

set -- "${ARGS[@]}"

# --------- Helpers ---------

# Affiche une commande avec barre toujours en bas (corrigé pour pv)
show_progress_bottom() {
    local cmd="$1"
    local term_lines=$(tput lines)
    local bar_line=$((term_lines-1))

    # Capture stderr de pv (séquences avec \r) en mode raw
    eval "$cmd" 2> >(stdbuf -o0 cat | while IFS= read -r -n1 char; do
        buffer+="$char"
        if [[ "$char" == $'\r' ]]; then
            tput cup $bar_line 0
            tput el
            printf "%s" "$buffer"
            buffer=""
        fi
    done)

    # Nettoyage final
    echo ""
}

progressbar_simulated() {
    local total=$1
    local width=${2:-40}
    local delay=${3:-0.1}
    local spin='|/-\'

    local green=$(tput setaf 2)
    local red=$(tput setaf 1)
    local yellow=$(tput setaf 3)
    local reset=$(tput sgr0)

    for i in $(seq 1 $total); do
        local percent=$(( i * 100 / total ))
        local filled=$(( i * width / total ))
        local empty=$(( width - filled ))
        local s=${spin:$(( i % 4 )):1}

        local bar="${green}$(printf "%0.s#" $(seq 1 $filled))${reset}"
        bar+="${red}$(printf "%0.s-" $(seq 1 $empty))${reset}"

        tput cup $(( $(tput lines)-1 )) 0
        tput el
        printf "[%s] %3d%% ${yellow}%c${reset}" "$bar" "$percent" "$s"

        sleep $delay
    done

    local final_bar="${green}$(printf "%0.s#" $(seq 1 $width))${reset}"
    tput cup $(( $(tput lines)-1 )) 0
    tput el
    printf "[%s] 100%% ${green}✔${reset}\n" "$final_bar"
}

progressbar_command() {
    local spin='|/-\'
    local yellow=$(tput setaf 3)
    local green=$(tput setaf 2)
    local reset=$(tput sgr0)

    "$@" &
    local pid=$!

    local i=0
    while kill -0 $pid 2>/dev/null; do
        local s=${spin:$(( i % 4 )):1}
        tput cup $(( $(tput lines)-1 )) 0
        tput el
        printf "${yellow}[%c]${reset} En cours..." "$s"
        sleep 0.1
        ((i++))
    done

    wait $pid
    local status=$?

    tput cup $(( $(tput lines)-1 )) 0
    tput el
    if [[ $status -eq 0 ]]; then
        printf "${green}[✔]${reset} Terminé !       \n"
    else
        printf "[✘] Erreur (code %d)\n" "$status"
    fi
}

progressbar_pv() {
    local src=$1
    local dest=$2
    if ! command -v pv >/dev/null; then
        echo "Erreur : 'pv' n’est pas installé."
        exit 1
    fi
    if [[ -d "$src" ]]; then
        echo "Archivage de $src vers $dest ..."
        tar -cf - "$src" | pv | tar -xf - -C "$dest"
    elif [[ -f "$src" ]]; then
        local size=$(stat -c %s "$src" 2>/dev/null || stat -f %z "$src")
        echo "Copie de $src vers $dest ..."
        pv -s "$size" "$src" > "$dest"
    else
        echo "Erreur : $src n’existe pas"
        exit 1
    fi
}

progressbar_pv_archive() {
    local src=$1
    local dest=$2
    if ! command -v pv >/dev/null; then
        echo "Erreur : 'pv' n’est pas installé."
        exit 1
    fi
    if [[ -d "$src" ]]; then
        local start=$(date +%s)
        if [[ "$dest" == *.tar.gz ]]; then
            echo "Création de l’archive compressée $dest depuis $src ..."
            if [[ $VERBOSE -eq 1 ]]; then
                show_progress_bottom "tar -cvf - \"$src\" | pv | gzip > \"$dest\""
            else
                tar -cf - "$src" | pv | gzip > "$dest"
            fi
        elif [[ "$dest" == *.tar ]]; then
            echo "Création de l’archive non compressée $dest depuis $src ..."
            if [[ $VERBOSE -eq 1 ]]; then
                show_progress_bottom "tar -cvf - \"$src\" | pv > \"$dest\""
            else
                tar -cf - "$src" | pv > "$dest"
            fi
        else
            echo "Erreur : le fichier destination doit se terminer par .tar ou .tar.gz"
            exit 1
        fi
        local end=$(date +%s)
        local duration=$((end - start))
        local size=$(stat -c %s "$dest" 2>/dev/null || stat -f %z "$dest")
        echo -e "\nRésumé :"
        echo " - Taille : $(numfmt --to=iec $size)"
        echo " - Durée  : ${duration}s"
        if (( duration > 0 )); then
            echo " - Vitesse: $(numfmt --to=iec $(( size / duration )))/s"
        fi
    else
        echo "Erreur : $src n’est pas un dossier"
        exit 1
    fi
}

progressbar_pv_extract() {
    local archive=$1
    local dest=$2
    if ! command -v pv >/dev/null; then
        echo "Erreur : 'pv' n’est pas installé."
        exit 1
    fi
    if [[ ! -f "$archive" ]]; then
        echo "Erreur : l’archive $archive n’existe pas"
        exit 1
    fi
    mkdir -p "$dest"
    local start=$(date +%s)
    if [[ "$archive" == *.tar.gz ]]; then
        echo "Extraction de l’archive compressée $archive vers $dest ..."
        if [[ $VERBOSE -eq 1 ]]; then
            show_progress_bottom "pv \"$archive\" | tar -xvzf - -C \"$dest\""
        else
            pv "$archive" | tar -xzf - -C "$dest"
        fi
    elif [[ "$archive" == *.tar ]]; then
        echo "Extraction de l’archive $archive vers $dest ..."
        if [[ $VERBOSE -eq 1 ]]; then
            show_progress_bottom "pv \"$archive\" | tar -xvf - -C \"$dest\""
        else
            pv "$archive" | tar -xf - -C \"$dest\"
        fi
    else
        echo "Erreur : format non supporté"
        exit 1
    fi
    local end=$(date +%s)
    local duration=$((end - start))
    local size=$(stat -c %s "$archive" 2>/dev/null || stat -f %z "$archive")
    echo -e "\nRésumé :"
    echo " - Taille : $(numfmt --to=iec $size)"
    echo " - Durée  : ${duration}s"
    if (( duration > 0 )); then
        echo " - Vitesse: $(numfmt --to=iec $(( size / duration )))/s"
    fi
}

# --------- Choix du mode ---------
case "$1" in
    --)
        shift
        progressbar_command "$@"
        ;;
    --pv)
        shift
        progressbar_pv "$@"
        ;;
    --pv-archive)
        shift
        progressbar_pv_archive "$@"
        ;;
    --pv-extract)
        shift
        progressbar_pv_extract "$@"
        ;;
    *)
        progressbar_simulated "$@"
        ;;
esac

