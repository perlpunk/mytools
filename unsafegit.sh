#!/bin/bash

unsafegit() {
    local realhome=$HOME
    local TMPGIT HOME
    TMPGIT=$(mktemp -d --tmpdir tempgithome.XXXXX)
    [[ $? -ne 0 ]] && return 1
    [[ ! -d "$TMPGIT" ]] && return 1
    HOME=$TMPGIT
    export HOME
    for i in "${UNSAFEGIT_INCLUDEPATHS[@]}"; do
        git config --global --add include.path "$i"
    done
    git config --global --add safe.directory "$PWD"
    git "$@"
    \rm -r "$TMPGIT"
}

## Purpose

# git prevents us from accidentally executing malicious code when running
# git commands in git directories owned by others.
# However, sometimes we just know it's safe, and we don't want to manually
# add such paths to our config all the time.

## Usage

    # % source unsafegit.sh
    # go to an unsafe git repository
    # % unsafegit log

## Config

# optionally add include paths to git configs, e.g.
# if you don't want to miss your usual git aliases,
# put this in your shell config file:

#     export UNSAFEGIT_INCLUDEPATHS=($HOME/.gitconfig /another/path)
