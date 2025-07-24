#!/bin/bash

if bluetoothctl info | grep -q "Connected: yes"; then
  echo "%{F#ffb3d6} ïˆ…µ BT: Conectado%{F-}"
else
  echo "%{F#999999} ïˆ„ª BT: Desconectado%{F-}"
fi
