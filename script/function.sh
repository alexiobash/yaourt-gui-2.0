#!/bin/bash
# Yaourt-Gui is a bash and GTK gui for yaourt and Pacman
#
# Creation-Date: 2015-07-01
#
# Support: http://alexiobash.com
# Mail: support@alexiobash.com

# Set environment
TEXTDOMAINDIR=/usr/share/locale
TEXTDOMAIN=yaourt-gui
BLUE="\033[7;34m"
BLU="\033[1;34m"
RED="\033[1;31m"
LRED="\033[7;31m"
WHI="\033[1;37m"
NC="\033[0m"
YELLOW="\033[1;33m"
GREL="\033[7;32m"
GRE="\033[1;32m"
PROFD=/etc/profile.d
CONFIG=/usr/share/yaourt-gui
IMGDIR=$CONFIG/img
SCRIPT=$CONFIG/script
PAMACBIN=/usr/bin/pamac-manager
VER=$(cat $CONFIG/RELEASE)
msg="$(gettext 'Insert Root Password to be continue. Save your Password for this session.')"

# Load Yaourt-GUI conf
function loadconf () {
	source /etc/yaourt-gui.conf
}

# Export for languages
export TEXTDOMAINDIR=/usr/share/locale
export TEXTDOMAIN=yaourt-gui

# Check Distro
source /etc/lsb-release
case $DISTRIB_ID in
	ManjaroLinux|Manjaro) 
		distro=Manjaro
		logo="$IMGDIR/logo_manjaro.png"
	;;
	*) 
		distro=ArchLinux
		logo="$IMGDIR/logo_archlinux.png"
	;;
esac

# Function 
function initmessage () { # Init Message
	zenity --title="Yaourt-Gui GTK Info" --text-info --filename=/usr/share/yaourt-gui/yaourt-gui.message --height="500" --width="800"
	resexit="$?"
	if [[ -z $2 ]]; then case $resexit in 0) touch ~/.yaourt-gui.init;; *) exit 1;; esac; fi
}


function pacmanrun () { # Pacman is running
	loadconf
	if [[ -f /var/lib/pacman/db.lck ]]; then zenity --error --text="$(gettext 'Pacman is currently in use.')\n$(gettext 'please wait or use the Unlock Function.')"; exit 1; fi
}

function sync_db () { # Sync DB
	loadconf
	pacmanrun
	result=$(zenity --extra-button="$(gettext 'Run in terminal')" --question --title="$(gettext 'Sync DB')" --text="$(gettext 'Do you want Sync DB?')" --ok-label="$(gettext 'Sync')")
	case $? in
		0) yaourt -Sy | zenity --title="$(gettext 'Sync DB')" --progress --auto-kill --text="$(gettext 'Command'): $ yaourt -Sy" --pulsate;;
		*) if [[ ! -z $result ]]; then $XTERM "yaourt -Sy; echo ""; read -sp \"$(gettext 'Press Enter to close the window') \""; fi;;
	esac
		
}

function updatepkg () { # Update Packages
	loadconf
	pacmanrun
	if [[ -f /tmp/list_update ]]; then rm -f /tmp/list_update; fi
	#yaourt -Sy | zenity --title="$(gettext 'Sync DB')" --progress --auto-kill --text="$(gettext 'Sync DB in progress...')" --pulsate --auto-close
	#case $? in
	#	0)
			yaourt -Qua | sed -e 's/\// /g' | sed 's/->/ /g' > /tmp/list_update
			check_pkg=$(cat /tmp/list_update | wc -l)
			if [[ "$check_pkg" = 0 ]]; then zenity --error --text="$(gettext 'No packages needs to be updated!!!')"; exit 1; fi
			pkg=$(zenity --list --title "$(gettext 'Update System')" --text "$(gettext 'Available Updates:')" --checklist --column="$(gettext 'Pick')" --column="$(gettext 'Packages')" --column="$(gettext 'Repo')" --column="$(gettext 'Actual')" --column="$(gettext 'Update')" $(for i in $(seq 1 $(cat /tmp/list_update | wc -l)); do echo "FALSE $(cat /tmp/list_update | sed -n "$i"p | awk '{print $2,$1,$3,$4}')"; done) --separator=" ")
			case $? in
				0)
					if [[ ! -z $pkg ]]; then 
						$XTERM "yaourt -S $pkg --noconfirm  ; echo ""; read -sp \"$(gettext 'Press Enter to close the window') \""
					else
						zenity --error --text="$(gettext 'No package selected')"
						update
					fi
				;;
				*) exit 1;;
			esac		
	#	;; # end 1 case
	#	*) exit 1;;
	#esac
}

