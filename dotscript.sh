#!/bin/bash

VERBOSE=2
DF="$HOME/.dotfiles"
DOTIGNORE=(.git README.md dotscript.sh)

# Check if installed and freshness
if [ -d "$DF" ]; then
    NOW=$(date +%s)
    LAST_UPDATED=$(date -r "$DF" +%s)
    if ((   $(( NOW - LAST_UPDATED )) < $(( 3600*24*17 ))   )); then
        if (( VERBOSE >= 1 ));
            then echo "Dotfiles updated recently."
        fi
        exit
    fi
    # Update
    if (( VERBOSE >= 1 )); then echo "Renewing dotfiles"; fi
    git --git-dir="$DF/.git" --work-tree="$DF" fetch
    touch "$DF"
# Install
else
    if (( VERBOSE >= 1 )); then echo "Installing dotfiles"; fi
    git clone https://github.com/kvaidas/.dotfiles "$DF"
fi

# Update symlinks
function update_symlinks {
    local FROM=$1
    local TO=$2
    ls -1A "$FROM" | while read dotfile; do
        if (( VERBOSE >= 1 )); then
            echo "Dotfile $FROM/$dotfile to dir $TO";
        fi
        if [[ "${DOTIGNORE[*]}" =~ "$dotfile" ]]; then
            if (( VERBOSE >= 1 )); then
                echo "Dotignore: $dotfile"
            fi
            return
        fi
        if [ -d "$FROM/$dotfile" ]; then
            if (( VERBOSE >= 1 )); then
                echo "Dotdir $FROM/$dotfile to $TO/$dotfile";
            fi
            mkdir -p $TO
            update_symlinks "$FROM/$dotfile" "$TO/$dotfile"
        elif [ ! -e "$TO/$dotfile" ]; then
            if (( VERBOSE >= 1 )); then
                echo "Linking $FROM/$dotfile to $TO/$dotfile";
            fi
            ln -s "$TO/$dotfile" "$FROM/$dotfile"
        elif [ ! -L "$TO/$dotfile" ]; then
            if (( VERBOSE >= 2 )); then
                echo "Non-symlink: $TO/$dotfile, diff from $FROM/$dotfile:"
                diff -y "$TO/$dotfile" "$FROM/$dotfile"
            fi
        fi
    done
}
update_symlinks "$DF" "$HOME"

if (( VERBOSE >= 1 )); then echo "Dotfile script done"; fi
