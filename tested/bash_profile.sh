#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/blob/master/tested/bash_profile.sh
# Script create date: 07/02/2020
# Script ver: 1.0.0
# Script purpose: Set your Bash profile
# Script tested on OS: CentOS 7.x
#--------------------------------------------------

set -ex

# Copy content below to ~/.bashrc

# Turn on Bash command completion
sudo yum install bash-completion
source /etc/profile.d/bash_completion.sh

# CMD Line aliases
alias edit=$VISUAL
alias copy='cp'
alias cls='clear'
alias del='rm'
alias dir='ls'
alias md='mkdir'
alias move='mv'
alias rd='rmdir'
alias ren='mv'
alias ipconfig='ip a'
alias diff='diff -u'

# Get OS Updates
alias update='yum -y update'

# Force colorful grep output
alias grep='grep --color'

# ls stuff
alias l.='ls -d .* --color=tty'
alias ll='ls -l --color=tty'
alias ls='ls --color=tty'