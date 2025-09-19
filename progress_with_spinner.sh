#!/bin/bash

progress_with_spinner() {
    local total=$1       # nombre d'étapes
    local width=${2:-40} # largeur de la barre
    local delay=${3:-0.1} # vitesse
    local spin='|/-\'

    # couleurs
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

        printf "\r[%s] %3d%% ${yellow}%c${reset}" "$bar" "$percent" "$s"
        sleep $delay
    done

    # ✅ ligne finale correcte (une seule)
    local final_bar="${green}$(printf "%0.s#" $(seq 1 $width))${reset}"
    printf "\r[%s] 100%% ${green}✔${reset}\n" "$final_bar"
}

# Exemple
progress_with_spinner 100 40 0.05

