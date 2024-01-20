#!/bin/env bash
export REPOSPATH=$HOME/Work/repos
export REPOSPATH_PER_USER=$REPOSPATH/per_user
export REPOSPATH_PER_PROJECT=$REPOSPATH/per_proj

cds(){
    local todir="${1}"
    [[ -e "$REPOSPATH" ]] || mkdir -p "$REPOSPATH"/per_{user,proj}
    local dirs=( \
        "$REPOSPATH"/per_{user,proj}/*/"$todir" \
    )
    [[ "$todir" != "" ]] \
    && [[ -d "$dirs" ]] \
    && cd "$dirs" \
    || cd "$REPOSPATH"
}


_get_cds_per_user(){
    local cur="${1}"
    cds
    cd per_user
    for i in *; do
        cd "$i"
        compgen -d -- "${cur}"
        cd ..
    done
}

_get_cds_per_proj(){
    local cur="${1}"
    cds
    cd per_proj
    for i in *; do
        cd "$i"
        compgen -d -- "${cur}"
        cd ..
    done
}

_cds_complete()
{ 
    local cur="$2";
    COMPREPLY=($(\
        _get_cds_per_user "${cur}" \
        && _get_cds_per_proj "${cur}" \
    ))
}
complete -F _cds_complete cds

redpill(){
    local pyver="${1:-python3}"
    local curdir="${PWD##*/}"
    local venv="$curdir${pyver:+-$pyver}"
    workon "$venv" &>/dev/null \
    || mkvirtualenv "$venv" ${pyver:+"--python=$pyver"}
}

redpill3(){
    redpill python3
}

redpill_clean(){
    local pyver="${1:-python3}"
    local curdir="${PWD##*/}"
    local venv="$curdir${pyver:+-$pyver}"
    deactivate
    rmvirtualenv "$venv" &>/dev/null
}

redpill3_clean(){
    redpill_clean python3
}

redpill_reset(){
    redpill_clean
    redpill
}

redpill3_reset(){
    redpill3_clean
    redpill3
}


superclone_help() {
    cat <<EOH
    Usage: superclone [-n|--no-venv] ghuser/repo
EOH
    return
}

superclone(){
    local with_venv="yes"
    [[ "$1" == "-h" ]] && superclone_help && return
    [[ "$1" == "--help" ]] && superclone_help && return
    [[ "$1" == "--no-venv" ]] && with_venv="no" && shift
    [[ "$1" == "-n" ]] && with_venv="no" && shift

    local user_proj="${1?}"
    local user="${user_proj%/*}"
    local proj="${user_proj##*/}"
    local per_user_dir="$REPOSPATH_PER_USER/$user"
    local per_proj_dir="$REPOSPATH_PER_PROJECT/$proj"
    local per_proj_link="$per_proj_dir/$user"

    [[ "$user_proj" =~ .+/.+ ]] || {
        echo "Bad repo passed, must be in the form <user>/<repo>, for example:"
        echo "    david-caro/python-autosemver"
        return 1
    }

    mkdir -p "$per_user_dir"
    mkdir -p "$per_proj_dir"
    cd "$per_user_dir"

    git clone "git@github.com:$user_proj" || return $?
    ln -s "$per_user_dir/$proj" "$per_proj_link"

    cd "$per_user_dir/$proj"
    if [[ "$with_venv" == "yes" ]]; then
        redpill
    fi
    cat <<EOI
    Created repository at '$per_user_dir/$proj' and created symlink at
    '$per_proj_link'.
EOI
}
