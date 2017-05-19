# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Don't record in history: repeated lines and ones beginning with a space
# Also, remove from history all the lines like the one being executed
HISTCONTROL=ignorespace:ignoredups:erasedups

# append to the history file, don't overwrite it
shopt -s histappend
shopt -s autocd
HISTSIZE=1000
HISTFILESIZE=5000

color_prompt=yes
if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt 

# enable color support of ls and also add handy aliases
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

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# locales
if locale -a | grep -q lt_LT.UTF-8; then
  export LANG=lt_LT.UTF-8
  export LC_MESSAGES=C.UTF-8
fi