function fullupdate () { # Update System and force
	loadconf
	pacmanrun
	if [[ -f /tmp/list_update ]]; then rm -f /tmp/list_update; fi
#	yaourt -Sy | zenity --title="$(gettext 'Sync DB')" --progress --auto-kill --text="$(gettext 'Sync DB in progress...')" --pulsate --auto-close
#	case $? in
#		0)
			yaourt -Qua | sed -e 's/\// /g' | sed 's/->/ /g' > /tmp/list_update
			check_pkg=$(cat /tmp/list_update | wc -l)
			if [[ "$check_pkg" = 0 ]]; then zenity --error --text="$(gettext 'No packages needs to be upgraded!!!')"; exit 1; fi	
			result=$(zenity --extra-button="$(gettext 'Upgrade noconfirm')" --cancel-label="$(gettext 'Abort')" --ok-label="$(gettext 'Upgrade')" --list --title="$(gettext 'Update System')" --text="$check_pkg $(gettext 'packages will be upgraded:')" --column="$(gettext 'Packages')" --column="$(gettext 'Repo')" --column="$(gettext 'Current')" --column="$(gettext 'Update')" $(for i in $(seq 1 $(cat /tmp/list_update | wc -l)); do echo "$(cat /tmp/list_update | sed -n "$i"p | awk '{print $2,$1,$3,$4}')"; done) --separator=" ")
			case $? in
				0) if [[ $2 = force ]]; then yaopt="-Sua --force"; else yaopt="-Sua"; fi;;
				1)
					if [[ ! -z $result ]]; then
						if [[ $2 = force ]]; then yaopt="-Sua --force --noconfirm"; else yaopt="-Sua --noconfirm"; fi
					else
						exit 1
					fi
				;;
				*) exit 1;;
			esac
			$XTERM "yaourt $yaopt ; echo ""; read -sp \"$(gettext 'Press Enter to close the window') \""
#		;;
#		*) exit 1;
#	esac
}

