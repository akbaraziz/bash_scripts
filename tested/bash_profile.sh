#!/bin/bash
# To create customized profiles with different aliases when using bash shell
# Created by: Akbar Aziz
# Date: 06/05/2020
# Version: 1.0


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

# Other Linux stuff
alias diff='diff -u'

# get updates from RHN
alias update='yum -y update'

# force colorful grep output
alias grep='grep --color'

# ls stuff
alias l.='ls -d .* --color=tty'
alias ll='ls -l --color=tty'
alias ls='ls --color=tty'