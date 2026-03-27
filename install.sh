#!/bin/bash

#Probably need to think of the simplest way to get these installed on new installations but for now its just like live documentation i guess?
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ln -s "${SCRIPT_DIR}/.gitconfig" ~/.gitconfig
