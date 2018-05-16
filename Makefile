GIT_REPOS_ROOT_FOLDER = ~/git/
GIT_THIRD_PARTY_FOLDER = ${GIT_REPOS_ROOT_FOLDER}third-party/
INSTALL = apt install -y
UPDATE = apt update



all: desktop-environment link-all

link-all: link-xresources

link-xresources:
	stow Xresources --target=${HOME}
	xrdb ${HOME}/.Xresources

desktop-environment: i3 kde-connect-indicator drivers flashfocus

drivers:
	${INSTALL} bcmwl-kernel-source 

flashfocus:
	${INSTALL} libxcb-render0-dev libffi-dev python-dev python-cffi python-pip
	pip install flashfocus

kde-connect-indicator:
	add-apt-repository ppa:webupd8team/indicator-kdeconnect
	${UPDATE}
	${INSTALL} install kdeconnect indicator-kdeconnect

i3: notifications i3-python
	${INSTALL} i3

notifications:
	${INSTALL} dunst

i3-python:
	${INSTALL} python-tz python-tzlocal
zsh:
	${INSTALL} zsh
	chsh -s /bin/zsh

keepassxc:
	sudo add-apt-repository ppa:phoerious/keepassxc
	${UPDATE}
	${INSTALL} keepassxc

google-chrome:
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	dpkg -i google-chrome-stable_current_amd64.deb
	rm google-chrome-stable_current_amd64.deb

mendeley:
	wget -O mendeleydesktop.deb https://www.mendeley.com/repositories/ubuntu/stable/amd64/mendeleydesktop-latest
	${INSTALL} libqtwebkit4
	dpkg -i mendeleydesktop.deb
	rm mendeleydesktop.deb

geeknote:
	${INSTALL} python-setuptools* python-dev git
	cd ${GIT_THIRD_PARTY_FOLDER}; git clone git://github.com/VitaliyRodnenko/geeknote.git; cd geeknote; git pull origin master; python setup.py install


