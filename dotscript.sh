#!/bin/bash

verbose=1
dotfiles="$PWD"
dotignore=(.git README.md dotscript.sh backups)

# Check freshness
if [ -d "$dotfiles" ]; then
    now=$(date +%s)
    last_updated=$(date -r "$dotfiles" +%s)
    if [ "$1" != '-f' ] && ((   $(( now - last_updated )) < $(( 3600*24*17 ))   )); then
        if (( verbose >= 1 ));
            then echo "Dotfiles updated recently."
        fi
        exit
    fi

    # Update
    if (( verbose >= 1 )); then echo "Renewing dotfiles"; fi
    git --git-dir="${dotfiles}/.git" --work-tree="$dotfiles" fetch
    touch "$dotfiles"
else
    "Dotfile dir \'${dotfiles}\' not found"
fi

function update_symlinks {
    local from=$1
    local to=$2
    ls -1A "${from}" | while read dotfile; do
        if (( verbose >= 2 )); then
            echo "Dotfile ${from}/${dotfile} to dir ${to}";
        fi

        # Skip ignored files
        if [[ "${dotignore[*]}" =~ $dotfile ]]; then
            if (( verbose >= 2 )); then
                echo "Dotignore: ${dotfile}"
            fi
            continue
        fi

        # This is a dotdir
        if [ -d "${from}/${dotfile}" ]; then
            if (( verbose >= 2 )); then
                echo "Dotdir ${from}/${dotfile} to ${to}/${dotfile}";
            fi
            mkdir -p "${to}/${dotfile}"
            update_symlinks "${from}/${dotfile}" "${to}/${dotfile}"
            continue
        fi

        # Backup non-symlinks
        if [ ! -L "${to}/${dotfile}" ]; then
            echo "Non-symlink: ${to}/${dotfile}, backing up to ${from}"
            mv "${to}/${dotfile}" "${from}/backups/${dotfile}-$(date '+%Y-%m-%dT%H:%M:%S')"
        fi

        # Symlink dotfile
        rm -f "${to}/${dotfile}"
        if (( verbose >= 1 )); then
            echo "Linking ${from}/${dotfile} to ${to}/${dotfile}";
        fi
        ln -s "${from}/${dotfile}" "${to}/${dotfile}"
    done
}

# Run the function
update_symlinks "$dotfiles" "$HOME"
