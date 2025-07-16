#!/bin/sh

interface="wlan0"
ip=$(ip addr show "$interface" | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)

if [ -n "$ip" ]; then
    echo "%{B#ffb3d6}%{F#1a1a1a}   $ip %{B-}%{F-}"
else
    echo "%{B#666666}%{F#000000}   Disconnected %{B-}%{F-}"
fi