function setproxy () { # Set proxy
	loadconf
	if [[ -f $PROFD/proxy.sh ]]; then 
		source $PROFD/proxy.sh
		zenity --title="$(gettext 'Proxy allready configured')" --question --text="$(gettext 'The Proxy is allready configured.')\n$(gettext 'Do you want override proxy settings?')\n\nProxy Server: $PROXYHOST\nProxy Port: $PROXYPORT"
		if [[ $? != 0 ]]; then exit 1; fi
	fi
	typeproxy=$(zenity --title="Proxy" --extra-button="$(gettext 'Abort')" --question --text="$(gettext 'Is a Auth Proxy?')")
	case $? in
		0) 
			#string_elab=$(zenity --forms --text="Set Proxy" --title "Proxy" --add-entry="$(gettext 'IP or Hostname'):" --add-entry="$(gettext 'Port'):" --add-entry="$(gettext 'Username'):" --add-password "Password:" --separator=" ")
			string_elab=$(zenity --forms --text="Set Proxy" --title "Proxy" --add-entry="$(gettext 'IP or Hostname'):" --add-entry="$(gettext 'Port'):" --add-entry="$(gettext 'Username'):" --add-password "Password:" --add-entry="$(gettext 'Exclusion'):" --separator=" ")
			if [[ $? != 0 ]]; then exit 1; fi
			PROXY=$(echo $string_elab | awk '{print $1}')
			PORT=$(echo $string_elab | awk '{print $2}')
			USRNAME=$(echo $string_elab | awk '{print $3}')
			PASSWPR=$(echo $string_elab | awk '{print $4}')
			EXCLUDE=$(echo $string_elab | awk '{for (i=5; i<=NF; i++) print $i}')
			if [[ ( -z $PROXY ) || ( -z $PORT ) || ( -z $USRNAME ) || ( -z $PASSWPR ) ]]; then zenity --error --text="$(gettext 'Empty Value')"; setproxy; fi
			echo -e "#!/bin/bash" > /home/$USER/proxy.sh	
			echo -e "PROXYHOST=$PROXY" >> /home/$USER/proxy.sh
			echo -e "PROXYPORT=$PORT" >> /home/$USER/proxy.sh		
			echo "export http_proxy='http://$USRNAME:$PASSWPR@$PROXY:$PORT'" >> /home/$USER/proxy.sh
			echo "export https_proxy='http://$USRNAME:$PASSWPR@$PROXY:$PORT'" >> /home/$USER/proxy.sh
			echo "export ftp_proxy='http://$USRNAME:$PASSWPR@$PROXY:$PORT'" >> /home/$USER/proxy.sh
			echo "export no_proxy='$EXCLUDE'" >> /home/$USER/proxy.sh
			gksu -m "$msg" "mv /home/$USER/proxy.sh $PROFD"
			if [[ -f $PROFD/proxy.sh ]]; then
				gksu -m "$msg" "chmod +x $PROFD/proxy.sh"
				gksu -m "$msg" "chown root:root $PROFD/proxy.sh"
				source $PROFD/proxy.sh
				zenity --info --text="$(gettext 'Proxy set successfully')"
				exit 0
			else
				zenity --error --text="$(gettext 'The proxy is not set')"
				exit 1
			fi
			exit
		;;
		*)
			if [[ ! -z $typeproxy ]]; then exit 1; fi
			#string_elab=$(zenity  --forms --text="Set Proxy" --title "Proxy" --add-entry="$(gettext 'IP or Hostname'):" --add-entry="$(gettext 'Port'):" --separator=" ")
			string_elab=$(zenity  --forms --text="Set Proxy" --title "Proxy" --add-entry="$(gettext 'IP or Hostname'):" --add-entry="$(gettext 'Port'):" --add-entry="$(gettext 'Exclusion'):" --separator=" ")
			if [[ $? != 0 ]]; then exit 1; fi
			PROXY=$(echo $string_elab | awk '{print $1}')
			PORT=$(echo $string_elab | awk '{print $2}')
			EXCLUDE=$(echo $string_elab | awk '{for (i=3; i<=NF; i++) print $i}')
			if [[ ( -z $PROXY ) || ( -z $PORT ) ]]; then zenity --error --text="$(gettext 'Empty Value')"; setproxy; fi
			echo -e "#!/bin/bash" > /home/$USER/proxy.sh
			echo -e "PROXYHOST=$PROXY" >> /home/$USER/proxy.sh
			echo -e "PROXYPORT=$PORT" >> /home/$USER/proxy.sh
			echo -e "export http_proxy='"http://$PROXY:$PORT"'" >> /home/$USER/proxy.sh
			echo -e "export https_proxy='"http://$PROXY:$PORT"'" >> /home/$USER/proxy.sh
			echo -e "export ftp_proxy='"http://$PROXY:$PORT"'" >> /home/$USER/proxy.sh
			echo "export no_proxy='$EXCLUDE'" >> /home/$USER/proxy.sh
			gksu -m "$msg" "mv /home/$USER/proxy.sh $PROFD"
			if [[ -f $PROFD/proxy.sh ]]; then
				gksu -m "$msg" "chmod +x $PROFD/proxy.sh"
				gksu -m "$msg" "chown root:root $PROFD/proxy.sh"
				source $PROFD/proxy.sh
				zenity --info --text="$(gettext 'Proxy set successfully')"
				exit 0
			else
				zenity --error --text="$(gettext 'The proxy is not set')"
				exit 1
			fi
			exit
		;;
	esac
}

function removeproxy () { # Remove proxy
	loadconf
	if [[ ! -f $PROFD/proxy.sh ]]; then zenity --error --text="$(gettext 'The proxy is not set')"; exit 1; fi
	zenity --title="Proxy" --question --text="$(gettext 'Do you really want remove proxy?')"
	case $? in
		0)
			gksu -m "$msg" "rm -f $PROFD/proxy.sh"
			unset http_proxy
			unset https_proxy
			unset ftp_proxy
			if [[ $? = 0 ]]; then zenity --info --text="$(gettext 'Proxy removed')"; exit 0; fi
		;;
		*) exit 1;;
	esac
}

