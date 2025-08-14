# Config variables
GIT_REPOS_ROOT_FOLDER = ~/git/
GIT_THIRD_PARTY_FOLDER = ${GIT_REPOS_ROOT_FOLDER}third-party/

# versions
COC_NODE_VERSION=v12.6.0
ASDF_VERSION=v0.13.1
GO_VERSION=1.12.5

# snippets
INSTALL = sudo apt install -y
INSTALL_LOCAL= sudo dpkg -i
SNAP_INSTALL = sudo snap install
UPDATE = sudo apt update
ADD_REPOSITORY= sudo add-apt-repository -y
DOWNLOAD_AS=wget -O
AT_TEMP_FOLDER=cd /tmp/ ;






# all: desktop-environment link-all

all: telegram entr spotify syncthing vi clipboard-tools


clipboard-tools: greenclip xclip
# DAEMONS -----------------------------------------------------
keyd:
	${ADD_REPOSITORY} ppa:keyd-team/ppa
	${UPDATE}
	${INSTALL} keyd keyd-application-mapper
	sudo systemctl enable --now keyd

greenclip:
	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} greenclip.bin https://github.com/erebe/greenclip/releases/download/3.3/greenclip
	${AT_TEMP_FOLDER} chmod +x greenclip.bin
	${AT_TEMP_FOLDER} sudo mv greenclip.bin /usr/local/bin/greenclip

syncthing:
	sudo curl -o /usr/share/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg
	echo "deb [signed-by=/usr/share/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list
	${UPDATE}
	${INSTALL} syncthing
	sudo systemctl enable syncthing@cawal.service
	sudo systemctl start syncthing@cawal.service


keepassxc:
	${ADD_REPOSITORY} ppa:phoerious/keepassxc
	${UPDATE}
	${INSTALL} keepassxc

dropbox:
	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} dropbox.deb https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2025.05.20_amd64.deb 
	# ${INSTALL} python-gtk2 libpango1.0-0
	${AT_TEMP_FOLDER} ${INSTALL_LOCAL} dropbox.deb


# GUI APPS ----------------------------------------------------
obsidian:
	sudo snap install obsidian --classic

arandr:
	${INSTALL} arandr

zotero:
	wget -qO- https://raw.githubusercontent.com/retorquere/zotero-deb/master/install.sh | sudo bash
	${UPDATE}
	${INSTALL} zotero

dbeaver:
	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} dbeaver.deb https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb
	${AT_TEMP_FOLDER} ${INSTALL_LOCAL} dbeaver.deb
	${AT_TEMP_FOLDER} rm dbeaver.deb

image-manipulation:
	${INSTALL} inkscape gimp imagemagick gpick

office-suite:
	${INSTALL} libreoffice

ktikz:
	${INSTALL} ktikz

graphviz:
	${INSTALL} graphviz


video-player:
	${INSTALL} vlc


telegram:
	${SNAP_INSTALL} telegram-desktop

spotify:
	${SNAP_INSTALL} spotify

slack:
	${SNAP_INSTALL} slack --classic

wifi-analyser:
	${INSTALL} linssid

package-files:
	${INSTALL} file-roller



calibre:
	${INSTALL} calibre

gedit:
	${INSTALL} gedit



zathura: FORCE
	${INSTALL} zathura


web-browser: firefox

firefox:
	${INSTALL} firefox

google-chrome:
	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	${AT_TEMP_FOLDER} ${INSTALL_LOCAL} google-chrome.deb

qutebrowser: FORCE
	${INSTALL} qutebrowser

homebank:
	${ADD_REPOSITORY} ppa:mdoyen/homebank
	${UPDATE}
	${INSTALL} homebank


libfuse: # for APPIMAGES # https://github.com/AppImage/AppImageKit/wiki/FUSE
	${ADD_REPOSITORY} universe
	${INSTALL} libfuse2


# TERMINAL -----------------------------------------------------
tmate:
	${INSTALL} tmate

zsh: FORCE
	${INSTALL} zsh
	chsh -s /bin/zsh
terminal:
	${INSTALL} rxvt-unicode

