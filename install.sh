#!/usr/bin bash

set -e

if (( EUID != 0 ))
then
  echo "You must be root to run this file." 1>&2
  exit 100
fi

if [ -z "$1" ]
then
  echo "You must provide a sudo password." 1>&2
  exit 101
else
  SUDO_PASS=$1
fi

SYSINIT_PATH=/home/${SUDO_USER}/sysinit
RELEASE=$(cat /etc/os-release | grep '^ID=' | awk '{ split($0, a, "="); print a[2]}')
CODENAME=$(lsb_release -cs)

apt-get install -y git

if [ ! -d ${SYSINIT_PATH} ]
then
  git clone -b main --single-branch https://github.com/kedwards/sysinit.git ${SYSINIT_PATH}
  cd ${SYSINIT_PATH}
#else
 cd ${SYSINIT_PATH}
fi

su -c "ansible-playbook -i inventory/hosts.yml project/playbook.yml -K --ask-vault-pass --tags core -e 'ansible_sudo_pass=${SUDO_PASS}'" ${SUDO_USER}

