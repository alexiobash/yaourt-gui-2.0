SHELL = /bin/bash
INSTALL = /usr/bin/install -c
MSGFMT = /usr/bin/msgfmt
SED = /bin/sed
DESTDIR =
bindir = /usr/bin
localedir = /usr/share/locale
config = /usr/share/yaourt-gui
script = /usr/share/yaourt-gui/script
icons = /usr/share/pixmaps
icons48 = /usr/share/icons/hicolor/48x48/apps
deskdir = /usr/share/applications
imgdir = /usr/share/yaourt-gui/img
etcdir = /etc

all:

install: all
	$(INSTALL) -d $(DESTDIR)$(bindir)
	$(INSTALL) -d $(DESTDIR)$(config)
	$(INSTALL) -d $(DESTDIR)$(icons)
	$(INSTALL) -d $(DESTDIR)$(deskdir)
	$(INSTALL) -d $(DESTDIR)$(imgdir)
	$(INSTALL) -d $(DESTDIR)$(script)
	$(INSTALL) -m755 yaourt-gui $(DESTDIR)$(bindir)
	$(INSTALL) -m755 yaourt-gui.conf.default $(DESTDIR)$(etcdir)/yaourt-gui.conf
	$(INSTALL) -m755 yaourt-gui.conf.default $(DESTDIR)$(config)
	$(INSTALL) -m644 LICENSE $(DESTDIR)$(config)
	$(INSTALL) -m644 RELEASE $(DESTDIR)$(config)
	$(INSTALL) -m644 yaourt-gui.sudo $(DESTDIR)$(config)
	$(INSTALL) -m644 img/yaourtgui.png $(DESTDIR)$(icons)
	$(INSTALL) -m644 img/yaourtgui.png $(DESTDIR)$(icons48)
	$(INSTALL) -m644 Yaourt-Gui.desktop $(DESTDIR)$(deskdir)
	$(INSTALL) -m644 Yaourt-Gui-GTK.desktop $(DESTDIR)$(deskdir)
	for file in script/*.sh; \
	do \
		$(INSTALL) -m755 $$file $(DESTDIR)$(script);\
	done
	for file in img/*; \
	do \
		$(INSTALL) -m644 $$file $(DESTDIR)$(imgdir);\
	done
	for file in po/*.po; \
	do \
		lang=$$(echo $$file | $(SED) -e 's#.*/\([^/]\+\).po#\1#'); \
		$(INSTALL) -d $(DESTDIR)$(localedir)/$$lang/LC_MESSAGES; \
		$(MSGFMT) -o $(DESTDIR)$(localedir)/$$lang/LC_MESSAGES/yaourt-gui.mo $$file; \
	done
	msglang=$$(echo $(LANG) | cut -c1-2); \
	$(INSTALL) -m644 msg/yaourt-gui_$$msglang.message $(DESTDIR)$(config)/yaourt-gui.message
