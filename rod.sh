#!/bin/bash
# Script: Direct Movie URL Downloader

# --------------------------
# 1. Configuration / Variables (Wala na tayong TMDB keys)
# --------------------------
# Walang kailangan na TMDB keys/URLs dito.

# --------------------------
# 2. Function: Check Prerequisites
# --------------------------
check_prereqs() {
    # Kailangan lang ng 'wget' at 'curl'
    if ! command -v wget &> /dev/null && ! command -v curl &> /dev/null; then
        echo "ERROR: Kailangan mo ng 'wget' o 'curl' packages."
        echo "Paki-install sa Termux: pkg install wget curl -y"
        exit 1
    fi
}

# --------------------------
# 3. Main Logic
# --------------------------

check_prereqs

echo "--- DIRECT MOVIE DOWNLOADER ---"

# Kumuha ng input mula sa user (ang direct URL)
read -p "I-paste ang DIRECT MOVIE URL (e.g., http://.../movie.mp4) dito: " movie_url

# I-check kung may in-input
if [ -z "$movie_url" ]; then
    echo "ERROR: Walang in-input na URL."
    exit 1
fi

# Kumuha ng default filename mula sa URL (e.g., kukunin ang 'movie.mp4' mula sa huling part ng link)
# Ang 'basename' ay kukuha ng filename mula sa path
DEFAULT_FILENAME=$(basename "$movie_url")

# Linisin ang default filename (para sa mga characters na hindi pwede)
CLEAN_DEFAULT_FILENAME=$(echo "$DEFAULT_FILENAME" | tr -cd '[:alnum:]._-')

# Kumuha ng desired output filename mula sa user, gamit ang CLEAN_DEFAULT_FILENAME bilang suggestion
read -p "I-type ang output filename (default: $CLEAN_DEFAULT_FILENAME): " user_filename

# Gamitin ang input ng user, pero kung wala siyang in-input, gamitin ang default filename
FILE_NAME=${user_filename:-$CLEAN_DEFAULT_FILENAME}

echo "Sinisimulan ang pag-download..."
echo "Source: $movie_url"
echo "Saving as: $FILE_NAME"
echo "-----------------------------------"

# Gamitin ang 'wget' para i-download ang file
# Ang 'wget' ay mas madalas gamitin para sa download ng malaking file
if command -v wget &> /dev/null; then
    # -c para mag-resume kung sakaling ma-interrupt (laking tulong sa Termux)
    # -O para i-save sa specific filename
    if wget -c "$movie_url" -O "$FILE_NAME"; then
        echo -e "\nSUCCESS: Kumpleto na ang pag-download at na-save bilang: $FILE_NAME"
    else
        echo -e "\nERROR: Hindi ma-download ang file. Paki-check ang URL, network connection, at file size limit."
    fi
elif command -v curl &> /dev/null; then
    # Kung walang wget, gamitin ang curl (walang resume capability dito)
    echo "NOTE: Gumagamit ng curl (walang resume capability)."
    if curl -L "$movie_url" -o "$FILE_NAME"; then
        echo -e "\nSUCCESS: Kumpleto na ang pag-download at na-save bilang: $FILE_NAME"
    else
        echo -e "\nERROR: Hindi ma-download ang file. Paki-check ang URL, network connection, at file size limit."
    fi
else
    echo "FATAL ERROR: Walang 'wget' o 'curl' na nakita, kahit sinabing installed."
fi

echo "-----------------------------------"
echo "Tapos na ang Download script."