function testconnect () { # Test Connectivity
	loadconf
	if [[ -f $PROFD/proxy.sh ]]; then 
		source $PROFD/proxy.sh
		echo exit | $(which telnet) $PROXYHOST $PROXYPORT
		if [[ $? = 0 ]]; then
			zenity --info --text="Test Proxy $PROXYHOST:$PROXYPORT Connection OK" 
		else
			zenity --error --text="Test Proxy $PROXYHOST:$PROXYPORT Connection FAILED"
			exit 1
		fi	
	fi
	$(which wget) -O/dev/null http://$URL -T 5 -t 2 --no-cache | zenity --title="$(gettext 'Test Connectivity')" --progress --auto-kill --text="$(gettext 'Contact') http://$URL ..." --pulsate --auto-close
	if [[ $? = 0 ]]; then http_check=OK; else http_check=FAIL; fi
	$(which wget) -O/dev/null https://$URL -T 5 -t 2 --no-cache | zenity --title="$(gettext 'Test Connectivity')" --progress --auto-kill --text="$(gettext 'Contact') https://$URL ..." --pulsate --auto-close
	if [[ $? = 0 ]]; then https_check=OK; else https_check=FAIL; fi
	if [[ ( $http_check = FAIL ) && ( $https_check = FAIL ) ]]; then zenity --error --text="$(gettext 'Test Connectivity FAILED')"; exit 1; fi
	if [[ ( $http_check = OK ) && ( $https_check = OK ) ]]; then zenity --info --text="$(gettext 'Test Connectivity OK')"; exit 0; fi
	if [[ ( $http_check = OK ) || ( $https_check = OK ) ]]; then zenity --info --text="$(gettext 'Test Connectivity:')\nHTTP $http_check\nHTTPS $http_check\n"; exit 0; fi
}

function pacoptimize () { # Pacman Optimize
	loadconf
	pacmanrun
	gksu -m "$msg" "pacman-optimize" | zenity --title="Pacman Optimize" --progress --auto-kill --auto-close --text="$(gettext 'Command'): $ sudo pacman-optimize" --pulsate
	if [[ $? = 0 ]]; then
		zenity --info --text="$(gettext 'Pacman Optimized')"
		exit 0
	else
		zenity --error --text="$(gettext 'Pacman not Optimized')"
		exit 1
	fi	
}

function pacdbupgrade () { # pacman-db-upgrade
	loadconf
	pacmanrun
	gksu -m "$msg" "pacman-db-upgrade" | zenity --title="Pacman DB Upgrade" --progress --auto-kill --auto-close --text="$(gettext 'Command'): $ sudo pacman-db-upgrade" --pulsate
	if [[ $? = 0 ]]; then
		zenity --info --text="$(gettext 'Pacman DB Upgraded')"
		exit 0
	else
		zenity --error --text="$(gettext 'Pacman DB not Upgraded')"
		exit 1
	fi
}

function dependencies () { # Remove Dependencies
	loadconf
	pacmanrun
	if [[ -f /tmp/list_dependencies ]]; then rm -f /tmp/list_dependencies; fi
	yaourt -Qdtq > /tmp/list_dependencies
	check_dep=$(cat /tmp/list_dependencies | wc -l)
	if [[ "$check_dep" = 0 ]]; then 
		if [[ -z $dep_count ]]; then
			zenity --error --text="$(gettext 'No Dependencies to be removed')"
			exit 1
		else
			zenity --info --text="$(gettext 'All Dependencies have been removed')"
			exit 0
		fi 
	fi
	zenity --cancel-label="$(gettext 'Abort')" --ok-label="$(gettext 'Remove')" --list --title="$(gettext 'Dependencies')" --text="$check_pkg $(gettext 'Dependencies to be removed:')" --column="$(gettext 'Packages')" $(cat /tmp/list_dependencies) --separator=" "
	case $? in
		0)
			yaourt -R $(yaourt -Qdtq) --noconfirm | zenity --title="$(gettext 'Remove Dependencies')" --progress --auto-kill --text="$(gettext 'Remove Dependencies')..." --pulsate --auto-close
			dep_count=1
			dependencies
		;;
		*) exit 1;;
	esac
}

