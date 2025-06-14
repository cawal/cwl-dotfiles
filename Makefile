GIT_REPOS_ROOT_FOLDER = ~/git/
GIT_THIRD_PARTY_FOLDER = ${GIT_REPOS_ROOT_FOLDER}third-party/
INSTALL = sudo apt install -y
INSTALL_LOCAL= sudo dpkg -i
SNAP_INSTALL = sudo snap install
UPDATE = sudo apt update
ADD_REPOSITORY= sudo add-apt-repository -y
DOWNLOAD_AS=wget -O
AT_TEMP_FOLDER=cd /tmp/ ;




COC_NODE_VERSION=v12.6.0
ASDF_VERSION=v0.13.1
GO_VERSION=1.12.5


# all: desktop-environment link-all

all: telegram entr spotify syncthing vi clipboard-tools aws-cli

flashfocus:
	${INSTALL} libxcb-render0-dev libffi-dev python3-dev python3-cffi python3-pip
	pip install flashfocus

aws-cli:
	# depends on glibc groff less
	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} awscliv2.zip "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"; unzip awscliv2.zip; sudo ./aws/install


arandr:
	${INSTALL} arandr

keyd:
	${ADD_REPOSITORY} ppa:keyd-team/ppa
	${UPDATE}
	${INSTALL} keyd keyd-application-mapper
	sudo systemctl enable --now keyd


tmate:
	${INSTALL} tmate

zsh: FORCE
	${INSTALL} zsh
	chsh -s /bin/zsh

oh-my-zsh: pipenv
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

pipenv:
	pip3 install pipenv

greenclip:
	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} greenclip.bin https://github.com/erebe/greenclip/releases/download/3.3/greenclip
	${AT_TEMP_FOLDER} chmod +x greenclip.bin
	${AT_TEMP_FOLDER} sudo mv greenclip.bin /usr/local/bin/greenclip

terminal:
	${INSTALL} rxvt-unicode


rofi: FORCE
	${INSTALL} rofi unifont

vi: ripgrep silver-seacher python3-pip3
	sudo apt remove neovim neovim-runtime
	sudo apt-get install ninja-build gettext cmake unzip curl build-essential
	${AT_TEMP_FOLDER} git clone https://github.com/neovim/neovim
	${AT_TEMP_FOLDER} cd neovim && git checkout stable && make CMAKE_BUILD_TYPE=RelWithDebInfo
	${AT_TEMP_FOLDER} cd neovim/build && cpack -G DEB && sudo dpkg -i nvim-linux64.deb
	${INSTALL} python3-neovim
	git config --global core.editor nvim
	# pip3 install neovim

ripgrep:
	${SNAP_INSTALL} --classic ripgrep

silver-seacher:
	${INSTALL} silversearcher-ag

#python3-pynvim: python3-pip3
#	cd ~; python3 -m venv .neovim_venv
#	cd ~/.neovim_venv; source .bin/activate; pip install pynvim

clipboard-tools: greenclip
	${INSTALL} xclip

go: asdf-golang
	asdf install golang "${GO_VERSION}"
	asdf global golang "${GO_VERSION}"


asdf: # https://asdf-vm.com/guide/getting-started.html
	git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch "${ASDF_VERSION}"

asdf-golang: asdf # https://github.com/asdf-community/asdf-golang
	asdf plugin add golang https://github.com/asdf-community/asdf-golang.git


github-cli:
	(type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
		&& sudo mkdir -p -m 755 /etc/apt/keyrings \
		&& wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
		&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
		&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
		&& sudo apt update \
		&& sudo apt install gh -y

wallpaper:
	${INSTALL} nitrogen


icon-themes:
	${INSTALL} numix-icon-theme

gtk-themes:
	${INSTALL} arc-theme

sound-control:
	${INSTALL} pavucontrol



docker: docker-ce-edge docker-compose

docker-ce-edge:
	$(if $(shell which docker),$(error "Docker already installed"),)
	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} get-docker.sh https://get.docker.com
	${AT_TEMP_FOLDER} sh get-docker.sh
	sudo usermod -aG docker `whoami`

