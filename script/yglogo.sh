#!/bin/bash
# Logo Yaourt-Gui
#
# Customize: http://www.network-science.de/ascii/
# Support: https://alexiobash.com
#
# example color:
# BLUE="\033[1;34m" 
# RED="\033[1;31m"
# WHITE="\033[1;37m"
# GREEN="\033[1;32m"
# YELLOW="\033[1;33m"
#

reset="\033[0m"
colorlogo=`echo $LANG | cut -c1-2`

# Check lang color
case "$colorlogo" in
	"it" | "IT" ) CA="\033[1;32m"; CB="\033[1;37m"; CB1=""; CC="\033[1;31m";;
	"fr" | "FR" ) CA="\033[1;34m"; CB="\033[1;37m"; CB1=""; CC="\033[1;31m";;
	"es" | "ES" ) CA="\033[1;31m"; CB=""; CB1="\033[1;33m"; CC="";;
	"en" | "EN" ) CA=""; CB=""; CB1="\033[1;34m"; CC="\033[1;34m";;
	*) CA="$reset"; CB="$reset"; CB1="$reset"; CC="$reset";;
esac

# Check Distro
source /etc/lsb-release

case $DISTRIB_ID in
	ManjaroLinux|Manjaro)
		# LOGO MANJARO
		GR="\033[1;32m"
		echo -e "$GR                  __  __              _                 	$reset"
		echo -e "$GR                 |  \/  | __ _ _ __  (_) __ _ _ __ ___  	$reset"
		echo -e "$GR                 | |\/| |/ _\` | '_ \ | |/ _\` | '__/ _ \ 	$reset"
		echo -e "$GR                 | |  | | (_| | | | || | (_| | | | (_) |	$reset"
		echo -e "$GR                 |_|  |_|\__,_|_| |_|/ |\__,_|_|  \___/ 	$reset"
		echo -e "$GR                                   |__/        			$reset"
	;;
	*)
		# LOGO ARCHLINUX
		echo -e "$CA                    _         $CB _   $CB1 _    _ $CC         			$reset"
		echo -e "$CA                   /_\  _ _ __$CB| |_ $CB1| |  (_)"$CC"_ _ _  ___ __ 		$reset" 
		echo -e "$CA                  / _ \| '_/ _$CB| ' |$CB1| |__| |$CC ' \ || \ \ / 		$reset"
		echo -e "$CA                 /_/ \_\_| \__$CB|_||_"$CB1"|____|_|"$CC"_||_\_,_/_\_\ 	$reset"
	;;
esac

## END SCRIPT
