#!/bin/bash
# Yaourt-Gui is a bash and GTK gui for yaourt and Pacman
#
# Creation-Date: 2015-06-26
#
# Support: https://alexiobash.com
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
VER=$(cat $CONFIG/RELEASE)

# Export for languages
export TEXTDOMAINDIR=/usr/share/locale
export TEXTDOMAIN=yaourt-gui

# Load Yaourt-GUI conf
source /etc/yaourt-gui.conf

# Check Distro
source /etc/lsb-release
case $DISTRIB_ID in
	ManjaroLinux|Manjaro) logo="$IMGDIR/logo_manjaro.png";;
	*) logo="$IMGDIR/logo_archlinux.png";;
esac
if [[ ! -z $EE ]]; then logo="$IMGDIR/ee.gif"; fi

# Function
sync_db="$SCRIPT/function.sh sync_db > /dev/null 2>&1 &"
updatepkg="$SCRIPT/function.sh updatepkg > /dev/null 2>&1 &"
fullupdate="$SCRIPT/function.sh fullupdate > /dev/null 2>&1 &"
forceupdate="$SCRIPT/function.sh fullupdate force > /dev/null 2>&1 &"
dependencies="$SCRIPT/function.sh dependencies > /dev/null 2>&1 &"
setproxy="$SCRIPT/function.sh setproxy > /dev/null 2>&1 &"
removeproxy="$SCRIPT/function.sh removeproxy > /dev/null 2>&1 &"
backupkg="$SCRIPT/function.sh backupkg > /dev/null 2>&1 &"
testconnect="$SCRIPT/function.sh testconnect > /dev/null 2>&1 &"
pacdbupgrade="$SCRIPT/function.sh pacdbupgrade > /dev/null 2>&1 &"
pacoptimize="$SCRIPT/function.sh pacoptimize > /dev/null 2>&1 &"
infopkg="$SCRIPT/function.sh infopkg > /dev/null 2>&1 &"
pacmanlock="$SCRIPT/function.sh pacmanlock > /dev/null 2>&1 &"
infomain="gtkdialog --program=INFOMAIN > /dev/null 2>&1 &"
proxymain="gtkdialog --program=PROXYMAIN > /dev/null 2>&1 &"
rempkg="$SCRIPT/function.sh rempkg > /dev/null 2>&1 &"
clearcache="$SCRIPT/function.sh clearcache > /dev/null 2>&1 &"
pacdiffv="$SCRIPT/function.sh pacdiffv > /dev/null 2>&1 &"
logpacman="gtkdialog --program=LOGPACMAN > /dev/null 2>&1 &"
editpac="gtkdialog --program=EDITPACMAN > /dev/null 2>&1 &"
edityaourt="gtkdialog --program=EDITYAOURT > /dev/null 2>&1 &"
editpacterm="$SCRIPT/function.sh edittermpac > /dev/null 2>&1 &"
editpacx="$SCRIPT/function.sh editgtkpac > /dev/null 2>&1 &"
edityaouterm="$SCRIPT/function.sh edittermyaourt > /dev/null 2>&1 &"
edityaoux="$SCRIPT/function.sh editgtkyaourt > /dev/null 2>&1 &"
yaourtstats="$SCRIPT/function.sh yaourtstats > /dev/null 2>&1 &"
editpref="$SCRIPT/function.sh menupref > /dev/null 2>&1 &"
restorepkg="$SCRIPT/function.sh restorepkg > /dev/null 2>&1 &"
helpcommand="gtkdialog --program=HELPCOMMAND > /dev/null 2>&1 &"
belongfile="$SCRIPT/function.sh belongfile > /dev/null 2>&1 &"
installpkg="$SCRIPT/function.sh installpkg > /dev/null 2>&1 &"
searchinst="$SCRIPT/function.sh searchinst > /dev/null 2>&1 &"
initmessage="$SCRIPT/function.sh initmessage off > /dev/null 2>&1 &"

# Frist init message
if [[ ! -f ~/.yaourt-gui.init ]]; then
	$SCRIPT/function.sh initmessage > /dev/null 2>&1
fi 