docker-compose:
	sudo curl -L "https://github.com/docker/compose/releases/download/1.28.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose

docker-remove-image-cache:
	docker builder prune

libfuse: # for APPIMAGES # https://github.com/AppImage/AppImageKit/wiki/FUSE
	sudo add-apt-repository universe
	sudo apt install libfuse2

liber: liber-vpn

liber-vpn: # https://liber.atlassian.net/wiki/spaces/SRE/pages/6952747080/Instala+o+Linux
	${INSTALL} wireguard


liber-backup:
	mkdir ${HOME}/backup/
	sudo cp /etc/wireguard ${HOME}/backup/etc/wireguard
	mkdir -p ${HOME}/backup/home/cawal
	cp ${HOME}/.gitconfig ${HOME}/.gitcredentials




# DESKTOP EXPERIENCE
desktop-environment: qtile flashfocus desktop-configuration clipboard-manager xdotool

clipboard-manager: greenclip rofi

desktop-configuration: arandr
	${INSTALL} lxappearance

qtile: lockscreen qtile-dependencies FORCE
	pip install qtile
	# cd ${GIT_THIRD_PARTY_FOLDER}; rm -rf qtile; git clone https://github.com/qtile/qtile.git; cd qtile; sudo pip3 install .
	sudo wget --output-document /usr/share/xsessions/qtile.desktop https://raw.githubusercontent.com/qtile/qtile/master/resources/qtile.desktop

qtile-dependencies:
	${INSTALL} python3-cffi python3-cairocffi libpangocairo-1.0-0 python3-xcffib
	pip3 install --no-cache cairo-cffi
	pip3 install dbus-next

lockscreen:
	${INSTALL} i3lock

## I3 --------------------------
i3: notifications i3-bar rofi wallpaper compositor i3ipc
	#${AT_TEMP_FOLDER} /usr/lib/apt/apt-helper download-file http://debian.sur5r.net/i3/pool/main/s/sur5r-keyring/sur5r-keyring_2019.02.01_all.deb keyring.deb SHA256:176af52de1a976f103f9809920d80d02411ac5e763f695327de9fa6aff23f416
	#${AT_TEMP_FOLDER} ${INSTALL_LOCAL} ./keyring.deb
	#${AT_TEMP_FOLDER} echo "deb http://debian.sur5r.net/i3/ $(grep '^DISTRIB_CODENAME=' /etc/lsb-release | cut -f2 -d=) universe" >> /etc/apt/sources.list.d/sur5r-i3.list
	${UPDATE}
	${INSTALL} i3

i3-bar: py3status i3-python

i3ipc:
	pip3 install i3ipc

i3-python:
	${INSTALL} python3-tz python3-tzlocal

py3status:
	${INSTALL} py3status

## I3: END ---------------------


xmonad:
	${INSTALL} xmonad libghc-xmonad-contrib-dev xmobar

alluvium:
	${INSTALL} libcairo2-dev libgirepository1.0-dev
	pip3 install alluvium

compositor:
	${INSTALL} compton


bluetooth:
	sudo apt-get install bluetooth bluez bluez-tools rfkill blueman


#diodon:
#	${INSTALL} diodon

notifications: dunst

dunst-install:
	${INSTALL} dunst

kitty:
	curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
	cd ~/bin; ln -s ~/.local/kitty.app/bin/kitten; ln -s ~/.local/kitty.app/bin/kitty
	# Create symbolic links to add kitty and kitten to PATH (assuming ~/.local/bin is in
	# your system-wide PATH)
	ln -sf ~/.local/kitty.app/bin/kitty ~/.local/kitty.app/bin/kitten ~/.local/bin/
	# Place the kitty.desktop file somewhere it can be found by the OS
	cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
	# If you want to open text files and images in kitty via your file manager also add the kitty-open.desktop file
	cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/
	# Update the paths to the kitty and its icon in the kitty.desktop file(s)
	sed -i "s|Icon=kitty|Icon=/home/$USER/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
	sed -i "s|Exec=kitty|Exec=/home/$USER/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop



