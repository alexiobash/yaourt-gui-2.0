# yaourt-gui-2.0
To modify Yaourt-Gui logo edit file: /usr/share/yaourt-gui/yglogo.sh

For Proxy settings add in your ~/.bashrc or /etc/bash.bashrc:

if [ -f /etc/profile.d/proxy.sh ]; then 
	source /etc/profile.d/proxy.sh
else
	unset http_proxy
	unset https_proxy
	unset ftp_proxy
fi

and add in /etc/sudoers:

Defaults env_keep = "http_proxy https_proxy ftp_proxy"

To modify Yaourt-Gui preference edit file: /etc/yaourt-gui.conf
	
==> WARNING <==
Run this command (normal user) if you not have root provileges
or not using sudo without password:

$ sed -e s/USER/$USER/g /usr/share/yaourt-gui/yaourt-gui.sudo | sudo tee /etc/sudoers.d/yaourt-gui


