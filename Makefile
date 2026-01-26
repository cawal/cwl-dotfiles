# ============================================================================
# CWL Dotfiles Makefile - Organized by Category
# ============================================================================

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

# ============================================================================
# HELP AND MAIN TARGETS
# ============================================================================

.PHONY: help
help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Category Targets:'
	@echo '  core-system        Install essential system tools'
	@echo '  desktop-env        Install desktop environment components'
	@echo '  terminal-env       Install terminal and shell environment'
	@echo '  development        Install development tools and languages'
	@echo '  communication      Install browsers, chat, and productivity apps'
	@echo '  media-creative     Install media and creative tools'
	@echo '  utilities          Install file management and utility tools'
	@echo '  academic-docs      Install academic and documentation tools'
	@echo '  configure          Link all configuration files'
	@echo ''
	@echo 'Main Targets:'
	@echo '  all               Install current default selection'
	@echo '  minimal           Install minimal essential setup'
	@echo '  desktop-full      Install complete desktop environment'
	@echo '  install-packages  Install all packages without config'
	@echo ''

# Main legacy target (preserved)
all: telegram entr spotify syncthing vi clipboard-tools

# Category-based installation targets
core-system: keyd curl htop version-control stow drivers network-manager-applet

desktop-env: qtile i3 rofi compositor wallpaper icon-themes gtk-themes lockscreen notifications

terminal-env: zsh tmux kitty terminal tmate

development: vi node-js docker github-cli build-tools shellcheck web-service-development-tools language-servers

communication: firefox telegram slack office-suite

media-creative: video-player audacity image-manipulation graphviz

utilities: ranger-install xclip csvkit cloc entr xdotool

academic-docs: latex zathura zotero calibre

# Comprehensive installation
desktop-full: core-system desktop-env terminal-env development communication media-creative utilities academic-docs configure

minimal: keyd configure firefox vi zsh qtile

install-packages: core-system desktop-env terminal-env development communication media-creative utilities academic-docs
	sudo apt autoremove

# ============================================================================
# CORE SYSTEM TOOLS
# ============================================================================

# DAEMONS AND SYSTEM SERVICES
keyd:
	${ADD_REPOSITORY} ppa:keyd-team/ppa
	${UPDATE}
	${INSTALL} keyd keyd-application-mapper
	sudo systemctl enable --now keyd

keyd-restart:
	sudo systemctl restart keyd

syncthing:
	sudo curl -o /usr/share/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg
	echo "deb [signed-by=/usr/share/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list
	${UPDATE}
	${INSTALL} syncthing
	sudo systemctl enable syncthing@cawal.service
	sudo systemctl start syncthing@cawal.service

# ESSENTIAL TOOLS
curl:
	${INSTALL} curl

htop:
	${INSTALL} htop

version-control:
	${INSTALL} git

stow:
	${INSTALL} stow

drivers:
	${INSTALL} bcmwl-kernel-source


xclip:
	${INSTALL} xclip

dysk: # df alternative
	${INSTALL} dysk

# NETWORK AND SECURITY


network-manager-applet:
	${INSTALL} network-manager-applet

nm-applet:
	${INSTALL} network-manager-applet

bluetooth:
	sudo apt-get install bluetooth bluez bluez-tools rfkill blueman

# ============================================================================
# DESKTOP ENVIRONMENT
# ============================================================================

# WINDOW MANAGERS
desktop-environment: qtile desktop-configuration clipboard-manager xdotool network-manager-applet

qtile: lockscreen qtile-dependencies FORCE
	pip3 install 'qtile[widgets]'
	cd ${GIT_THIRD_PARTY_FOLDER}; rm -rf qtile; git clone https://github.com/qtile/qtile.git; cd qtile; git checkout v0.32.0; sudo pip3 install .
	sudo wget --output-document /usr/share/xsessions/qtile.desktop https://raw.githubusercontent.com/qtile/qtile/master/resources/qtile.desktop

qtile-dependencies: pipx
	${INSTALL} python3-cffi python3-cairocffi libpangocairo-1.0-0 python3-xcffib python3-dbus-fast libwlroots-dev libiw-dev
	pipx install mypy

i3: notifications i3-bar rofi wallpaper compositor i3ipc
	${UPDATE}
	${INSTALL} i3

i3-bar: py3status i3-python

i3ipc:
	pip3 install i3ipc

i3-python:
	${INSTALL} python3-tz python3-tzlocal

py3status:
	${INSTALL} py3status



# DESKTOP COMPONENTS
rofi: FORCE
	${INSTALL} rofi unifont

compositor:
	${INSTALL} compton
	${INSTALL} picom

wallpaper:
	${INSTALL} nitrogen



# THEMING
icon-themes:
	${INSTALL} numix-icon-theme

gtk-themes:
	${INSTALL} arc-theme