export HELPCOMMAND='
<window title="'$(gettext 'Edit')' pacman.conf"  window_position="1" icon-name="yaourtgui" border-width="0">
	<vbox>
		<pixmap><input file>'$logo'</input></pixmap>
		<text use-markup="true"><label>'$(gettext 'For more information about Pacman and Yaourt see Official Wiki')'</label> </text>
		<table>
			<width>1000</width><height>400</height>
			<label>"'$(gettext 'Command')''$( echo -e "\t\t\t\t\t")'|'$(gettext 'Description')'"</label>
			<item>"yaourt -Sy |'$(gettext 'To synchronize DB')'"</item>
			<item>"yaourt -Sua |'$(gettext 'To update the system')'"</item>
			<item>"yaourt -Sua --force |'$(gettext 'To update the system in force mode')'"</item>
			<item>"yaourt -S <pkgname> |'$(gettext 'To install a packages')'"</item>
			<item>"yaourt -R <pkgname> |'$(gettext 'To remove a packages')'"</item>
			<item>"yaourt -U <pkgname> |'$(gettext 'To update a packages')'"</item>
			<item>"yaourt -R $(yaourt -Qdtq) |'$(gettext 'To remove unused dependencies')'"</item>
			<item>"yaourt -Ss <keywords> |'$(gettext 'To search a packages')'"</item>
			<item>"yaourt <keywords> |'$(gettext 'To search and install a packages')'"</item>
			<item>"yaourt -Qo <command> |'$(gettext 'To view a file belonging')'. ex: $ yaourt -Qo ls"</item>
			<item>"yaourt -Qi <pkgname> |'$(gettext 'To query local database e info packages')'"</item>
			<item>"yaourt -Scc |'$(gettext 'To clean a cache')'"</item>
			<item>"yaourt -C |'$(gettext 'To Manage .pac* files')'"</item>
			<item>"sudo pacdiffviewer |'$(gettext 'To Manage .pac* files')'"</item>
			<item>"sudo pacman-db-upgrade |'$(gettext 'To run pacman-db-upgrade')'"</item>
			<item>"sudo pacman-optimize |'$(gettext 'To optimize pacman')'"</item>
			<item>"yaourt --stats |'$(gettext 'To see the statistic of yaourt')'"</item>
			<item>"yaourt -Rdd <pkgname> |'$(gettext 'To remove a package, which is required by another package, without removing the dependent package')'"</item>
			<item>"yaourt -Rn <pkgname> |'$(gettext 'To remove packages whitout .pacsave creation')'"</item>
			<item>"yaourt -Sg <groupname> |'$(gettext 'To see what packages belong to the group')'. ex: $ yaourt -Sg gnome"</item>
			<item>"yaourt -Qqe > ~/pkg_list.txt |'$(gettext 'To backup list of installed packages')'"</item>
			<item>"yaourt -Sy $(cat ~/pkg_list.txt) |'$(gettext 'To restore')'"</item>
		</table>
		<hbox>
			<button><label>'$(gettext 'Exit')'</label><input file icon="editdelete"></input><action type="exit">exit 0</action></button>
		</hbox>
	</vbox>
</window>
'

export EDITPACMAN='
<window title="'$(gettext 'Edit')' pacman.conf"  window_position="1" icon-name="yaourtgui" border-width="0">
	<vbox>
		<frame>
				<text use-markup="true"><label>'$(gettext 'Edit the Pacman Preference (/etc/pacman.conf)')'</label> </text>
				<button>
					<input file>'$IMGDIR/terminal.png'</input>
					<label>'$(gettext 'Edit in Terminal')'</label>
					<action>'$editpacterm'</action>
				</button>
				<button>
					<input file>'$IMGDIR/editgtk.png'</input>
					<label>'$(gettext 'Use your graphic editor')'</label>
					<action>'$editpacx'</action>
				</button>
				<hbox>
					<button><label>'$(gettext 'Exit')'</label><input file icon="editdelete"></input><action type="exit">exit 0</action></button>
				</hbox>
		</frame>
	</vbox>
</window>
'

export EDITYAOURT='
<window title="'$(gettext 'Edit')' yaourtrc"  window_position="1" icon-name="yaourtgui" border-width="0">
	<vbox>
		<frame>
				<text use-markup="true"><label>'$(gettext 'Edit the Yaourt Preference (/etc/yaourtrc)')'</label> </text>
				<button>
					<input file>'$IMGDIR/terminal.png'</input>
					<label>'$(gettext 'Edit in Terminal')'</label>
					<action>'$edityaouterm'</action>
				</button>
				<button>
					<input file>'$IMGDIR/editgtk.png'</input>
					<label>'$(gettext 'Use your graphic editor')'</label>
					<action>'$edityaoux'</action>
				</button>
				<hbox>
					<button><label>'$(gettext 'Exit')'</label><input file icon="editdelete"></input><action type="exit">exit 0</action></button>
				</hbox>
		</frame>
	</vbox>
