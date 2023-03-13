#!/bin/bash


set -o nounset
set -o errexit
set -o pipefail

OPS_DIR=~dcaro/ops
SECRETS_DIR=$OPS_DIR/home-lab-secrets
SETUP_DIR=$OPS_DIR/home-lab-setup


init() {
   # bootstrap the setup
   [[ -d "$OPS_DIR" ]] || mkdir -p "$OPS_DIR"
   [[ -d "$SECRETS_DIR" ]] || {
       git clone git@github.com:david-caro/home-lab-secrets.git "$SECRETS_DIR"
   }
   [[ -d "$SETUP_DIR" ]] || {
       git clone git@github.com:david-caro/home-lab-setup.git "$SETUP_DIR"
   }
}


update_repo() {
    local repo="${1?No repo passed}"
    cd "$repo"
    git fetch --all
    git rebase FETCH_HEAD
    cd -
}


run_plays() {
    local plays_dir="${1?No plays_dir passed}"
    for play in "${plays_dir}"/*.yml; do
        ansible-playbook "$play" || :
    done
}



main() {
    init
    while true; do
        update_repo "$SETUP_DIR"
        update_repo "$SECRETS_DIR"

        cd "$SETUP_DIR"
        run_plays "${SETUP_DIR}/plays/continuous"
        
        echo "sleeping for 1h"
        sleep 3600
    done

}


main "$@"
