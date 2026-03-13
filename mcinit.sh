#!/bin/bash

# Create config, binary and data directories
DATADIR="$HOME/.local/share/mcgen"
BINARYDIR="$HOME/.local/bin"
BINARY="$BINARYDIR/mcgen"
CONFIGDIR="$HOME/.config/mcgen"
TEMPLATESDIR="$DATADIR/templates"

if [[ ! -t 0 ]]; then
    exit 1
fi

install_mcgen() {
    mkdir -pv $DATADIR
    mkdir -pv $BINARYDIR
    mkdir -pv $CONFIGDIR

    if [[ "$(ls -A "$DATADIR")" || "$(command -v "$BINARY")" || "$(ls -A "$CONFIGDIR")" ]]; then
        echo "Error: Script has already ran. Please do not rerun it. If you'd like to uninstall it then please run the following:"
        echo "/mcinit.sh --remove"
        exit 1
    fi

    # Copy initial defaults to defaults
    cp -v ./initial-defaults.json $CONFIGDIR/defaults.json

    # Copy scripts to .local/share/mcgen
    cp -rv ./scripts $DATADIR/scripts

    chmod +x $DATADIR/scripts/*.sh

    ln -sv $DATADIR/scripts/mcgen.sh $BINARY

    cp -r ./templates $TEMPLATESDIR
    echo "'./templates' -> '$TEMPLATESDIR'"

    echo "Successfully installed mcgen!"
    exit 0
}

remove_mcgen() {
    if [ -d $TEMPLATESDIR ]; then
        rm -r $TEMPLATESDIR
        echo "removed directory '$TEMPLATESDIR'"
    fi

    if [ -d $DATADIR ]; then
        rm -rv $DATADIR
    fi

    if [ -L $BINARY ]; then
        rm -v $BINARY
    fi

    if [ -d $CONFIGDIR ]; then
        rm -rv $CONFIGDIR
    fi

    echo "Successfully removed mcgen!"
    exit 0
}

if [[ "$1" == "--remove" ]]; then
    remove_mcgen
else
    install_mcgen
fi
