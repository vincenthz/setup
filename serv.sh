#!/bin/sh

cmd_system() {
	apt-get update
	apt-get dist-upgrade
}

### install gitcontrol

cmd_gitcontrol_setup() {
	id git 2>/dev/null
	if [ $? -ne 0 ]; then
		adduser --disabled-login --disabled-password --uid 500 git
		echo "# user:dir/repo:w" >> /home/git/gitcontrol
		mkdir /home/git/.ssh
		chmod 700 /home/git/.ssh
	fi
}

cmd_gitcontrol_update() {
	DEST=/home/git/.ssh/authorized_keys
	TMP_DEST=${DEST}.tmp

	if [ ! -d /home/git/users ]; then
		echo "gitcontrol not setup correctly: missing 'users' directory"
		exit 1
	fi
	if [ ! -f /home/git/gitcontrol ]; then
		echo "gitcontrol not setup correctly: missing 'gitcontrol' file"
		exit 2
	fi

	rm -f $TMP_DEST
	for u in "/home/git/users"/*
	do
		user=$(basename $u)
		# add test to see that $u is a valid user
		while read LINE; do 
			echo "command=\"/usr/bin/gitcontrol-shell ${user}\" $LINE" >> $TMP_DEST
		done < "${u}"
	done

	if [ -f $DEST ]; then
		echo "###### updating authorized key with ..."
		diff -Naur $DEST $TMP_DEST
	fi
	mv $TMP_DEST $DEST
}

cmd_docker() {
    apt-get remove docker docker-engine docker.io
    apt-get install apt-transport-https ca-certificates curl gnupg2 software-properties-common
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
    apt-get install docker-ce
}

case $1 in
  "system") cmd_system;;
  "gitcontrol-setup") cmd_gitcontrol_setup;;
  "gitcontrol") cmd_gitcontrol_update;;
  "docker") cmd_docker;;
  "")
    echo "usage: $0 <system|gitcontrol-setup|gitcontrol|docker>"
    ;;
esac
