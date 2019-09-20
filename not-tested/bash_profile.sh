# Copy content below to ~/.bashrc

# Turn on Bash command completion
source /etc/bash_completion

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
alias ipconfig='ifconfig'

# Other Linux stuff
alias bc='bc -l'
alias diff='diff -u'

# get updates from RHN
alias update='yum -y update'

# set eth1 as default
alias dnstop='dnstop -l 5  eth1'
alias vnstat='vnstat -i eth1'

# force colorful grep output
alias grep='grep --color'

# ls stuff
alias l.='ls -d .* --color=tty'
alias ll='ls -l --color=tty'
alias ls='ls --color=tty'