function infopkg () { # Info Pkg
	loadconf
	pacmanrun
	if [[ -f /tmp/list_pkgdisp ]]; then rm -f /tmp/list_pkgdisp; fi
	if [[ -f /tmp/pkg_info ]]; then rm -f /tmp/pkg_info; fi
	yaourt -Qq > /tmp/list_pkgdisp
	pkgname=$(zenity --height="400" --width="300" --list --title "$(gettext 'Select Packages')" --text "$(gettext 'Available Packages'):" --radiolist --column="$(gettext 'Pick')" --column="$(gettext 'Packages')" $(for i in $(seq 1 $(cat /tmp/list_pkgdisp | wc -l)); do echo "FALSE $(cat /tmp/list_pkgdisp | sed -n "$i"p)"; done) --separator=" ")
	if [[ -z $pkgname ]]; then exit 1; fi
	yaourt -Qi $pkgname > /tmp/pkg_info
	zenity --title="Info $pkgname" --text-info --width="600" --height="500" --filename="/tmp/pkg_info"
	exit 0
}

function pacmanlock () { # remove /var/lib/pacman/db.lck
	loadconf
	if [[ ! -f /var/lib/pacman/db.lck ]]; then zenity --info --text="$(gettext 'Good Notice! Pacman is not locked!')\n/var/lib/pacman/db.lck $(gettext 'not exist')"; exit 0; fi
	zenity --title="Pacman DB Unlock" --question --text="$(gettext 'Delete /var/lib/pacman/db.lck and kill Pacman process is more Dangerous.')\n$(gettext 'Are you sure to be continued?')"
	if [[ $? = 0 ]]; then
		gksu -m "$msg" "killall -9 pacman" 
		gksu -m "$msg" "rm -f /var/lib/pacman/db.lck"
		zenity --info --text="$(gettext 'Pacman is now unlocked!')"
	fi
}

function rempkg () { # Remove pkg
	loadconf
	pacmanrun
	if [[ -f /tmp/list_pkgrm ]]; then rm -f /tmp/list_pkgrm; fi
	pkgnmrm=$(zenity --title="$(gettext 'Remove Packages')" --text="$(gettext 'Insert package/s name to be removed:')" --entry --entry-text="pkgname1 pkgname2" --extra-button="$(gettext 'Available Packages')" --ok-label="$(gettext 'Remove')" --cancel-label="$(gettext 'Abort')")
	if [[ $? = 0 ]]; then
		$XTERM "yaourt -R $pkgnmrm; echo ""; read -sp \"$(gettext 'Press Enter to close the window') \""
		exit 0
	else
		if [[ ! -z $pkgnmrm ]]; then 
			yaourt -Qqe > /tmp/list_pkgrm
			pkgnamerm=$(zenity --height="400" --width="300" --list --title "$(gettext 'Select Packages')" --text "$(gettext 'Select Packages to be removed')\n\n$(gettext 'Available Packages'):" --checklist --column="$(gettext 'Pick')" --column="$(gettext 'Packages')" $(for i in $(seq 1 $(cat /tmp/list_pkgrm | wc -l)); do echo "FALSE $(cat /tmp/list_pkgrm | sed -n "$i"p)"; done) --separator=" " --multiple)
			if [[ -z $pkgnamerm ]]; then exit 1; fi
			$XTERM "yaourt -R $pkgnamerm; echo ""; read -sp \"$(gettext 'Press Enter to close the window') \""
			exit 0
		else
			exit 1
		fi
	fi
}

function clearcache () { # Clear Cache
	loadconf
	pacmanrun
	$XTERM "echo -e '$RED$(gettext '==> Press CTRL + C to Exit')\n$NC'; yaourt -Scc; echo ""; read -sp \"$(gettext 'Press Enter to close the window') \""
}

function pacdiffv () { # pacdiffviewer
	loadconf
	$XTERM "echo -e '$RED$(gettext '==> Press CTRL + C to Exit')\n$NC'; pacdiffviewer; echo ""; read -sp \"$(gettext 'Press Enter to close the window') \""
}

function yaourtstats () { # Yaourt Stats
	loadconf
	pacmanrun
	#$XTERM "echo -e '$RED$(gettext '==> Press CTRL + C to Exit')\n$NC'; yaourt --stats; echo ""; read -sp \"$(gettext 'Press Enter to close the window') \""
	yaourt --stats | zenity --text-info --title="Yaourt Statistics" --height="500" --width="500"
}

