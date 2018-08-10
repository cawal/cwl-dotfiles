MASTER_FILE = config.d/config.gpp
RESULT_FILE = config
BARS_DIRECTORY = py3status
HOSTNAME := ${shell hostname}

create_config:
	gpp -H -D${HOSTNAME}=1 -o ${RESULT_FILE} ${MASTER_FILE}

#.bartemplate.bar:
#	cd ${BARS_DIRECTORY} ; gpp -H -D${HOSTNAME}=1 -o  $*.bar $<
#
#bars: top-left.bar top-right.bar bottom-right.bar 
