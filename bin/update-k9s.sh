#!/bin/bash

USER=derailed
REPO=k9s

pushd /tmp/

curl -sL https://api.github.com/repos/${USER}/${REPO}/releases/latest \
	| jq -r '.assets[].browser_download_url' \
	| grep "Linux_x86_64" \
	| wget -qi -

tarball="$(find . -name "*Linux_x86_64.tar.gz")"
tar -xzf $tarball

chmod +x k9s

sudo mv k9s /usr/local/bin/

popd

location="$(which k9s)"
echo "k9s binary location: $location"

version="$(k9s version)"
echo "k9s binary version: $version"
