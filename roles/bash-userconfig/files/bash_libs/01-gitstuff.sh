#!/bin/env bash

nice_date() {
    date --date="$1"
}
# to be able to use it from gitconfig we need to export the function
export -f nice_date


hash_at() {
    local branch="${2:-$(git rev-parse --abbrev-ref HEAD)}"
    git rev-list -1 --before="$(nice_date "$1")" "$branch"
}
# to be able to use it from gitconfig we need to export the function
export -f hash_at


show_at() {
    git show "$(hash_at "$*")"
}
# to be able to use it from gitconfig we need to export the function
export -f show_at


git_clean_branches() {
    local branch
    git branch >/dev/null || {
        echo "Not in a git repo"
        return 1
    }
    for branch in $(git branch | grep -v '*' | grep -v master); do
        git branch -D "$branch"
    done
    return 0
}