function restorepref () { # Restore Preference
	zenity --question --title="$(gettext 'Restore Preference')" --text="$(gettext 'Do you want restore /etc/yaourt-gui.conf?')" --ok-label="$(gettext 'Restore')"
	case $? in
		0) 
			gksu -m "$msg" "cp -frp $CONFIG/yaourt-gui.conf.default /etc/yaourt-gui.conf"
			rm -f ~/.yaourt-gui.init
			zenity --info --text="$(gettext 'Restore completed')"
			menupref
		;;
		*) menupref;;
	esac
}

function menupref () { # Preference menu
	loadconf
	prefimg=$IMGDIR/pref.png
	if [[ -z $SEDITOR ]]; then SEDITOR="null"; fi
	if [[ -z $GTKEDITOR ]]; then GTKEDITOR="null"; fi
	if [[ -z $URL ]]; then URL="www.archlinux.org"; fi
	if [[ -z $USEPAMAC ]]; then USEPAMAC=false; fi
	if [[ -f $PAMACBIN ]]; then ISPAMAC=true; STSINSTPAMC=" "; else ISPAMAC=false; STSINSTPAMC="($(gettext 'Not Installed'))"; fi
	export PREFMAIN='
	<window title="'$(gettext 'Preference')'"  window_position="1" icon-name="yaourtgui" border-width="0">
		<vbox>
			<pixmap><input file>'$IMGDIR/pref.png'</input></pixmap>
			<text><label>'$(gettext 'Configure your preference')'</label></text>
		  <frame '$(gettext 'Editor')'>
			<hbox>
				<text use-markup="true"><label>'$(gettext 'Shell Editor')'</label></text>
			  <entry>
				<variable>SEDITOR</variable>
				<default>'$SEDITOR'</default>
			  </entry>
			  <button>
				<input file stock="gtk-open"></input>
				<action type="fileselect">SEDITOR</action>
			  </button>
			</hbox>
			<hbox>
				<text use-markup="true"><label>'$(gettext 'GTK Editor')'</label></text>
			  <entry>
				<variable>GTKEDITOR</variable>
				<default>'$GTKEDITOR'</default>
			  </entry>
			  <button>
				<input file stock="gtk-open"></input>
				<action type="fileselect">GTKEDITOR</action>
			  </button>
			</hbox>
			</frame>
			<frame '$(gettext 'Check Connection')'>
			<hbox>
				<text use-markup="true"><label>"URL http://"</label></text>
			  <entry>
				<variable>URL</variable>
				<default>'$URL'</default>
			  </entry>
			</hbox>
			</frame> 
			<frame '$(gettext 'Installation Metod')'>
				<checkbox>
					<label>"'$(gettext 'Use Pamac')' '$STSINSTPAMC'"</label>
					<variable>USEPAMAC</variable>
					<default>'$USEPAMAC'</default>
					<sensitive>'$ISPAMAC'</sensitive>
				</checkbox>
			</frame>
			<frame>
			<button><label>'$(gettext 'Restore Preference')'</label><action type="exit">RESTORE</action></button>
			</frame>
			<hbox>
				<button><label>'$(gettext 'Save')'</label><input file icon="gtk-ok"></input><action type="exit">OK</action></button>
				<button><label>'$(gettext 'Abort')'</label><input file icon="editdelete"></input><action type="exit">abort</action></button>
			</hbox>
		 </vbox>
	</window>
	'
	VALUE=$(gtkdialog --program=PREFMAIN)
	export $VALUE
	#echo $VALUE # for debug
	if [[ "$EXIT" == "\"abort\"" ]]; then exit 1; fi
	if [[ "$EXIT" == "\"RESTORE\"" ]]; then restorepref; fi
	if [[ ( -z $URL ) || ( "$URL" == '"''"' ) ]]; then URL=www.archlinux.org; fi
	if [[ ( -z $SEDITOR ) || ( $SEDITOR == null ) ]]; then SEDITOR=""; fi
	if [[ -z $GTKEDITOR || ( $GTKEDITOR == null ) ]]; then GTKEDITOR=""; fi
	gksu -m "$msg" "cp -f /etc/yaourt-gui.conf /etc/yaourt-gui.conf.bk"
	gksu -m "$msg" "cat $CONFIG/yaourt-gui.conf.default | sed -e 's/SEDITOR=/SEDITOR=$SEDITOR/g' | sed -e 's/GTKEDITOR=/GTKEDITOR=$GTKEDITOR/g' | sed -e 's/URL=www.archlinux.org/URL=$URL/g' | sed -e 's/USEPAMAC=false/USEPAMAC=$USEPAMAC/g' > /etc/yaourt-gui.conf"
}

