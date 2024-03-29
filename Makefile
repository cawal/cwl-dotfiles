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


all: desktop-environment link-all

# DESKTOP EXPERIENCE
desktop-environment: i3 flashfocus desktop-configuration clipboard-manager xdotool

clipboard-manager: greenclip rofi

desktop-configuration: arandr
	${INSTALL} lxappearance

i3: notifications i3-bar rofi wallpaper compositor i3ipc
	#${AT_TEMP_FOLDER} /usr/lib/apt/apt-helper download-file http://debian.sur5r.net/i3/pool/main/s/sur5r-keyring/sur5r-keyring_2019.02.01_all.deb keyring.deb SHA256:176af52de1a976f103f9809920d80d02411ac5e763f695327de9fa6aff23f416
	#${AT_TEMP_FOLDER} ${INSTALL_LOCAL} ./keyring.deb
	#${AT_TEMP_FOLDER} echo "deb http://debian.sur5r.net/i3/ $(grep '^DISTRIB_CODENAME=' /etc/lsb-release | cut -f2 -d=) universe" >> /etc/apt/sources.list.d/sur5r-i3.list
	${UPDATE}
	${INSTALL} i3

i3-bar: py3status i3-python

i3ipc:
	pip3 install i3ipc

arandr:
	${INSTALL} arandr

xmonad:
	${INSTALL} xmonad libghc-xmonad-contrib-dev xmobar

alluvium:
	${INSTALL} libcairo2-dev libgirepository1.0-dev
	pip3 install alluvium

compositor:
	${INSTALL} compton

py3status:
	${INSTALL} py3status

bluetooth:
	sudo apt-get install bluetooth bluez bluez-tools rfkill blueman

greenclip:
	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} greenclip.bin https://github.com/erebe/greenclip/releases/download/3.3/greenclip
	${AT_TEMP_FOLDER} chmod +x greenclip.bin
	${AT_TEMP_FOLDER} sudo mv greenclip.bin /usr/local/bin/greenclip

#diodon:
#	${INSTALL} diodon

notifications: dunst

dunst:
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

i3-python:
	${INSTALL} python3-tz python3-tzlocal


wallpaper:
	${INSTALL} nitrogen


icon-themes:
	${INSTALL} numix-icon-theme

gtk-themes:
	${INSTALL} arc-theme

drivers:
	${INSTALL} bcmwl-kernel-source

flashfocus:
	${INSTALL} libxcb-render0-dev libffi-dev python-dev python-cffi python-pip
	pip install flashfocus

rofi: FORCE
	${INSTALL} rofi unifont

conky-notifications:
	${INSTALL} conky-all

terminal:
	${INSTALL} rxvt-unicode



# TERMINAL TOOLS

vi: ripgrep silver-seacher coc-node
	${ADD_REPOSITORY} ppa:neovim-ppa/stable
	${UPDATE}
	${INSTALL} neovim universal-ctags
	pip3 install neovim
	#pip install neovim

ripgrep:
	${SNAP_INSTALL} --classic ripgrep

silver-seacher:
	${INSTALL} silversearcher-ag

coc-node:
	nvm install "${COC_NODE_VERSION}"

python3-pynvim: python3-pip3
	cd ~; python3 -m venv .neovim_venv
	cd ~/.neovim_venv; source .bin/activate; pip install pynvim

python3-pip3:
	${INSTALL} python3-pip

ranger-install:
	${INSTALL} ranger

clipboard-tools: greenclip
	${INSTALL} xclip

# tools for editing CSV files
csvkit:
	${INSTALL} csvkit

# count lines of codes
cloc:
	${INSTALL} cloc

entr:
	${INSTALL} entr

tmate:
	${INSTALL} tmate

zsh: FORCE
	${INSTALL} zsh
	chsh -s /bin/zsh

oh-my-zsh:
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

cli-administration: osquery ppapurge

ppapurge:
	${INSTALL} ppa-purge

osquery:
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1484120AC4E9F8A1A577AEEE97A80C63C9D8B80B
	${ADD_REPOSITORY} 'deb [arch=amd64] https://pkg.osquery.io/deb deb main'
	${UPDATE}
	${INSTALL} osquery


q:
	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} q.deb https://github.com/harelba/packages-for-q/raw/master/deb/q-text-as-data_1.7.1-2_all.deb
	${AT_TEMP_FOLDER} dpkg -i q.deb

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

docker: docker-ce-edge docker-compose

docker-ce-edge:
	$(if $(shell which docker),$(error "Docker already installed"),)
	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} get-docker.sh https://get.docker.com
	${AT_TEMP_FOLDER} sh get-docker.sh
	sudo usermod -aG docker `whoami`

docker-compose:
	sudo curl -L "https://github.com/docker/compose/releases/download/1.28.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose


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

# offline docs
zeal:
	${ADD_REPOSITORY} ppa:zeal-developers/ppa
	${UPDATE}
	${INSTALL} zeal

mssql-tools:
	curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
	curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | sudo tee /etc/apt/sources.list.d/msprod.list
	${UPDATE}
	${INSTALL}  mssql-tools unixodbc-dev


go:
	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} go.tar.gz  https://golang.org/dl/go1.16.2.linux-amd64.tar.gz
	${AT_TEMP_FOLDER} tar xf go.tar.tz
	${AT_TEMP_FOLDER} sudo mv go /usr/local

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
	#sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 931FF8E79F0876134EDDBDCCA87FF9DF48BF1C90
	#echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list
	${UPDATE}
	${INSTALL} spotify-client

skype:
	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} skype.deb https://repo.skype.com/latest/skypeforlinux-64.deb
	${AT_TEMP_FOLDER} dpkg -i skype.deb



# stow all configuration files ------------------------------------------

link-all: link-bin link-conky link-gtk3 link-login-shell link-neovim link-ranger link-rofi link-tmux link-xresources link-urxvt link-vscode link-zsh link-zathura

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

link-vscode:
	mkdir -p ${HOME}/.config/Code/user
	stow -R vscode --target=${HOME}/.config/Code/User

link-zsh:
	stow -R zsh --target=${HOME}

link-zathura:
	mkdir -p ${HOME}/.config/zathura/
	stow -R zathura --target=${HOME}/.config/zathura/




FORCE:
