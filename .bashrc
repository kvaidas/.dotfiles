# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

PATH=$HOME/bin:$PATH

# Source machine-local rcfiles
for rcfile in $(find . -maxdepth 1 -name .bashrc_*); do source $rcfile ; done

# Don't record in history: repeated lines and ones beginning with a space
# Also, remove from history all the lines like the one being executed
HISTCONTROL=ignorespace:ignoredups:erasedups

# append to the history file, don't overwrite it
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=5000
HISTTIMEFORMAT='%F %T '

# Enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias cp='cp -i'
    alias mv='mv -i'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    alias less='less -M'
fi

# Some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Locales
if locale -a | grep -q lt_LT.UTF-8; then
    export LANG=lt_LT.UTF-8
    export LC_MESSAGES=POSIX
fi

# Program settings
export GREP_OPTIONS='--color=yes'
export LESS='--RAW-CONTROL-CHARS'

# Enable bash-completion if available
BASH_COMPLETION_SCRIPTS=(
    '/etc/bash_completion/' # Debian/Ubuntu
    '/usr/local/etc/profile.d/bash_completion.sh' # Mac brew
)
for SCRIPT in "${BASH_COMPLETION_SCRIPTS[@]}"; do
    if [ -f "$SCRIPT" ]; then
        . "$SCRIPT"
        break
    fi
done

# Prompts
PS1='${chroot:+($chroot)}\001\e[01;32m\002\u@\h\001\e[0m\002:\001\e[01;34m\002\w\001\e[00m\002\$ '

# Enable git-prompt if available
GIT_PROMPT_SCRIPTS=(
    '/usr/lib/git-core/git-sh-prompt' # Debian/Ubuntu
    '/usr/local/etc/bash_completion.d/git-prompt.sh' # Mac brew
    '/usr/share/git-core/contrib/completion/git-prompt.sh' # RHEL
)
export GIT_PS1_SHOWDIRTYSTATE="true"
export GIT_PS1_SHOWCOLORHINTS="true"
export GIT_PS1_UNTRACKEDFILES="true"
export GIT_PS1_SHOWSTASHSTATE="true"
export GIT_PS1_SHOWUPSTREAM="verbose"

function generate_prompt {
    # Non-zero exit code
    if [ 0 -ne $1 ]; then
        EXIT_CODE_MESSAGE="\001\a\e[0;31m\002Exit code: $1\001\e[0m\002"
        echo ${EXIT_CODE_MESSAGE@P}
    fi

    # Background jobs
    JOBS='\j'
    JOBS=${JOBS@P}
    if [ "0" != $JOBS ]; then
        JOBS="\001\e[1;33m\002(${JOBS})\001\e[0m\002"
        echo -n ${JOBS@P}
    fi

    # Old bash version
    if [ "$BASH_VERSINFO" != 5 ]; then
        echo " $BASH_VERSINFO "
    fi

    # Python virtualenv
    if [ ! -z "$VIRTUAL_ENV" ]; then
        echo -en "\001\e[94m\002 ${VIRTUAL_ENV} \001\e[0m\002"
    fi

    # Vaulted
    if [ ! -z "$VAULTED_ENV" ]; then
        echo -en "\001\e[35m\002 ${VAULTED_ENV} \001\e[0m\002"
    fi

    # Terraform
    if [ -d .terraform ]; then
        if [ -e .terraform/environment ]; then
            terraform_workspace=$(cat .terraform/environment)
        else
            terraform_workspace='default'
        fi
        echo -en "\001\e[94m\002 $terraform_workspace \001\e[0m\002"
    fi

    # Git
    __git_ps1 "" "$PS1_COPY" "(%s) "
}

for SCRIPT in "${GIT_PROMPT_SCRIPTS[@]}"; do
    if [ -f $SCRIPT ]; then
        . $SCRIPT
        PS1_COPY="$PS1"
        PROMPT_COMMAND='generate_prompt $?'
        break
    fi
done
