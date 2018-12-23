GIT_REPOS_ROOT_FOLDER = ~/git/
GIT_THIRD_PARTY_FOLDER = ${GIT_REPOS_ROOT_FOLDER}third-party/
INSTALL = apt install -y
INSTALL_LOCAL=dpkg -i
UPDATE = apt update
ADD_REPOSITORY=add-apt-repository -y
DOWNLOAD_AS=wget -O
AT_TEMP_FOLDER=cd /tmp/ ; 


all: desktop-environment link-all

# DESKTOP EXPERIENCE
desktop-environment: i3 kde-connect-indicator flashfocus desktop-configuration diodon

desktop-configuration:
	${INSTALL} lxappearance

i3: notifications i3-bar rofi wallpaper compositor
	${INSTALL} i3

i3-bar: py3status i3-python

compositor:
	${INSTALL} compton

py3status:
	${INSTALL} py3status


diodon:
	${INSTALL} diodon

notifications:
	${INSTALL} dunst

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

kde-connect-indicator:
	add-apt-repository ppa:webupd8team/indicator-kdeconnect
	${UPDATE}
	${INSTALL} kdeconnect indicator-kdeconnect

polybar: polybar-dependencies
	${AT_TEMP_FOLDER} git clone --branch 3.2 --recursive https://github.com/jaagr/polybar
	${AT_TEMP_FOLDER} mkdir polybar/build; cd polybar/build; cmake ..; make install

polybar-dependencies:
	${INSTALL} cmake cmake-data pkg-config libcairo2-dev libxcb1-dev libxcb-util0-dev libxcb-randr0-dev python-xcbgen xcb-proto libxcb-image0-dev libxcb-ewmh-dev libxcb-icccm4-dev
	${INSTALL} libxcb-xkb-dev libxcb-xrm-dev libxcb-cursor-dev libasound2-dev libpulse-dev i3-wm libjsoncpp-dev libmpdclient-dev libcurl4-openssl-dev libiw-dev libnl-3-dev 


rofi:
	${INSTALL} rofi

conky-notifications:
	${INSTALL} conky-all

terminal:
	${INSTALL} rxvt-unicode



# TERMINAL TOOLS
vi:
	${INSTALL} neovim

ranger-install:
	${INSTALL} ranger

clipboard-tools: diodon
	${INSTALL} xclip

entr:
	${INSTALL} entr

zsh:
	${INSTALL} zsh
	chsh -s /bin/zsh

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


# DEVELOPMENT TOOLS

docker: docker-ce-edge 

docker-ce-edge:
	$(if $(shell which docker),$(error "Docker already installed"),)
	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} get-docker.sh https://get.docker.com 
	${AT_TEMP_FOLDER} sh get-docker.sh 
	usermod -aG docker `whoami`

version-control:
	${INSTALL} git mercurial mercurial-git subversion

shellcheck:
	${INSTALL} shellcheck

web-service-development-tools: insomnia
	${INSTALL} httpie jq tcpflow

web-development:
	${INSTALL} jekyll

insomnia:
	echo "deb https://dl.bintray.com/getinsomnia/Insomnia /" | sudo tee -a /etc/apt/sources.list.d/insomnia.list
	wget --quiet -O - https://insomnia.rest/keys/debian-public.key.asc | sudo apt-key add -
	${UPDATE}
	${INSTALL} insomnia



build-tools:
	${INSTALL} maven gradle gpp ant checkinstall make

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

qutebrowser:
	${INSTALL} qutebrowser


google-chrome:
	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	${AT_TEMP_FOLDER} ${INSTALL_LOCAL} google-chrome.deb


bb: bb-dependencies
	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} warsaw.deb https://cloud.gastecnologia.com.br/bb/downloads/ws/warsaw_setup64.deb
	${AT_TEMP_FOLDER} ${INSTALL_LOCAL} warsaw.deb

bb-dependencies:
	${INSTALL} openssl libnss3-tools libcurl3 dbus libdbus-1-3 python-openssl






telegram:
	snap install telegram-sergiusens



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


#screenshot:
#	${INSTALL} spectacle

autokey:
	${ADD_REPOSITORY} ppa:sporkwitch/autokey
	${UPDATE}
	${INSTALL} autokey-gtk

spotify:
	apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 931FF8E79F0876134EDDBDCCA87FF9DF48BF1C90
	echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list
	${UPDATE}
	${INSTALL} spotify-client

skype:
	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} skype.deb https://repo.skype.com/latest/skypeforlinux-64.deb
	${AT_TEMP_FOLDER} dpkg -i skype.deb



# stow all configuration files ------------------------------------------

link-all: link-bin link-conky link-login-shell link-neovim link-polybar link-ranger link-xresources link-zathura

link-bin:
	stow -R bin --target=${HOME}/bin/

link-conky:
	stow -R conky --target=${HOME}

link-login-shell:
	stow -R login-shell --target=${HOME}

link-neovim:
	mkdir -p ${HOME}/.local/share/nvim/site/autoload/ 
	cd neovim; stow -R autoload --target=${HOME}/.local/share/nvim/site/autoload/
	mkdir -p ${HOME}/.config/nvim/
	cd neovim; stow -R config --target=${HOME}/.config/nvim/

link-polybar:
	mkdir -p ${HOME}/.config/polybar/
	stow -R polybar --target=${HOME}/.config/polybar/

link-ranger:
	stow -R ranger --target=${HOME}/.config/ranger	

link-xresources:
	stow -R Xresources --target=${HOME}
	xrdb ${HOME}/.Xresources

link-zathura:
	mkdir -p ${HOME}/.config/zathura/
	stow -R zathura --target=${HOME}/.config/zathura/




FORCE:
