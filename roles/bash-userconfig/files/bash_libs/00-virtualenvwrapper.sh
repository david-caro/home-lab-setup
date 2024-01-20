#!/bin/env bash

######## venv wrapper
export WORKON_HOME=$HOME/.virtualenvs
venwrap=`type -P virtualenvwrapper.sh`
if [ "$venwrap" != "" ]; then
    source $venwrap
fi

