#!/bin/env bash

command -v rbenv &>/dev/null && {
    # Add rbenv for ruby environments
    # https://github.com/rbenv/rbenv#basic-github-checkout
    export PATH="$PATH:$HOME/.rbenv/bin"
    eval "$(rbenv init -)"
}
