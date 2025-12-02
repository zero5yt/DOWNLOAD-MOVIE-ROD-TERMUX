#!/bin/bash
# Edukasyonal na Script: Simple TMDB Movie Search at Poster Downloader

# --------------------------
# 1. Configuration / Variables
# --------------------------
API_KEY="2ca7867bd79df533100a376465e92a0f"  # Iyong TMDB API Key
TMDB_URL="https://api.themoviedb.org/3/search/movie"
IMAGE_BASE_URL="https://image.tmdb.org/t/p/w500" # Base URL para sa pagkuha ng poster images

# --------------------------
# 2. Function: Check Prerequisites
# --------------------------
check_prereqs() {
    # Dapat may 'curl', 'jq', at 'wget'
    if ! command -v curl &> /dev/null || ! command -v jq &> /dev/null || ! command -v wget &> /dev/null; then
        echo "ERROR: Kailangan mo ng 'curl', 'jq', at 'wget' packages."
        echo "Paki-install sa Termux: pkg install curl jq wget -y"
        exit 1
    fi
}

# --------------------------
# 3. Main Logic
# --------------------------

check_prereqs

# Kumuha ng input mula sa user
read -p "I-type ang title ng pelikula: " search_query

# I-encode ang search query para sa URL (palitan ang space ng %20)
ENCODED_QUERY=$(echo "$search_query" | sed 's/ /%20/g')

echo "Naghahanap ng pelikula para sa: $search_query"

# I-construct ang final API URL
FULL_URL="${TMDB_URL}?api_key=${API_KEY}&query=${ENCODED_QUERY}"

# Tawagin ang API at i-store ang JSON response
RESPONSE=$(curl -s "$FULL_URL")

# I-check kung may resulta
if [ "$(echo "$RESPONSE" | jq '.total_results')" == "0" ]; then
    echo "Walang nakitang resulta para sa '$search_query'."
else
    echo -e "\n--- TOP RESULT ---"
    
    # Gamitin ang jq para kumuha ng data mula sa unang (index 0) resulta
    TITLE=$(echo "$RESPONSE" | jq -r '.results[0].title')
    RELEASE_DATE=$(echo "$RESPONSE" | jq -r '.results[0].release_date')
    OVERVIEW=$(echo "$RESPONSE" | jq -r '.results[0].overview')
    POSTER_PATH=$(echo "$RESPONSE" | jq -r '.results[0].poster_path')

    echo "Title: $TITLE"
    echo "Release Date: $RELEASE_DATE"
    echo "Overview: $OVERVIEW"
    
    # --- IMAGE DOWNLOAD LOGIC ---
    if [ "$POSTER_PATH" != "null" ]; then
        POSTER_URL="${IMAGE_BASE_URL}${POSTER_PATH}"
        # Linisin ang TITLE para sa filename (inalis ang mga characters na hindi pwede)
        CLEAN_TITLE=$(echo "$TITLE" | tr -cd '[:alnum:]._-')
        FILE_NAME="${CLEAN_TITLE}_poster.jpg" 
        
        echo -e "\n--- DOWNLOADING POSTER ---"
        
        # Gamitin ang 'wget' para i-download ang image
        if wget -q "$POSTER_URL" -O "$FILE_NAME"; then
            echo "SUCCESS: Na-save ang Poster bilang: $FILE_NAME"
        else
            echo "ERROR: Hindi ma-download ang poster."
        fi
    else
        echo -e "\nWalang available na poster image para sa pelikulang ito."
    fi
    # ----------------------------

    echo "------------------"
fi

echo "Tapos na ang TMDB script."