#!/bin/bash
source /root/user_env.sh

if [ ! -e "/home/${DEV_USER}/.ssh/authorized_keys" ]; then
        cp "/home/${DEV_USER}/._ssh/authorized_keys" "/home/${DEV_USER}/.ssh/authorized_keys"
        chmod 0600 "/home/${DEV_USER}/.ssh/authorized_keys"
        chown -R $DEV_USER:$DEV_USER "/home/${DEV_USER}/.ssh"
fi
if [ ! -e "/home/${DEV_USER}/.ssh/id_ed25519" ]; then
        ssh-keygen -t ed25519 -f "/home/${DEV_USER}/.ssh/id_ed25519" -q -N ""
        chmod 0600 "/home/${DEV_USER}/.ssh/id_ed25519"
        chown -R $DEV_USER:$DEV_USER "/home/${DEV_USER}/.ssh"
fi
/usr/sbin/sshd -D