kitty:
	curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
	# Create symbolic links to add kitty and kitten to PATH (assuming ~/.local/bin is in
	# your system-wide PATH)
	ln -sf ~/.local/kitty.app/bin/kitty ~/.local/kitty.app/bin/kitten ~/.local/bin/
	# Place the kitty.desktop file somewhere it can be found by the OS
	cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
	# If you want to open text files and images in kitty via your file manager also add the kitty-open.desktop file
	cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/
	# Update the paths to the kitty and its icon in the kitty desktop file(s)
	sed -i "s|Icon=kitty|Icon=$(readlink -f ~)/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
	sed -i "s|Exec=kitty|Exec=$(readlink -f ~)/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop
	# Make xdg-terminal-exec (and hence desktop environments that support it use kitty)
	echo 'kitty.desktop' > ~/.config/xdg-terminals.list

tmux:
	${INSTALL} tmux
	mv ~/.tmux/ ~/tmux.bak || true

vi: ripgrep silver-seacher python3-pip3
	sudo apt remove neovim neovim-runtime
	sudo apt-get install ninja-build gettext cmake unzip curl build-essential
	${INSTALL} python3-dev python3-pip python3-neovim
	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} nvim https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
	${AT_TEMP_FOLDER} chmod u+x nvim
	sudo rm /usr/local/bin/nvim
	${AT_TEMP_FOLDER} sudo mv nvim /usr/local/bin/
	sudo update-alternatives --install /usr/bin/vi vi /usr/local/bin/nvim 1111
	sudo update-alternatives --set vi /usr/local/bin/nvim
	git config --global core.editor nvim
	# pip3 install neovim

ripgrep:
	${SNAP_INSTALL} --classic ripgrep

silver-seacher:
	${INSTALL} silversearcher-ag

xclip:
	${INSTALL} xclip

github-cli:
	(type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
		&& sudo mkdir -p -m 755 /etc/apt/keyrings \
		&& wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
		&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
		&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
		&& sudo apt update \
		&& sudo apt install gh -y

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

xdotool:
	${INSTALL} xdotool

# DEVELOPMENT TOOLS

version-control:
	${INSTALL} git

shellcheck:
	${INSTALL} shellcheck

web-service-development-tools: httpie jq tcpflow

httpie:
	${INSTALL} httpie

jq:
	${INSTALL} jq

tcpflow:
	${INSTALL} tcpflow

ppapurge:
	${INSTALL} ppa-purge

q:
	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} q.deb https://github.com/harelba/q/releases/download/v3.1.6/q-text-as-data-3.1.6-1.x86_64.deb
	${AT_TEMP_FOLDER} sudo dpkg -i q.deb

htop:
	${INSTALL} htop

sox:
	${INSTALL} sox


curl:
	${INSTALL} curl

debugging:
	# perf:
	${INSTALL} linux-tools-common linux-tools-generic linux-cloud-tools-generic

build-tools:
	${INSTALL} gpp gcc checkinstall make


markdown:
	${INSTALL} pandoc

nvm:
	mkdir -p ${HOME}/.nvm
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

node-js: nvm
	nvm install stable

gcloud:
	mv ~/bin/google-cloud-sdk ~/bin/google-cloud-sdk-old
	curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz
	tar -xf google-cloud-cli-linux-x86_64.tar.gz
	./google-cloud-sdk/install.sh
	mv google-cloud-cli ~/bin/
	rm ./google-cloud-sdk/install.sh
# WM ----------------------------------------------------
desktop-environment: qtile desktop-configuration clipboard-manager xdotool network-manager-applet

nm-applet:
	${INSTALL} network-manager-applet
rofi: FORCE
	${INSTALL} rofi unifont

wallpaper:
	${INSTALL} nitrogen


icon-themes:
	${INSTALL} numix-icon-theme

gtk-themes:
	${INSTALL} arc-theme

sound-control:
	${INSTALL} pavucontrol

clipboard-manager: greenclip rofi

desktop-configuration:
	${INSTALL} lxappearance
lockscreen:
	${INSTALL} i3lock

compositor:
	${INSTALL} compton
	${INSTALL} picom


bluetooth:
	sudo apt-get install bluetooth bluez bluez-tools rfkill blueman


notifications: dunst

dunst-install:
	${INSTALL} dunst


screenruler:
	${INSTALL} screenruler

fonts:
	${INSTALL} ubuntu-restricted-extras


screenshot:
	${INSTALL} flameshot

conky-notifications:
	${INSTALL} conky-all


#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
# --------------------------------------------------------
oh-my-zsh: pipenv
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

pipenv:
	pipx install pipenv