drivers:
	${INSTALL} bcmwl-kernel-source


conky-notifications:
	${INSTALL} conky-all



# TERMINAL TOOLS

coc-node:
	nvm install "${COC_NODE_VERSION}"

python3-pip3:
	${INSTALL} python3-pip

ranger-install:
	${INSTALL} ranger


# tools for editing CSV files
csvkit:
	${INSTALL} csvkit

# count lines of codes
cloc:
	${INSTALL} cloc

entr:
	${INSTALL} entr

cli-administration: osquery ppapurge

ppapurge:
	${INSTALL} ppa-purge

osquery:
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1484120AC4E9F8A1A577AEEE97A80C63C9D8B80B
	${ADD_REPOSITORY} 'deb [arch=amd64] https://pkg.osquery.io/deb deb main'
	${UPDATE}
	${INSTALL} osquery


q:
	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} q.deb https://github.com/harelba/q/releases/download/v3.1.6/q-text-as-data-3.1.6-1.x86_64.deb
	${AT_TEMP_FOLDER} sudo dpkg -i q.deb

htop:
	${INSTALL} htop

sc-im: libxlsxwriter
	${INSTALL} bison libncurses5-dev libncursesw5-dev libxml2-dev libzip-dev
	${AT_TEMP_FOLDER} git clone https://github.com/andmarti1424/sc-im.git
	${AT_TEMP_FOLDER} cd sc-im/src; make && sudo make install

libxlsxwriter:
	${AT_TEMP_FOLDER} git clone https://github.com/jmcnamara/libxlsxwriter.git
	${AT_TEMP_FOLDER} cd libxlsxwriter; make && sudo make install
	sudo ldconfig

sox:
	${INSTALL} sox

xdotool:
	${INSTALL} xdotool

# DEVELOPMENT TOOLS

version-control:
	${INSTALL} git mercurial mercurial-git subversion

shellcheck:
	${INSTALL} shellcheck

web-service-development-tools: httpie jq tcpflow

httpie:
	${INSTALL} httpie

jq:
	${INSTALL} jq

tcpflow:
	${INSTALL} tcpflow

web-development:
	${INSTALL} jekyll

insomnia:
	echo "deb https://dl.bintray.com/getinsomnia/Insomnia /" | sudo tee -a /etc/apt/sources.list.d/insomnia.list
	wget --quiet -O - https://insomnia.rest/keys/debian-public.key.asc | sudo apt-key add -
	${UPDATE}
	${INSTALL} insomnia

insomnia-designer:
	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} insomnia-designer.deb "https://updates.insomnia.rest/downloads/ubuntu/latest?ref=&app=com.insomnia.designer&source=website"
	${AT_TEMP_FOLDER} ${INSTALL_LOCAL} insomnia-designer.deb

debugging:
	# perf:
	${INSTALL} linux-tools-common linux-tools-generic linux-cloud-tools-generic

build-tools:
	${INSTALL} maven gradle gpp ant checkinstall make

intellij-idea:
	snap install intellij-idea-community

sdkman:
	curl -s https://get.sdkman.io | bash

kotlinc:
	sdk install kotlin

nvm:
	mkdir -p ${HOME}/.nvm
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash

node-js: nvm
	nvm install stable

oracle-java-8:
	${ADD_REPOSITORY} ppa:webupd8team/java
	${UPDATE}
	${INSTALL} oracle-java8-installer

oracle-java-10:
	${ADD_REPOSITORY} ppa:linuxuprising/java
	${UPDATE}
	${INSTALL} oracle-java10-installer

