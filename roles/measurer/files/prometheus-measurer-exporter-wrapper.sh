#!/bin/bash

# thin wrapper as the python script sometimes just hangs

while true; do
    # restart every hour, just in case it gets stuck
    timeout 3200 ~/venv/bin/python3 "$(dirname "$0$")/prometheus-measurer-exporter.py"  "$@"
    echo "The process finished bit rc $?, restarting"
    sleep 1
done
