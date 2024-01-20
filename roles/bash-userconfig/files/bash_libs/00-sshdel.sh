#!/bin/env bash

sshdel() {
    sed -ie "$1d" ~/.ssh/known_hosts
}
