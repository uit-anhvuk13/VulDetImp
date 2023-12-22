#!/bin/sh

export EDITOR='/usr/bin/vi'
export HISTCONTROL='ignoreboth:erasedups'
export PS1='\[\033[38;5;45m\]\u@\h \[\033[38;5;33m\]\w\[\033[38;5;175m\]$(__git_ps1 " (%s)" 2> /dev/null)\n\[\033[38;5;15m\]\$ \[\033[0m\]'

alias bashrc='vi ~/.bashrc'
alias src='clear && exec $SHELL'

__git_ps1 () {
    git_dir="$(git rev-parse --git-dir 2>/dev/null)"
    if [ -n "$git_dir" ]; then
        if branch_name=$(git symbolic-ref --quiet HEAD 2>/dev/null); then
            branch_name=${branch_name##refs/heads/}
            printf " (%s)" "$branch_name"
        else
            printf " (detached)"
        fi
    fi
}

