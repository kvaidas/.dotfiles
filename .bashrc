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
shopt -s autocd
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

# Prom
color_prompt=yes
if [ "$color_prompt" = yes ]; then
    PS1='${chroot:+($chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${chroot:+($chroot)}\u@\h:\w\$ '
fi
unset color_prompt 

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
    # Show non-zero exit code
    BELL=$'\a'
    if [ 0 -ne $1 ]; then
        EXIT_CODE_MESSAGE="\a\[\033[0;31\]mExit code: $1"
        echo ${EXIT_CODE_MESSAGE@P}
    fi

    # Show if there are background jobs present
    JOBS='\j'
    JOBS=${JOBS@P}
    if [ "0" != $JOBS ]; then
        JOBS="\[\033[1;33\]m(${JOBS})"
        echo -n ${JOBS@P}
    fi

    # Git prompt
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
