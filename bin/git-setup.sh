#!/bin/bash

if [ ! -f $HOME/.gitconfig ]; then
  echo -n "Full name (for git): "
  read NAME
  echo -n "Email (for git): "
  read EMAIL
  # configure git in case I've forgotten to do it
  git config --global user.name "${NAME}"
  git config --global user.email "${EMAIL}"
fi
