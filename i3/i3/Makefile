MASTER_FILE = config.d/config.gpp
RESULT_FILE = config
BARS_DIRECTORY = py3status
HOSTNAME := ${shell hostname}

.PHONY: create_config bars top-left.bar top-right.bar

create_config:
	gpp -H -D${HOSTNAME}=1 -o ${RESULT_FILE} ${MASTER_FILE}

.bartemplate.bar:
	cd ${BARS_DIRECTORY} ; gpp -H -D${HOSTNAME}=1 -o  $*.bar $<

bars: top-left.bar top-right.bar

top-left.bar: 
#	cd ${BARS_DIRECTORY} ; gpp -H -D${HOSTNAME}=1 -o  top-left.bar top-left.bar.template
	cd ${BARS_DIRECTORY} ; gpp -U "<#" ">" "\B" "|" ">" "<" ">" "#" ""  -D${HOSTNAME}=1 -o  top-left.bar top-left.bar.template

top-right.bar: 
#	cd ${BARS_DIRECTORY} ; gpp -H -D${HOSTNAME}=1 -o  top-right.bar top-right.bar.template
	cd ${BARS_DIRECTORY} ; gpp -U "<#" ">" "\B" "|" ">" "<" ">" "#" ""  -D${HOSTNAME}=1 -o  top-right.bar top-right.bar.template