docker:
	$(if $(shell which docker),$(error "Docker already installed"),)
	${INSTALL} docker-compose-v2
	sudo usermod -aG docker `whoami`


docker-remove-image-cache:
	docker builder prune


# DESKTOP EXPERIENCE


qtile: lockscreen qtile-dependencies FORCE
	pip3 install 'qtile[widgets]'
	cd ${GIT_THIRD_PARTY_FOLDER}; rm -rf qtile; git clone https://github.com/qtile/qtile.git; cd qtile; git checkout v0.32.0; sudo pip3 install .
	sudo wget --output-document /usr/share/xsessions/qtile.desktop https://raw.githubusercontent.com/qtile/qtile/master/resources/qtile.desktop

qtile-dependencies: pipx
	${INSTALL} python3-cffi python3-cairocffi libpangocairo-1.0-0 python3-xcffib python3-dbus-fast libwlroots-dev libiw-dev
	pipx install mypy
	# pip3 install --no-cache cairo-cffi
	# pip3 install dbus-next


pipx:
	sudo apt install pipx
	pipx ensurepath

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




drivers:
	${INSTALL} bcmwl-kernel-source



# TERMINAL TOOLS

python3-pip3:
	${INSTALL} python3-pip

sc-im: libxlsxwriter
	${INSTALL} bison libncurses5-dev libncursesw5-dev libxml2-dev libzip-dev
	${AT_TEMP_FOLDER} git clone https://github.com/andmarti1424/sc-im.git
	${AT_TEMP_FOLDER} cd sc-im/src; make && sudo make install

libxlsxwriter:
	${AT_TEMP_FOLDER} git clone https://github.com/jmcnamara/libxlsxwriter.git
	${AT_TEMP_FOLDER} cd libxlsxwriter; make && sudo make install
	sudo ldconfig



insomnia:
	echo "deb https://dl.bintray.com/getinsomnia/Insomnia /" | sudo tee -a /etc/apt/sources.list.d/insomnia.list
	wget --quiet -O - https://insomnia.rest/keys/debian-public.key.asc | sudo apt-key add -
	${UPDATE}
	${INSTALL} insomnia


intellij-idea:
	snap install intellij-idea-community

sdkman:
	curl -s https://get.sdkman.io | bash

kotlinc:
	sdk install kotlin



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

latex:
	${INSTALL} texlive-latex-base texlive-latex-extra texlive-humanities texlive-xetex texlive-publishers biber bibtool texlive-fonts-recommended texlive-latex-extra texlive-lang-portuguese latexmk

beamer-theme-metropolis: latex
	${AT_TEMP_FOLDER}  git clone https://github.com/matze/mtheme.git
	${AT_TEMP_FOLDER}  cd mtheme; make sty && make install

# Others -------------------------------------------------


audacity:
	${INSTALL} audacity

baobab:
	${INSTALL} baobab



steam: graphic-drivers
	${INSTALL} python-apt
	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} steam.deb https://steamcdn-a.akamaihd.net/client/installer/steam.deb
	${AT_TEMP_FOLDER} ${INSTALL_LOCAL} steam.deb

graphic-drivers:
	 ${INSTALL} libvulkan1 mesa-vulkan-drivers vulkan-utils



bb: bb-dependencies
	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} warsaw.deb https://cloud.gastecnologia.com.br/bb/downloads/ws/warsaw_setup64.deb
	${AT_TEMP_FOLDER} ${INSTALL_LOCAL} warsaw.deb

bb-dependencies:
	${INSTALL} openssl libnss3-tools libcurl3 dbus libdbus-1-3 python-openssl







# stow all configuration files ------------------------------------------

link-all: stow link-bin link-conky link-login-shell link-neovim link-ranger link-rofi link-tmux link-xresources link-urxvt link-zsh link-zathura

stow:
	${INSTALL} stow

link-bin:
	stow -R bin --target=${HOME}/bin/

link-conky:
	stow -R conky --target=${HOME}

link-dunst:
	mkdir -p "${HOME}/.config/dunst/"
	stow -R dunst --target=${HOME}/.config/dunst/

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
	sudo mkdir -p /etc/keyd/
	sudo stow -R keyd_default --target=/etc/keyd/
	mkdir -p ${HOME}/.config/keyd/
	stow -R keyd_app --target=${HOME}/.config/keyd/



FORCE:
