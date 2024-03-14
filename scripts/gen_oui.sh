#!/bin/sh

CURL=`which curl 2>/dev/null`
WGET=`which wget 2>/dev/null`
OUI_DOWNLOAD_URL="http://standards.ieee.org/develop/regauth/oui/oui.txt"

OUI_PATH="/usr/local/etc/aircrack-ng"
AIRODUMP_NG_OUI="${OUI_PATH}/airodump-ng-oui.txt"
OUI_IEEE="${OUI_PATH}/oui.txt"
USERID=""


# Make sure the user is root
if [ x"`which id 2> /dev/null`" != "x" ]
then
	USERID="`id -u 2> /dev/null`"
fi

if [ x$USERID = "x" -a x$UID != "x" ]
then
	USERID=$UID
fi

if [ x$USERID != "x" -a x$USERID != "x0" ]
then
	echo Run it as root ; exit ;
fi


if [ ! -d "${OUI_PATH}" ]; then
	mkdir -p ${OUI_PATH}
fi

if [ ${CURL} ] || [ ${WGET} ]; then
	# Delete previous partially downloaded file (if the script was aborted)
	rm -f ${OUI_IEEE} >/dev/null 2>/dev/null

	# Download it
	echo "[*] Downloading IEEE OUI file..."

	if [ ${WGET} ]; then
		${WGET} ${OUI_DOWNLOAD_URL} -O ${OUI_IEEE} >/dev/null 2>/dev/null
	else
		${CURL} -L ${OUI_DOWNLOAD_URL} > ${OUI_IEEE} 2>/dev/null
	fi
	
	if [ "${?}" -ne 0 ]; then
		echo "[*] Error: Failed to download OUI list, aborting..."
		exit 1
	fi

	# Parse the downloaded OUI list
	echo "[*] Parsing OUI file..."
		
	# Keep the previous file
	if [ -f "${OUI_DOWNLOADED}" ]; then
		mv ${AIRODUMP_NG_OUI} ${OUI}-old
	fi

	# Parse it
	grep "(hex)" ${OUI_IEEE} > ${AIRODUMP_NG_OUI}
	if [ "${?}" -ne 0 ]; then
		echo "[*] Error: Failed to parse OUI, aborting..."
		exit 1
	fi

	# Cleanup
	rm -f ${OUI_IEEE}
		
	echo "[*] Airodump-ng OUI file successfully updated"
else
	if [ -f "${OUI}" ]; then
		echo "[*] Please install curl or wget to update OUI list"
	else 
		echo "[*] Please install curl or wget to install OUI list"
	fi
	exit 1
fi

exit 0
