GIT_REPOS_ROOT_FOLDER = ~/git/
GIT_THIRD_PARTY_FOLDER = ${GIT_REPOS_ROOT_FOLDER}third-party/
INSTALL = apt install -y
INSTALL_LOCAL=dpkg -i
UPDATE = apt update
ADD_REPOSITORY=add-apt-repository -y
DOWNLOAD_AS=wget -O
AT_TEMP_FOLDER=cd /tmp/ ; 


all: desktop-environment link-all

link-all: link-xresources link-login-shell

link-xresources:
	stow Xresources --target=${HOME}
	xrdb ${HOME}/.Xresources

link-login-shell:
	stow login-shell --target=${HOME}

desktop-environment: i3 kde-connect-indicator flashfocus desktop-configuration

desktop-configuration:
	${INSTALL} lxappearance

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

i3: notifications i3-bar rofi wallpaper compositor
	${INSTALL} i3

i3-bar: py3status i3-python

compositor:
	${INSTALL} compton

py3status:
	${INSTALL} py3status

rofi:
	${INSTALL} rofi

wallpaper:
	${INSTALL} nitrogen

version-control:
	${INSTALL} git mercurial mercurial-git subversion

notifications:
	${INSTALL} dunst

i3-python:
	${INSTALL} python3-tz python3-tzlocal

zsh:
	${INSTALL} zsh
	chsh -s /bin/zsh

image-manipulation:
	${INSTALL} inkscape gimp imagemagick

#dropbox:
#	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} dropbox.deb https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2015.10.28_amd64.deb
#	${INSTALL} python-gtk2 libpango1.0-0
#	${AT_TEMP_FOLDER} ${INSTALL_LOCAL} dropbox.deb 

vi:
	${INSTALL} neovim

ranger-install:
	${INSTALL} ranger

link-ranger:
	stow ranger --target=${HOME}/.config/ranger	

video-player:
	${INSTALL} vlc

keepassxc:
	${ADD_REPOSITORY} ppa:phoerious/keepassxc
	${UPDATE}
	${INSTALL} keepassxc

google-chrome:
	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	${AT_TEMP_FOLDER} ${INSTALL_LOCAL} google-chrome.deb

mendeley:
	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} mendeleydesktop.deb https://www.mendeley.com/repositories/ubuntu/stable/amd64/mendeleydesktop-latest
	${INSTALL} libqtwebkit4 gconf2
	${AT_TEMP_FOLDER} ${INSTALL_LOCAL} mendeleydesktop.deb

web-service-development-tools: insomnia
	${INSTALL} httpie jq tcpflow

web-development:
	${INSTALL} jekyll

insomnia:
	echo "deb https://dl.bintray.com/getinsomnia/Insomnia /" | sudo tee -a /etc/apt/sources.list.d/insomnia.list
	wget --quiet -O - https://insomnia.rest/keys/debian-public.key.asc | sudo apt-key add -
	${UPDATE}
	${INSTALL} insomnia
#	snap install insomnia


link-conky:
	stow conky --target=${HOME}

build-tools:
	${INSTALL} maven gradle gpp ant 

oracle-java-8:
	${ADD_REPOSITORY} ppa:webupd8team/java
	${UPDATE}
	${INSTALL} oracle-java8-installer

oracle-java-10:
	${ADD_REPOSITORY} ppa:linuxuprising/java
	${UPDATE}
	${INSTALL} oracle-java10-installer


cli-administration:
	${INSTALL} ppa-purge

openjdk-11:
	${INSTALL} openjdk-11-jdk

openjdk-8:
	${INSTALL} openjdk-8-jdk icedtea-8-plugin

conky-notifications:
	${INSTALL} conky-all

writing: latex markdown office-suite

markdown:
	${INSTALL} pandoc

latex:
	${INSTALL} texlive-latex-base texlive-latex-extra texlive-xetex texlive-publishers biber bibtool

office-suite:
	${INSTALL} libreoffice

terminal:
	${INSTALL} rxvt-unicode

screenruler:
	${INSTALL} screenruler

q:
	${AT_TEMP_FOLDER} ${DOWNLOAD_AS} q.deb https://github.com/harelba/packages-for-q/raw/master/deb/q-text-as-data_1.7.1-2_all.deb
	${AT_TEMP_FOLDER} dpkg -i q.deb

#screenshot:
#	${INSTALL} spectacle

fonts:
	${INSTALL} ubuntu-restricted-extras

autokey:
	${ADD_REPOSITORY} ppa:sporkwitch/autokey
	${UPDATE}
	${INSTALL} autokey-gtk
