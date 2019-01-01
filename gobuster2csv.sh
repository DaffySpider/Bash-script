#!/bin/bash

THREADS=10
LINES='====================================================================='

# echo "                     __                              __                           ______                                  "
# echo "                    |  \                            |  \                         /      \                                 "
# echo "  ______    ______  | $$____   __    __   _______  _| $$_     ______    ______  |  $$$$$$\  _______   _______  __     __  "
# echo " /     \\  /      \ | $$    \ |  \  |  \ /       \|   $$ \   /      \  /      \  \$$__| $$ /       \ /       \|  \   /  \ "
# echo "|  $$$$$$\|  $$$$$$\| $$$$$$$\| $$  | $$|  $$$$$$$ \$$$$$$  |  $$$$$$\|  $$$$$$\ /      $$|  $$$$$$$|  $$$$$$$ \$$\ /  $$ "
# echo "| $$  | $$| $$  | $$| $$  | $$| $$  | $$ \$$    \   | $$ __ | $$    $$| $$   \$$|  $$$$$$ | $$       \$$    \   \$$\  $$  " 
# echo "| $$__| $$| $$__/ $$| $$__/ $$| $$__/ $$ _\$$$$$$\  | $$|  \| $$$$$$$$| $$      | $$_____ | $$_____  _\$$$$$$\   \$$ $$   " 
# echo " \$$    $$ \$$    $$| $$    $$ \$$    $$|       $$   \$$  $$ \$$     \| $$      | $$     \ \$$     \|       $$    \$$$    " 
# echo " _\$$$$$$$  \$$$$$$  \$$$$$$$   \$$$$$$  \$$$$$$$     \$$$$   \$$$$$$$ \$$       \$$$$$$$$  \$$$$$$$ \$$$$$$$      \$     " 
# echo "|  \__| $$                                                                                                                " 
# echo " \$$    $$                                                                                                                " 
# echo "  \$$$$$$                                                                                                                 "
 


usage() {

	echo "Usage: ${0} [-f] [TARGETS] [-w] [WORDLIST]" >&2
	echo "-u 	To set a single target" >&2
	echo "-f	To set multiple target from a file" >&2
	echo "-t	Set the number of threads" >&2
	echo "-w	To supply wordlist" >&2
	echo "-h	For help" >&2
	exit 1
}

while getopts u:f:t:w:h OPTIONS
do
	case ${OPTIONS} in
		u)
			SINGLE_TARGET='true'
			TARGET=${OPTARG}
			if [[ -f ${TARGET} ]]
			then
				echo "[-] Please supply target" >&2
				exit 1
			fi
			;;
		f)
			MULTIPLE_TARGET='true'
			TARGET_LIST=${OPTARG}
			if [[ ! -f "${TARGET_LIST}" ]]
			then
				echo "[-] Please supply file" >&2
				exit 1
			fi
			;;
		t)
			THREADS=${OPTARG}
			;;
		w)
			SET_WORDLIST='true'
			WORDLIST=${OPTARG}
			;;
		h)
			usage
			;;
		?)
			usage
			;;
	esac
done

# generate random file number
RANDOM_NUMBER=$(date +%s%D${RANDOM}${RANDOM} | base64 | head -n 10 )
TMP_DIR="/tmp/${RANDOM_NUMBER}"
touch ${TMP_DIR}
echo ${TMP_DIR}

# create csv file header
printf '%s\n' "URL" "Status Code" | paste -sd ',' > results.csv

if [[ "${SET_WORDLIST}" = 'true' ]]
then
	if [[ "${MULTIPLE_TARGET}" = 'true' ]]
	then
		for i in $(cat "${TARGET_LIST}")
		do
			echo "${LINES}"
			echo "[+] Wordlist: ${WORDLIST}"
			echo "[+] Target list: ${TARGET_LIST}"
			echo "[+] Threads: ${THREADS}"
			echo "Brute-forcing: ${i}"
			date
			gobuster -k -r -e -u ${i} -w ${WORDLIST} -t ${THREADS} >> ${TMP_DIR}
		done
		grep "Status: " ${TMP_DIR} | awk '{print $1","$3}' | tr -d ')' | sort -u >> results.csv
		echo "Finished scan..."
	elif [[ "${SINGLE_TARGET}" = 'true' ]]
	then	
		echo "${LINES}"
		echo "[+] Wordlist: ${WORDLIST}"
		echo "[+] Target: ${TARGET}"
		echo "[+] Threads: ${THREADS}"
		echo "Brute-forcing: ${TARGET}"
		date
		gobuster -k -r -e -u ${TARGET} -w ${WORDLIST} ${THREADS} >> ${TMP_DIR}
		grep "Status: " ${TMP_DIR} | awk '{print $1","$3}' | tr -d ')' | sort -u >> results.csv
		echo "Finished scan..."
	else 
		usage
	fi
else
	usage
fi

rm ${TMP_DIR} 

exit 0
