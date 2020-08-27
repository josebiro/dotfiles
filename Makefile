.PHONY: all system env kubernetes git bashit brainy-k8s vimrc dotfiles bison docker ansible gvm

all: system env kubernetes

# Utils
JSON_GET_VALUE = grep $1 | head -n 1 | sed 's/[," ]//g' | cut -d : -f 2

# Prereq tests
gitexists=$(wildcard /usr/bin/git)
bashitexists=$(wildcard ~/.bash_it)
vimrcexists=$(wildcard ~/.vimrc)
docker=$(wildcard /usr/bin/docker)

env: git bashit brainy-k8s vimrc dotfiles tmux
system: bison docker ansible gvm

#
# System Components
#
bison:
	sudo apt install bison binutils gcc -y

docker:
ifneq ("$(docker)", "")
	@echo "docker is installed."
else
	sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
	#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -

	#sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
	sudo apt-get update
	sudo apt-get -y install docker-ce docker-ce-cli containerd.io
endif

ansible:
	sudo apt-get update
	sudo apt-get install software-properties-common
	sudo apt-add-repository --yes --update ppa:ansible/ansible
	sudo apt-get install -y ansible

gvm:
	curl -o /tmp/gvm-installer -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer
	sudo chmod 755 /tmp/gvm-installer
	/tmp/gvm-installer
	source ${HOME}/.gvm/scripts/gvm


#
# Environment Setup
#
git:
ifneq ("$(gitexists)","")
	@echo "git is installed."
else
	sudo apt install git -y
endif

bashit:
ifneq ("$(bashitexists)", "")
	@echo "bash_it is installed."
else
	-git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it
	-~/.bash_it/install.sh --silent
	sed -i 's/bobby/brainy/g' ~/.bashrc
	source ~/.bashrc
endif

vimrc:
ifneq ("$(vimrcexists)","")
	@echo "vimrc exists"
else
	git clone --recursive https://github.com/jessfraz/.vim.git ~/.vim
	ln -sf ~/.vim/vimrc ~/.vimrc
	cd ~/.vim && git submodule update --init
endif

dotfiles:
	# add aliases for dotfiles
	for file in $(shell find $(CURDIR) -name ".*" -not -name ".gitignore" -not -name ".git" -not -name ".*.swp"); do \
		f=$$(basename $$file); \
		ln -sfn $$file $(HOME)/$$f; \
	done; \
	$(HOME)/dotfiles/custom.gitconfig
	#git update-index --skip-worktree $(CURDIR)/.gitconfig;

brainy-k8s:
	ln -s ./brainy-k8s $(HOME)/.bash_it/themes/brainy-k8s
	sed -i 's/brainy/brainy-k8s/g' ~/.bashrc
	source ~/.bashrc

tmux:
	sudo apt install tmux -y
	cp .tmux.conf ${HOME}/.tmux.conf

#
# Kubernetes related tooling
#
kubernetes: k8s skaffold kubetools k9s

k8s:
	echo "Installing k8s tools."
	sudo apt-get update && sudo apt-get install -y apt-transport-https
	curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
	echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
	sudo apt-get update
	sudo apt-get install -y kubectl

skaffold:
	echo "Installing skaffold"
	curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64
	chmod +x skaffold
	sudo mv skaffold /usr/local/bin

kubetools:
	sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
	sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
	sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
	sudo git clone https://github.com/jonmosco/kube-ps1.git /opt/kube-ps1
	sudo ln -s /opt/kube-ps1/kube-ps1.sh /usr/local/bin/kube-ps1
	sudo chmod 755 /usr/local/bin/kube-ps1
	sudo chmod 755 /usr/local/bin/kubectx
	sudo chmod 755 /usr/local/bin/kubens

k9s:
	bin/update-k9s.sh

kustomize:
	curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
	sudo mv kustomize /usr/local/bin

kubeps-tmux:
	git clone https://github.com/jonmosco/kube-tmux.git ~/.tmux

brew:
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
	sudo apt-get install build-essentia
	echo 'eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)' >>~/.bash_profile

vscode:
	wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
	sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
	sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
	sudo apt-get install apt-transport-https
	sudo apt-get update
	sudo apt-get install code