function edittermpac () { # Edit terminal pacman.conf
	loadconf
	if [[ -z $SEDITOR ]]; then 
		SEDITOR=nano
	fi
	$XTERM "sudo $SEDITOR /etc/pacman.conf"
	exit 0
}

function edittermyaourt () { # Edit terminal yaourtrc
	loadconf
	if [[ -z $SEDITOR ]]; then 
		SEDITOR=nano
	fi
	$XTERM "sudo $SEDITOR /etc/yaourtrc"
	exit 0
}

function editgtkpac () { # Edit GTK pacman.conf
	loadconf
	if [[ -z $GTKEDITOR ]]; then 
		editerrorp=$(zenity --extra-button="$(gettext 'Set Now')" --title="$(gettext 'Error')" --error --text="$(gettext 'No Graphic Editor set in /etc/yaourt-gui.conf')")
		if [[ ( $? != 0 ) && ( ! -z $editerrorp ) ]]; then
			menupref
			exit 0
		else
			exit 0
		fi
	fi	
	gksu -m "$msg" "$GTKEDITOR /etc/pacman.conf"
	exit 0
}

function editgtkyaourt () { # Edit GTK yaourtrc
	loadconf
	if [[ -z $GTKEDITOR ]]; then 
		editerrory=$(zenity --extra-button="$(gettext 'Set Now')" --title="$(gettext 'Error')" --error --text="$(gettext 'No Graphic Editor set in /etc/yaourt-gui.conf')")
		if [[ ( $? != 0 ) && ( ! -z $editerrory ) ]]; then
			menupref
			exit 0		
		else
			exit 0
		fi
	fi	
	gksu -m "$msg" "$GTKEDITOR /etc/yaourtrc"
	exit 0
}

function backupkg () { # Backup PKG List
	loadconf
	pacmanrun
	pathsave=$(zenity --title="$(gettext 'Select Folder')" --file-selection --directory)
	if [[ ( $? = 0 ) || ( ! -z $pathsave ) ]]; then
		data=$(date +%F)
		yaourt -Qqe > "$pathsave/packages_list-"$data".txt"
		if [[ -f "$pathsave/packages_list-"$data".txt" ]];then 
			chown "$USER".users "$pathsave/packages_list-"$data".txt"
			zenity --info --text="$(gettext 'Backup Packages List completed')"
		else 
			zenity --error --text="$(gettext 'Backup Packages List not saved')"
			exit 1
		fi
	else
		exit 1
	fi
}

function belongfile () { # Belongs file
	belogsearch=$(zenity --title="$(gettext 'Belongs to files')" --text="$(gettext 'Insert file name or command to be search:')" --entry --extra-button="$(gettext 'Select')" --ok-label="$(gettext 'Search')" --cancel-label="$(gettext 'Abort')")	
	if [[ $? = 0 ]]; then
		if [[ -z $belogsearch ]]; then belongfile; fi
		resultbtf=$(yaourt -Qo $belogsearch)
		zenity --info --text="$resultbtf"
		exit 0
	elif [[ ( $? = 1 ) && ( ! -z $belogsearch ) ]]; then
		pathfile=$(zenity --title="$(gettext 'Select File')" --file-selection)
		if [[ $? = 0 ]]; then
			resultbtf=$(yaourt -Qo $pathfile)
			if [[ -z $resultbtf ]]; then
				zenity --error --text="$(gettext 'No package owns') $pathfile"
				exit 1
			else
				zenity --info --text="$resultbtf"
				exit 0
			fi			
		else
			belongfile
		fi
	else
		exit
	fi
}

