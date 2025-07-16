#!/bin/bash

# Verifica si la VPN está activa mirando si existe tun0
if ip link show proton0 > /dev/null 2>&1; then
    echo "%{F#1a1a1a}%{B#ffb3d6}  Connected %{B-}%{F-}"
else
    echo "%{F#ffb3d6}%{B#666666}  Disconnected %{B-}%{F-}"
fi