</window>
'

export LOGPACMAN='
<window title="Pacman Log"  window_position="1" icon-name="yaourtgui" border-width="0">
	<vbox>
		<frame>
				<text use-markup="true"><label>'$(gettext 'View pacman log: /var/log/pacman.log')'</label> </text>
				<button>
					<input file>'$IMGDIR/log.png'</input>
					<label>'$(gettext 'View Log')'</label>
					<action>cat /var/log/pacman.log | zenity --text-info --width=700 --height=500 --title="/var/log/pacman.log" &</action>
				</button>
				<text use-markup="true"><label>'$(gettext 'or insert Keyword to find:')'</label> </text>
				<entry><variable>FIND</variable></entry>
				<hbox>
					<button>
						<input file>'$IMGDIR/find.png'</input>
						<label>'$(gettext 'Search')'</label>
						<action>cat /var/log/pacman.log | grep "$FIND" | zenity --text-info  --width=700 --height=500 --title="/var/log/pacman.log" &</action>
					</button>
					<button><label>'$(gettext 'Exit')'</label><input file icon="editdelete"></input><action type="exit">exit 0</action></button>
				</hbox>
		</frame>
	</vbox>
</window>
'

export PROXYMAIN='
<window title="'$(gettext 'Proxy Settings')'"  window_position="1" icon-name="yaourtgui" border-width="0">
	<vbox>
		<hbox>
		<frame>
			<pixmap><input file>'$IMGDIR/proxy.png'</input></pixmap>
		</frame>
		<frame>
			<button><label>'$(gettext 'Set Proxy')'</label><action signal="clicked">'$setproxy'</action></button>
			<button><label>'$(gettext 'Remove Proxy')'</label><action signal="clicked">'$removeproxy'</action></button>
			<button><label>'$(gettext 'Test Connettivity')'</label><action signal="clicked">'$testconnect'</action></button>
		</frame>
		</hbox>
		<hbox>
			<button><label>'$(gettext 'Exit')'</label><input file icon="editdelete"></input><action type="exit">exit 0</action></button>
		</hbox>
	</vbox>
</window>
'

export INFOMAIN='
<window title="Info Yaourt-Gui GTK"  window_position="1" icon-name="yaourtgui" border-width="0">
	<vbox>
		<frame>
			<pixmap><input file>'$IMGDIR/yaourtgui.png'</input></pixmap>
			<text use-markup="true"><label>"<b>Yaourt-Gui '$VER'</b>"</label> </text>
			<text use-markup="true"><label>"<b>A Bash and GTK GUI for Yaourt and Pacman</b>"</label></text>
		</frame>
		<frame Description>
			<text use-markup="true"><label>"Designed for new users who want to start using Arch Linux. Written in Bash, Zenity and GTKDialog, it offers a GUI to the common tasks of yaourt and pacman."</label></text>
		</frame>
		<frame Credits>
			<text use-markup="true"><label>"<b>AlexioBash</b>"</label></text>
			<text use-markup="true"><label>"www.alexiobash.com"</label></text>
			<text use-markup="true"><label>"me@alexiobash.com"</label></text>
		</frame>
		<frame Special Thanks>
			<text use-markup="true"><label>"<b>Tomberry</b> tomberro@gmail.com"</label> </text>
			<text use-markup="true"><label>"<b>XFCE-ITALIA</b> Community www.xfce-italia.it"</label> </text>
		</frame>
		<hbox>
			<button><label>'$(gettext 'Exit')'</label><input file icon="editdelete"></input><action type="exit">exit 0</action></button>
		</hbox>
	</vbox>
</window>
'

