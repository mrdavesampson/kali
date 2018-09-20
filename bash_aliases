# Basic Aliases
# Copy to ~/.bash_aliases
# Then use source ~/.bash_aliases to process before next session


alias ls='ls --color=auto'
alias ll='ls -hal --color=auto --time-style="+%b %d %Y %H:%M"'
alias lt='ls -hltr --color=auto --time-style="+%b %d %Y %H:%M"'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# update & clean
function apt-updater {
	echo 'apt-get update ...' &&
	sudo apt-get update &&
	echo 'apt-get dist-upgrade -Vy ...' &&
	sudo apt-get dist-upgrade -Vy &&
	echo 'apt-get autoremove -y ...' &&
	sudo apt-get autoremove -y &&
	echo 'apt-get autoclean ...' &&
	sudo apt-get autoclean &&
	echo 'apt-get clean ...' &&
	sudo apt-get clean &&
	echo 'reboot' &&
	reboot
	}

# Change bash prompt. See the article
# http://www-106.ibm.com/developerwork.../l-tip-prompt/
# export PS1='\u\[\e[34;1m\]@\[\e[36;1m\]\H \[\e[34;1m\]\w\[\e[32;1m\] $ \[\e[0m\]'
export PS1='\[\e[31;40;1m\]\u\[\e[37;1m\]@\[\e[35;1m\]\H\[\e[33;1m\]:\[\e[32;1m\]\w\[\e[31;40m\]$\[\e[0m\] '

# Monitor logs
alias syslog='sudo tail -100f /var/log/syslog'
alias messages='sudo tail -100f /var/log/messages'

# Keep 1000 lines in .bash_history (default is 500)
export HISTSIZE=1000
export HISTFILESIZE=1000

#Stop bash from caching duplicate lines.
HISTCONTROL=ignoredups

# List paths
alias path='echo -e ${PATH//:/\\n}'

# For nano editor
alias nano='nano -w'