fonts:
	${INSTALL} ubuntu-restricted-extras

# DESKTOP UTILITIES
lockscreen:
	${INSTALL} i3lock

notifications: dunst-install

dunst-install:
	${INSTALL} dunst

desktop-configuration:
	${INSTALL} lxappearance

sound-control:
	${INSTALL} pavucontrol

screenshot:
	${INSTALL} flameshot

screenruler:
	${INSTALL} screenruler

conky-notifications:
	${INSTALL} conky-all

# CLIPBOARD
clipboard-tools: greenclip xclip

clipboard-manager: greenclip rofi

greenclip:
	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} greenclip.bin https://github.com/erebe/greenclip/releases/download/3.3/greenclip
	${AT_TEMP_FOLDER} chmod +x greenclip.bin
	${AT_TEMP_FOLDER} sudo mv greenclip.bin /usr/local/bin/greenclip

# ============================================================================
# TERMINAL ENVIRONMENT
# ============================================================================

# SHELLS
zsh: FORCE
	${INSTALL} zsh
	chsh -s /bin/zsh

oh-my-zsh: pipenv
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# TERMINAL EMULATORS
terminal: kitty
	${INSTALL} rxvt-unicode

kitty:
	curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
	ln -sf ~/.local/kitty.app/bin/kitty ~/.local/kitty.app/bin/kitten ~/.local/bin/
	cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
	cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/
	sed -i "s|Icon=kitty|Icon=$(readlink -f ~)/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
	sed -i "s|Exec=kitty|Exec=$(readlink -f ~)/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop
	echo 'kitty.desktop' > ~/.config/xdg-terminals.list



# TERMINAL TOOLS
tmux:
	${INSTALL} tmux
	mv ~/.tmux/ ~/tmux.bak || true

tmate:
	${INSTALL} tmate


# ============================================================================
# DEVELOPMENT TOOLS
# ============================================================================

# EDITORS
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



# SEARCH TOOLS
ripgrep:
	${SNAP_INSTALL} --classic ripgrep

silver-seacher:
	${INSTALL} silversearcher-ag

# LANGUAGES AND RUNTIMES
nvm:
	mkdir -p ${HOME}/.nvm
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

node-js: nvm
	nvm install stable

python-virtualenvwrapper:
	pipx install virtualenvwrapper


python3-pip3:
	${INSTALL} python3-pip

pipenv:
	pipx install pipenv

pipx:
	sudo apt install pipx
	pipx ensurepath


homebrew:
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	#echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/cawal/.zshrc
	sudo apt-get install build-essential

# CONTAINERIZATION
docker:
	$(if $(shell which docker),$(error "Docker already installed"),)
	${INSTALL} docker-compose-v2
	sudo usermod -aG docker `whoami`

docker-remove-image-cache:
	docker builder prune

# BUILD TOOLS
build-tools:
	${INSTALL} gpp gcc checkinstall make

debugging:
	${INSTALL} linux-tools-common linux-tools-generic linux-cloud-tools-generic

# VERSION CONTROL
github-cli:
	(type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
		&& sudo mkdir -p -m 755 /etc/apt/keyrings \
		&& wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
		&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
		&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
		&& sudo apt update \
		&& sudo apt install gh -y

github-copilot-cli:
	(type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) \
	&& sudo mkdir -p -m 755 /etc/apt/keyrings \
	&& out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
	&& cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& sudo mkdir -p -m 755 /etc/apt/sources.list.d \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -y

# CODE QUALITY
shellcheck:
	${INSTALL} shellcheck

# WEB DEVELOPMENT
web-service-development-tools: httpie jq tcpflow

httpie:
	${INSTALL} httpie

jq:
	${INSTALL} jq

tcpflow:
	${INSTALL} tcpflow

# LANGUAGE SERVERS
language-servers: ls-bash ls-typescript

ls-bash:
	npm i -g bash-language-server

ls-typescript:
	npm install -g typescript-language-server
	npm install -g typescript

# CLOUD TOOLS
gcloud:
	mv ~/bin/google-cloud-sdk ~/bin/google-cloud-sdk-old
	curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz
	tar -xf google-cloud-cli-linux-x86_64.tar.gz
	./google-cloud-sdk/install.sh
	mv google-cloud-cli ~/bin/
	rm ./google-cloud-sdk/install.sh

# AI TOOLS
opencode-install:
	 npm install -g opencode-ai 

# SDK MANAGEMENT
sdkman:
	curl -s https://get.sdkman.io | bash

kotlinc:
	sdk install kotlin

# IDES
intellij-idea:
	snap install intellij-idea-community

insomnia:
	echo "deb https://dl.bintray.com/getinsomnia/Insomnia /" | sudo tee -a /etc/apt/sources.list.d/insomnia.list
	wget --quiet -O - https://insomnia.rest/keys/debian-public.key.asc | sudo apt-key add -
	${UPDATE}
	${INSTALL} insomnia

# DATABASE TOOLS
dbeaver:
	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} dbeaver.deb https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb
	${AT_TEMP_FOLDER} ${INSTALL_LOCAL} dbeaver.deb
	${AT_TEMP_FOLDER} rm dbeaver.deb

mssql-tools:
	curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
	curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | sudo tee /etc/apt/sources.list.d/msprod.list
	${UPDATE}
	${INSTALL}  mssql-tools unixodbc-dev



# ============================================================================
# COMMUNICATION AND PRODUCTIVITY
# ============================================================================

# BROWSERS
web-browser: firefox

firefox:
	${INSTALL} firefox
google-chrome:
	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	${AT_TEMP_FOLDER} ${INSTALL_LOCAL} google-chrome.deb

qutebrowser: FORCE
	${INSTALL} qutebrowser

# COMMUNICATION
telegram:
	${SNAP_INSTALL} telegram-desktop

slack:
	${SNAP_INSTALL} slack --classic



# PRODUCTIVITY
office-suite:
	${INSTALL} libreoffice


keepassxc:
	${ADD_REPOSITORY} ppa:phoerious/keepassxc
	${UPDATE}
	${INSTALL} keepassxc

obsidian:
	sudo snap install obsidian --classic

# CLOUD STORAGE
dropbox:
	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} dropbox.deb https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2025.05.20_amd64.deb 
	${AT_TEMP_FOLDER} ${INSTALL_LOCAL} dropbox.deb

# FINANCE
homebank:
	${ADD_REPOSITORY} ppa:mdoyen/homebank
	${UPDATE}
	${INSTALL} homebank

# ============================================================================
# MEDIA AND CREATIVE TOOLS
# ============================================================================

# VIDEO
video-player:
	${INSTALL} vlc





# AUDIO
audacity:
	${INSTALL} audacity

sox:
	${INSTALL} sox

spotify:
	${SNAP_INSTALL} spotify

# GRAPHICS
image-manipulation:
	${INSTALL} inkscape gimp imagemagick gpick



# VISUALIZATION
graphviz:
	${INSTALL} graphviz

ktikz:
	${INSTALL} ktikz

# READING
calibre:
	${INSTALL} calibre

# GAMING
steam: graphic-drivers
	${INSTALL} python-apt
	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} steam.deb https://steamcdn-a.akamaihd.net/client/installer/steam.deb
	${AT_TEMP_FOLDER} ${INSTALL_LOCAL} steam.deb

graphic-drivers:
	 ${INSTALL} libvulkan1 mesa-vulkan-drivers vulkan-utils

# ============================================================================
# UTILITIES
# ============================================================================

# FILE MANAGEMENT
ranger-install:
	${INSTALL} ranger



package-files:
	${INSTALL} file-roller

# SYSTEM UTILITIES
arandr:
	${INSTALL} arandr

baobab:
	${INSTALL} baobab

# DATA PROCESSING
csvkit:
	${INSTALL} csvkit

cloc:
	${INSTALL} cloc

entr:
	${INSTALL} entr

q:
	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} q.deb https://github.com/harelba/q/releases/download/v3.1.6/q-text-as-data-3.1.6-1.x86_64.deb
	${AT_TEMP_FOLDER} sudo dpkg -i q.deb

# SEARCH AND NAVIGATION




xdotool:
	${INSTALL} xdotool

# NETWORK UTILITIES
wifi-analyser:
	${INSTALL} linssid

# MAINTENANCE
ppapurge:
	${INSTALL} ppa-purge

# SPREADSHEETS
sc-im: libxlsxwriter
	${INSTALL} bison libncurses5-dev libncursesw5-dev libxml2-dev libzip-dev
	${AT_TEMP_FOLDER} git clone https://github.com/andmarti1424/sc-im.git
	${AT_TEMP_FOLDER} cd sc-im/src; make && sudo make install

libxlsxwriter:
	${AT_TEMP_FOLDER} git clone https://github.com/jmcnamara/libxlsxwriter.git
	${AT_TEMP_FOLDER} cd libxlsxwriter; make && sudo make install
	sudo ldconfig

# APPIMAGE SUPPORT
libfuse:
	${ADD_REPOSITORY} universe
	${INSTALL} libfuse2

# ============================================================================
# ACADEMIC AND DOCUMENTATION
# ============================================================================

# LATEX AND PUBLISHING
latex:
	${INSTALL} texlive-latex-base texlive-latex-extra texlive-humanities texlive-xetex texlive-publishers biber bibtool texlive-fonts-recommended texlive-latex-extra texlive-lang-portuguese latexmk

beamer-theme-metropolis: latex
	${AT_TEMP_FOLDER}  git clone https://github.com/matze/mtheme.git
	${AT_TEMP_FOLDER}  cd mtheme; make sty && make install

markdown:
	${INSTALL} pandoc

# DOCUMENT VIEWERS
zathura: FORCE
	${INSTALL} zathura

# REFERENCE MANAGEMENT
zotero:
	wget -qO- https://raw.githubusercontent.com/retorquere/zotero-deb/master/install.sh | sudo bash
	${UPDATE}
	${INSTALL} zotero

# TEXT EDITORS
gedit:
	${INSTALL} gedit

# ============================================================================
# BANKING AND SECURITY (BRAZIL SPECIFIC)
# ============================================================================

bb: bb-dependencies
	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} warsaw.deb https://cloud.gastecnologia.com.br/bb/downloads/ws/warsaw_setup64.deb
	${AT_TEMP_FOLDER} ${INSTALL_LOCAL} warsaw.deb

bb-dependencies:
	${INSTALL} openssl libnss3-tools libcurl3 dbus libdbus-1-3 python-openssl

# ============================================================================
# CONFIGURATION MANAGEMENT
# ============================================================================

configure: link-all

link-all: stow link-bin link-conky link-login-shell link-neovim link-ranger link-rofi link-tmux link-xresources link-urxvt link-zsh link-zathura

link-everything: link-qtile link-i3 link-rofi link-zsh link-qutebrowser link-vim link-tmux link-urxvt link-ranger link-xresources link-login-shell link-keyd link-vimium link-dunst link-gtk-3-0 link-neovim link-zathura

link-remove-everything: link-qtile-remove link-i3-remove link-rofi-remove link-zsh-remove link-qutebrowser-remove link-vim-remove link-tmux-remove link-urxvt-remove link-ranger-remove link-xresources-remove link-login-shell-remove link-keyd-remove link-vimium-remove link-dunst-remove link-gtk-3-0-remove link-neovim-remove link-zathura-remove

link-bin:
	stow -R bin --target=${HOME}/bin/

link-conky:
	stow -R conky --target=${HOME}

link-dunst:
	mkdir -p "${HOME}/.config/dunst/"
	stow -R dunst --target=${HOME}/.config/dunst/

link-gtk-3-0:
	mkdir -p "${HOME}/.config/gtk-3.0/"
	stow -R gtk-3.0 --target=${HOME}/.config/gtk-3.0/

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

link-scim:
	mkdir -p ${HOME}/.config/sc-im/
	stow -R sc-im --target=${HOME}/.config/sc-im/

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

link-vim:
	stow -R vim --target=${HOME}

link-vimium:
	mkdir -p ${HOME}/.config/vimium/
	stow -R vimium --target=${HOME}/.config/vimium/

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


link-opencode:
	stow -R opencode --target=${HOME}/.config/opencode/

# Remove targets (add similar pattern for other configs as needed)
link-qtile-remove:
	stow -D qtile --target=${HOME}/.config/

link-i3-remove:
	stow -D i3 --target=${HOME}/.config

link-rofi-remove:
	stow -D rofi --target=${HOME}/.config/rofi/

link-zsh-remove:
	stow -D zsh --target=${HOME}

link-qutebrowser-remove:
	stow -D qutebrowser --target=${HOME}/.config/qutebrowser/

link-vim-remove:
	stow -D vim --target=${HOME}

link-tmux-remove:
	stow -D tmux --target=${HOME}

link-urxvt-remove:
	stow -D urxvt --target=${HOME}/.urxvt/

link-ranger-remove:
	stow -D ranger --target=${HOME}/.config/ranger

link-xresources-remove:
	stow -D Xresources --target=${HOME}

link-login-shell-remove:
	stow -D login-shell --target=${HOME}

link-keyd-remove:
	sudo stow -D keyd_default --target=/etc/keyd/
	stow -D keyd_app --target=${HOME}/.config/keyd/

link-opencode-remove:
	stow -D opencode --target=${HOME}/.config/opencode/

link-vimium-remove:
	stow -D vimium --target=${HOME}/.config/vimium/

link-dunst-remove:
	stow -D dunst --target=${HOME}/.config/dunst/

link-gtk-3-0-remove:
	stow -D gtk-3.0 --target=${HOME}/.config/gtk-3.0/

link-neovim-remove:
	cd neovim; stow -D autoload --target=${HOME}/.local/share/nvim/site/autoload/
	cd neovim; stow -D config --target=${HOME}/.config/nvim/

link-zathura-remove:
	stow -D zathura --target=${HOME}/.config/zathura/

# ============================================================================
# UTILITY TARGETS
# ============================================================================

FORCE:

.PHONY: all help minimal desktop-full install-packages configure
.PHONY: core-system desktop-env terminal-env development communication media-creative utilities academic-docs
.PHONY: link-all link-everything link-remove-everything sc-im
