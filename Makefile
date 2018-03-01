all: install-desktop-env 

install-desktop-env: kde-connect-indicator

kde-connect-indicator:
	add-apt-repository ppa:webupd8team/indicator-kdeconnect
	apt update
	apt install kdeconnect indicator-kdeconnect