openjdk-11:
	${INSTALL} openjdk-11-jdk

openjdk-8:
	${INSTALL} openjdk-8-jdk icedtea-8-plugin

kotlin-compiler:
	snap install --classic kotlin

curl:
	${INSTALL} curl

dbeaver:
	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} dbeaver.deb https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb
	${AT_TEMP_FOLDER} ${INSTALL_LOCAL} dbeaver.deb
	${AT_TEMP_FOLDER} rm dbeaver.deb


mssql-tools:
	curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
	curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | sudo tee /etc/apt/sources.list.d/msprod.list
	${UPDATE}
	${INSTALL}  mssql-tools unixodbc-dev




# LANGUAGE SERVERS -----------------------------------------------------
language-servers: ls-bash ls-typescript

# https://github.com/mads-hartmann/bash-language-server
ls-bash:
	npm i -g bash-language-server

# https://github.com/theia-ide/typescript-language-server
ls-typescript:
	npm install -g typescript-language-server
	npm install -g typescript


# Writing tools --------------------------------------------------------
image-manipulation:
	${INSTALL} inkscape gimp imagemagick gpick

zotero:
	wget -qO- https://raw.githubusercontent.com/retorquere/zotero-deb/master/install.sh | sudo bash
	${UPDATE}
	${INSTALL} zotero

mendeley:
	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} mendeleydesktop.deb https://www.mendeley.com/repositories/ubuntu/stable/amd64/mendeleydesktop-latest
	${INSTALL} libqtwebkit4 gconf2
	${AT_TEMP_FOLDER} ${INSTALL_LOCAL} mendeleydesktop.deb

jabref-dependencies: openjdk-8
	${INSTALL} openjfx


writing: latex markdown office-suite gedit graphviz zathura

zathura: FORCE
	${INSTALL} zathura

markdown:
	${INSTALL} pandoc


latex:
	${INSTALL} texlive-latex-base texlive-latex-extra texlive-humanities texlive-xetex texlive-publishers biber bibtool texlive-fonts-recommended texlive-latex-extra texlive-lang-portuguese latexmk

beamer-theme-metropolis: latex
	${AT_TEMP_FOLDER}  git clone https://github.com/matze/mtheme.git
	${AT_TEMP_FOLDER}  cd mtheme; make sty && make install

office-suite:
	${INSTALL} libreoffice

ktikz:
	${INSTALL} ktikz

makefile2dot: graphviz
	pip3 install --user makefile2dot

graphviz:
	${INSTALL} graphviz

screenruler:
	${INSTALL} screenruler

fonts:
	${INSTALL} ubuntu-restricted-extras

# Others -------------------------------------------------


audacity:
	${INSTALL} audacity

baobab:
	${INSTALL} baobab


web-browser: firefox

firefox:
	sudo add-apt-repository ppa:mozillateam/ppa
	sudo snap remove firefox
	sudo cp apt/preferences.d/mozilla-firefox /etc/apt/preferences.d/
	${UPDATE}
	${INSTALL} firefox

qutebrowser: FORCE
	${INSTALL} qutebrowser

steam: graphic-drivers
	${INSTALL} python-apt
	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} steam.deb https://steamcdn-a.akamaihd.net/client/installer/steam.deb
	${AT_TEMP_FOLDER} ${INSTALL_LOCAL} steam.deb

graphic-drivers:
	 ${INSTALL} libvulkan1 mesa-vulkan-drivers vulkan-utils

google-chrome:
	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	${AT_TEMP_FOLDER} ${INSTALL_LOCAL} google-chrome.deb


bb: bb-dependencies
	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} warsaw.deb https://cloud.gastecnologia.com.br/bb/downloads/ws/warsaw_setup64.deb
	${AT_TEMP_FOLDER} ${INSTALL_LOCAL} warsaw.deb

