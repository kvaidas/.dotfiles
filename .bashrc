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
HISTSIZE=5000
HISTTIMEFORMAT='%F %T '

# Aliases
alias grep='grep --color=auto'
alias k='kubectl'

# Locales
if locale -a | grep -q lt_LT.UTF-8; then
    export LANG=lt_LT.UTF-8
    export LC_MESSAGES=POSIX
fi

# Program settings
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
PS1='\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ '

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
        echo -e "\001\a\e[1;31m\002Exit code: $1\001\e[0m\002"
    fi

    P=""

    # Background jobs
    JOBS='\j'
    if [ "0" != "${JOBS@P}" ]; then
        P="${P}\[\e[1;33m\](${JOBS@P})\[\e[0m\] "
    fi

    # Old bash version
    if [ "$BASH_VERSINFO" != 5 ]; then
        P="${P}${BASH_VERSINFO} "
    fi

    # Python virtualenv
    if [ -n "$VIRTUAL_ENV" ]; then
        P="${P}\[\e[94m\]${VIRTUAL_ENV} \[\e[0m\]"
    fi

    # Vaulted
    if [ -n "$VAULTED_ENV" ]; then
        expiry=$(TZ=UTC date -j -f "%Y-%m-%dT%H:%M:%SZ" "$VAULTED_ENV_EXPIRATION" "+%s")
        now=$(TZ=UTC date -j "+%s")
        remaining_time=$(( ($expiry - $now)/60 ))
        if (( $remaining_time <= 0 )); then
            expiry_text="\[\e[7m\]!!!"
        else
            expiry_text="(${remaining_time})"
        fi
        P="${P}\[\e[35m\]${VAULTED_ENV} ${expiry_text}\[\e[0m\] "
    fi

    # aws-vault
    if [ -n "$AWS_SESSION_EXPIRATION" ]; then
        expiry=$(date -j -f '%Y-%m-%dT%H:%M:%S' ${AWS_SESSION_EXPIRATION:0:19} '+%s')
        now=$(date '+%s')
        remaining_time=$(( ($expiry - $now)/60 ))
        if (( $remaining_time <= 0 )); then
            expiry_text="\[\e[;31m\]!!!"
        else
            expiry_text="(${remaining_time})"
        fi
        P="${P}\[\e[;33m\]AWS ${expiry_text}\[\e[0m\] "
    fi

    # Terraform
    if [ -d .terraform ]; then
        if [ -e .terraform/environment ]; then
            terraform_workspace=$(cat .terraform/environment)
        else
            terraform_workspace='default'
        fi
        P="${P}\[\e[94m\]$terraform_workspace\[\e[0m\] "
    fi

    # Git
    __git_ps1 "$P" "$PS1_COPY" "(%s) "
}

for SCRIPT in "${GIT_PROMPT_SCRIPTS[@]}"; do
    if [ -f $SCRIPT ]; then
        . $SCRIPT
        PS1_COPY=$PS1
        PROMPT_COMMAND='generate_prompt $?'
        break
    fi
done
