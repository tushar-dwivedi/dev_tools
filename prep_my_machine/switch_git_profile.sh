#!/bin/bash

# ~/switch_git_profile.sh

set_git_profile() {
    local profile=$1

    if [[ $profile == "work" ]]; then
        export GIT_PROFILE=work
        echo "Switched to Work Git Profile"
    elif [[ $profile == "personal" ]]; then
        export GIT_PROFILE=personal
        echo "Switched to Personal Git Profile"
    else
        echo "Unknown profile: $profile"
        echo "Usage: $0 {work|personal}"
    fi
}

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 {work|personal}"
    exit 1
fi

set_git_profile $1