function pamacfunc () { # Use Pamac-manager
	if [[ -f $PAMACBIN ]]; then
		$PAMACBIN
		exit 0
	else
		checkpamac=$(zenity --error --text="$(gettext 'Pamac not installed')" --extra-button="$(gettext 'Install Pamac')" --ok-label="$(gettext 'Exit')")
		if [[ ! -z $checkpamac ]]; then $XTERM "yaourt -S pamac-aur; echo ""; read -sp \"$(gettext 'Press Enter to close the window') \"";fi
		exit 1
	fi
}

function installpkg () { # Install packages
	loadconf
	pacmanrun
	if [[ "$USEPAMAC" == "true" ]]; then pamacfunc; fi
	export INSPKG='
	<window title="'$(gettext 'Install Packages')'"  window_position="1" icon-name="yaourtgui" border-width="0">
		<vbox>
			<pixmap><input file>'$IMGDIR/installation.png'</input></pixmap>
			<text use-markup="true"><label>"<b>'$(gettext 'Install one or more packages')'</b>"</label></text>	
		  <frame>
		  <text><label>'$(gettext 'Package/s Name:')'</label> </text>
			<hbox>	
			  <entry>
				<variable>PKG</variable>
			  </entry>
			</hbox>
			<hbox>
			<text><label>'$(gettext 'In case of multiple-choice enter a space between the one and the other package/s name.')'</label></text>
			</hbox>
			</frame>
			<frame '$(gettext 'Command:')'>
				<text><label>"$ yaourt -S pkgname1 pkgname2"</label></text>
			</frame>
			<hbox>
				<button><label>'$(gettext 'Install')'</label><input file icon="gtk-ok"></input><action type="exit">INSTALL</action></button>
				<button><label>'$(gettext 'Abort')'</label><input file icon="editdelete"></input><action type="exit">abort</action></button>
			</hbox>
		 </vbox>
	</window>
	'
	VALUEP=$(gtkdialog --program=INSPKG)
	export $VALUEP
	if [[ "$EXIT" == "\"abort\"" ]]; then exit 1; fi
	if [[ ( -z $PKG ) || ( "$PKG" == '"''"' ) ]]; then exit 1; fi
	$XTERM "yaourt -S $PKG; echo ""; read -sp \"$(gettext 'Press Enter to close the window') \""
}

function searchinst () { # Search and install packages
	loadconf
	pacmanrun
	if [[ "$USEPAMAC" == "true" ]]; then pamacfunc; fi
	export INSRCPKG='
	<window title="'$(gettext 'Install Packages')'"  window_position="1" icon-name="yaourtgui" border-width="0">
		<vbox>
			<pixmap><input file>'$IMGDIR/installation.png'</input></pixmap>
			<text use-markup="true"><label>"<b>'$(gettext 'Search and install one or more packages')'</b>"</label></text>	
		  <frame>
		  <text><label>'$(gettext 'Insert Keyword to find:')'</label> </text>
			<hbox>	
			  <entry>
				<variable>KEYV</variable>
			  </entry>
			</hbox>
			<hbox>
			<text><label>'$(gettext 'Example: firefox, tor-browser, XFCE, ecc')'</label></text>
			</hbox>
			</frame>
			<frame '$(gettext 'Command:')'>
				<text><label>"$ yaourt '$(gettext 'keyword')'"</label></text>
			</frame>
			<hbox>
				<button><label>'$(gettext 'Search and Install')'</label><input file icon="gtk-ok"></input><action type="exit">INSTALL</action></button>
				<button><label>'$(gettext 'Abort')'</label><input file icon="editdelete"></input><action type="exit">abort</action></button>
			</hbox>
		 </vbox>
	</window>
	'
	VALUEPS=$(gtkdialog --program=INSRCPKG)
	export $VALUEPS
	if [[ "$EXIT" == "\"abort\"" ]]; then exit 1; fi
	if [[ ( -z $KEYV ) || ( "$KEYV" == '"''"' ) ]]; then exit 1; fi
	$XTERM "yaourt $KEYV; echo ""; read -sp \"$(gettext 'Press Enter to close the window') \""
}


function restorepkg () { # Restore Pkglist
	zenity --error --text="Sorry! This feature is not available.\nFor restore run:\n\n\$ yaourt -S \$(cat /path/filelist)"
	exit 0
}

# Start Action
$1

# end script