bb-dependencies:
	${INSTALL} openssl libnss3-tools libcurl3 dbus libdbus-1-3 python-openssl

homebank:
	${ADD_REPOSITORY} ppa:mdoyen/homebank
	${UPDATE}
	${INSTALL} homebank

wifi-analyser:
	${INSTALL} linssid


telegram:
	sudo snap install telegram-desktop

slack:
	snap install slack --classic


dropbox:
	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} dropbox.deb https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2015.10.28_amd64.deb
	${INSTALL} python-gtk2 libpango1.0-0
	${AT_TEMP_FOLDER} ${INSTALL_LOCAL} dropbox.deb

package-files:
	${INSTALL} file-roller


video-player:
	${INSTALL} vlc

keepassxc:
	${ADD_REPOSITORY} ppa:phoerious/keepassxc
	${UPDATE}
	${INSTALL} keepassxc



calibre:
	${INSTALL} calibre

gedit:
	${INSTALL} gedit


screenshot:
	${INSTALL} flameshot

autokey:
	${ADD_REPOSITORY} ppa:sporkwitch/autokey
	${UPDATE}
	${INSTALL} autokey-gtk

syncthing:
	sudo curl -o /usr/share/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg
	echo "deb [signed-by=/usr/share/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list
	${UPDATE}
	${INSTALL} syncthing

spotify:
	sudo snap install spotify



# stow all configuration files ------------------------------------------

link-all: stow link-bin link-conky link-gtk3 link-login-shell link-neovim link-ranger link-rofi link-tmux link-xresources link-urxvt link-zsh link-zathura

stow:
	${INSTALL} stow

link-bin:
	stow -R bin --target=${HOME}/bin/

link-conky:
	stow -R conky --target=${HOME}

link-dunst:
	mkdir -p "${HOME}/.config/dunst/"
	stow -R dunst --target=${HOME}/.config/dunst/

link-gtk3:
	mkdir -p ${HOME}/.config/gtk-3.0
	stow -R gtk-3.0 --target=${HOME}/.config/gtk-3.0

link-i3:
	stow -R i3 --target=${HOME}/.config

link-login-shell:
	stow -R login-shell --target=${HOME}

link-neovim:
	mkdir -p ${HOME}/.local/share/nvim/site/autoload/
	cd neovim; stow -R autoload --target=${HOME}/.local/share/nvim/site/autoload/
	mkdir -p ${HOME}/.config/nvim/
	cd neovim; stow -R config --target=${HOME}/.config/nvim/

link-ranger:
	mkdir -p ${HOME}/.config/ranger
	stow -R ranger --target=${HOME}/.config/ranger

link-rofi:
	mkdir -p ${HOME}/.config/rofi/
	stow -R rofi --target=${HOME}/.config/rofi/

link-tmux:
	stow -R tmux --target=${HOME}

link-xmodmap:
	stow -R xmodmap --target=${HOME}
	xmodmap ${HOME}/.Xmodmap

link-xresources:
	stow -R Xresources --target=${HOME}
	xrdb ${HOME}/.Xresources


link-qtile:
	mkdir -p ${HOME}/.config/
	stow -R qtile --target=${HOME}/.config/

link-qutebrowser:
	mkdir -p ${HOME}/.config/qutebrowser/
	stow -R qutebrowser --target=${HOME}/.config/qutebrowser/

link-urxvt:
	mkdir -p ${HOME}/.urxvt/
	stow -R urxvt --target=${HOME}/.urxvt/

link-zsh:
	stow -R zsh --target=${HOME}

link-zathura:
	mkdir -p ${HOME}/.config/zathura/
	stow -R zathura --target=${HOME}/.config/zathura/

link-keyd:
	sudo stow -R keyd_default --target=/etc/keyd/
	mkdir -p ${HOME}/.config/keyd/
	stow -R keyd_app --target=${HOME}/.config/keyd/



FORCE:
