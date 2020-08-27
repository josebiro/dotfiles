#!/bin/bash

# update local
sudo apt -y update
sudo apt -y dist-upgrade

# Required for VIM
sudo apt -y install vim vim-addon-manager vim-common vim-gocomplete

# required for golang version manager
sudo apt -y install bison

# install gvm
if [ ! -d ~/.gvm ]; then
  cd $HOME
  bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
fi
source $HOME/.gvm/scripts/gvm

sudo apt -y install golang
export GOROOT_BOOTSTRAP=/usr/lib/go
gvm install go1.15.0
gvm use go1.15.0 --default

sudo apt -y install tmux
sudo apt -y autoremove
