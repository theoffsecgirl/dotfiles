#!/bin/bash

sleep_interval=0.2
scroll_speed=1
max_length=30
empty_space="     "

scroll_text() {
    local text="$1"
    local length=${#text}
    local i=0

    while true; do
        local start=$((i % length))
        local display="${text:start}${text:0:start}"
        echo "%{F#ffb3d6} ▶� ${display:0:$max_length}%{F-}"
        sleep $sleep_interval
        ((i += scroll_speed))
    done
}

get_current_song() {
    playerctl metadata --format '{{ title }} - {{ artist }}' 2>/dev/null
}

main() {
    last_song=""
    while read -r new_metadata; do
        song=$(echo "$new_metadata" | sed 's/\s\s*/ /g')

        [[ -z "$song" ]] && song="No song playing"
        [[ "$song" == "$last_song" ]] && continue
        last_song="$song"

        kill $(jobs -p) 2>/dev/null
        scroll_text "$song$empty_space" &
    done < <(playerctl metadata --format '{{ title }} - {{ artist }}' --follow)
}

main