export MAIN='
<window title="Yaourt-Gui GTK"  window_position="1" icon-name="yaourtgui" border-width="0">
	<vbox>
		<menubar>
			<menu label="_File" use-underline="true">
				<menuitem stock-id="gtk-quit" accel-key="0x51" accel-mods="4">
					<action>exit:Quit</action>
				</menuitem>
			</menu>
			<menu label="_'$(gettext 'Options')'" use-underline="true">
				<menuitem label="'$(gettext 'Preference')'">
					<action>'$editpref'</action>
				</menuitem>
				<menuitem label="'$(gettext 'Configure Proxy')'">
					<action>'$proxymain'</action>
				</menuitem>
			</menu>			
			<menu label="_'$(gettext 'Help')'" use-underline="true">
				<menuitem stock-id="gtk-about" label="'$(gettext 'About Yaourt-Gui GTK')'">
					<action>'$infomain'</action>
				</menuitem>
				<menuitem stock-id="gtk-about" label="'$(gettext 'Command help')'">
					<action>'$helpcommand'</action>
				</menuitem>
				<menuitem stock-id="gtk-about" label="'$(gettext 'Initial Message')'">
					<action>'$initmessage'</action>
				</menuitem>
			</menu>
		</menubar>
<notebook labels="Home|'$(gettext 'Advanzed')'">
<vbox>
	<pixmap><input file>'$logo'</input></pixmap>
	<text use-markup="true"><label>"<b>GTK frontend for Yaourt-Gui</b>"</label></text>
	<hbox>
	<frame '$(gettext 'System')'>
		<button><label>'$(gettext 'Sync DB')'</label><action signal="clicked">'$sync_db'</action></button>
		<button><label>'$(gettext 'Update System')'</label><action signal="clicked">'$fullupdate'</action></button>
		<button><label>'$(gettext 'Update force mode')'</label><action signal="clicked">'$forceupdate'</action></button>	
	</frame>
	<frame '$(gettext 'Packages')'>
		<button><label>'$(gettext 'Install Packages')'</label><action signal="clicked">'$installpkg'</action></button>
		<button><label>'$(gettext 'Search & Install')'</label><action signal="clicked">'$searchinst'</action></button>
		<button><label>'$(gettext 'Update Packages')'</label><action signal="clicked">'$updatepkg'</action></button>	
	</frame>
	<frame '$(gettext 'Remove')'>	
		<button><label>'$(gettext 'Remove Packages')'</label><action signal="clicked">'$rempkg'</action></button>
		<button><label>'$(gettext 'Remove Dependencies')'</label><action signal="clicked">'$dependencies'</action></button>
		<button><label>'$(gettext 'Clear Cache')'</label><action signal="clicked">'$clearcache'</action></button>
	</frame>
	</hbox>
	<hbox>
		<button><label>'$(gettext 'Exit')'</label><input file icon="editdelete"></input><action type="exit">exit 0</action></button>
	</hbox>
</vbox>
<vbox>
	<hbox>
	<frame Pacman Utility>
		<button><label>"Pacman DB Upgrade"</label><action signal="clicked">'$pacdbupgrade'</action></button>
		<button><label>"Pacman Optimize"</label><action signal="clicked">'$pacoptimize'</action></button>
		<button><label>'$(gettext 'Belongs To Files')'</label><action signal="clicked">'$belongfile'</action></button>
		<button><label>'$(gettext 'Info Packages')'</label><action signal="clicked">'$infopkg'</action></button>
	</frame>
	<frame '$(gettext 'Advanzed')'>
		<button><label>'$(gettext 'Unlock Pacman DB')'</label><action signal="clicked">'$pacmanlock'</action></button>
		<button><label>'$(gettext 'Edit pacman.conf')'</label><action signal="clicked">'$editpac'</action></button>
		<button><label>'$(gettext 'Edit yaourtrc')'</label><action signal="clicked">'$edityaourt'</action></button>
		<button><label>"PacDiffViewer"</label><action signal="clicked">'$pacdiffv'</action></button>
	</frame>
	</hbox>
		<hbox>
		<frame>
			<button><label>"Log Pacman"</label><action signal="clicked">'$logpacman'</action></button>
			<button><label>'$(gettext 'Yaourt Stats')'</label><action signal="clicked">'$yaourtstats'</action></button>
		</frame>
		<frame>
			<button><label>'$(gettext 'Backup pkg list')'</label><action signal="clicked">'$backupkg'</action></button>
			<button><label>'$(gettext 'Restore Pkg')'</label><action signal="clicked">'$restorepkg'</action></button>
		</frame>
		</hbox>	
</vbox>
</notebook>
</vbox>
</window>
'

gtkdialog --program=MAIN

# end script
