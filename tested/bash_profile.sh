#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts
# Script create date: 07/02/2020
# Script ver: 1.0
# Script tested on OS: CentOS 7.x
# Script purpose: Set your Bash profile

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