#!/bin/bash


set -o nounset
set -o errexit
set -o pipefail

while true; do
    cd /home/dcaro/repos/per_user/david-caro/home-lab-secrets
    git fetch --all
    git reset --hard FETCH_HEAD
    
    cd /home/dcaro/repos/per_user/david-caro/home-lab-setup
    git fetch --all
    git reset --hard FETCH_HEAD
    
    ansible-playbook plays/continuous/basic-server-setup.yml
    ansible-playbook plays/continuous/eopsin.yml
    ansible-playbook plays/continuous/apps.yml
    echo "sleeping for 1h"
    sleep 3600
done
