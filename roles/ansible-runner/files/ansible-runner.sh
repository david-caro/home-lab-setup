#!/bin/bash


set -o nounset
set -o errexit
set -o pipefail

OPS_DIR=~dcaro/ops
SECRETS_DIR=$OPS_DIR/home-lab-secrets
SETUP_DIR=$OPS_DIR/home-lab-setup
VENV_DIR=$OPS_DIR/ansible-venv


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

ensure_venv() {
    local venv_dir="${1:?No venv_dir passed}"
    local setup_repo="${2:?No setup_repo passed}"

    if [[ -e "$venv_dir/bin/activate" ]]; then
        source "$venv_dir/bin/activate"
        # check if the venv is working
        pip freeze &>/dev/null && {
            pip install --upgrade -r "$setup_repo/requirements.txt"
            return 0
        }

        deactivate
        # recreate the venv
        rm -rf "$venv_dir"
    fi

    mkdir -p "$venv_dir"
    python3 -m venv "$venv_dir"
    source "$venv_dir/bin/activate"
    pip install --upgrade -r "$setup_repo/requirements.txt"
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
    for play in "${plays_dir}"/*.yaml; do
        ansible-playbook "$play" || :
    done
}



main() {
    init
    while true; do
        update_repo "$SETUP_DIR"
        update_repo "$SECRETS_DIR"

        ensure_venv "$VENV_DIR" "$SETUP_DIR"
        source "$VENV_DIR/bin/activate"
        cd "$SETUP_DIR"
        run_plays "${SETUP_DIR}/plays/continuous"
        
        echo "sleeping for 1h"
        sleep 3600
    done

}


main "$@"
