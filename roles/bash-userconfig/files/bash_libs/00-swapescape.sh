#!/bin/env bash

# swap caps lock with escape
xmodmap -e 'clear Lock' -e 'keycode 0x42 = Escape' &>/dev/null

