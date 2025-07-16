#!/bin/bash

status=$(playerctl status 2>/dev/null)

if [ "$status" = "Playing" ]; then
    icon="▶"
elif [ "$status" = "Paused" ]; then
    icon="⏸"
else
    icon="♪"
fi

artist=$(playerctl metadata artist 2>/dev/null)
title=$(playerctl metadata title 2>/dev/null)

if [ -n "$artist" ] && [ -n "$title" ]; then
    echo "$icon $artist - $title"
else
    echo "Nada suena"
fi
