#!/bin/bash

set -o nounset
set -o errexit
set -o pipefail


# If it rebooted this amount of times in a row without fixing the net, stop rebooting
TOTAL_REBOOTS_SKIP_LIMIT=3
TOTAL_REBOOTS_FILE=~/.rebooter_reboots 


network_check() {
    ping -c 1 -w 1 192.168.1.1
}


main() {
    local retries=5
    local cur_tries=0
    local total_reboots=0
    if [[ -e $TOTAL_REBOOTS_FILE ]]; then
        total_reboots=$(cat $TOTAL_REBOOTS_FILE)
    fi

    while true; do
        if [[ $cur_tries -ge $retries ]]; then
            echo "WARNING: detected network issue, rebooting..."
                if [[ $total_reboots -ge $TOTAL_REBOOTS_SKIP_LIMIT ]]; then
                    echo "skipping reboot, rebooted too many times already, to reset remove the $TOTAL_REBOOTS_FILE file."
                else
                    total_reboots=$((total_reboots + 1))
                    echo "$total_reboots" > $TOTAL_REBOOTS_FILE
                    sudo reboot
                fi
        fi

        if ! network_check; then
            cur_tries=$((cur_tries + 1))
        else
            cur_tries=0
        fi

        sleep 10
    done
}


main "$@"
