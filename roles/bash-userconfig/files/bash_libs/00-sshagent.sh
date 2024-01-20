#!/bin/env bash

[[ "$SSH_AGENT_PID" ]] || eval "$(ssh-agent)"
ssh-add