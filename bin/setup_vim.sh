#!/bin/bash

cd $HOME

git clone --recursive https://github.com/jessfraz/.vim.git .vim
ln -sf $HOME/.vim/vimrc $HOME/.vimrc
cd $HOME/.vim
git submodule update --init
