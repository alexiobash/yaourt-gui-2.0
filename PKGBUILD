# Maintainer: alexiobash < me (at) alexiobash (dot) com >

pkgname=yaourt-gui
pkgver=2.0
pkgrel=1
pkgdesc="A Bash and GTK GUI for Yaourt and Pacman - Replace Pacmind"
arch=('any')
url="https://github.com/alexiobash/yaourt-gui/wiki"
license=('GPL')
depends=('yaourt' 'sudo' 'gettext' 'gtkdialog' 'zenity' 'xterm' 'lsb-release' 'gksu' 'wget' 'inetutils' 'hicolor-icon-theme')
conflicts=('yaourt-gui-manjaro')
optdepends=(
    'aurvote: Tool to vote for favorite AUR packages'
    'pamac-aur: A Gtk3 frontend for libalpm'
)
backup=('etc/yaourt-gui.conf' 'usr/share/yaourt-gui/script/yglogo.sh')
source=("$pkgname::git+https://github.com/alexiobash/$pkgname.git")
install="${pkgname}.install"
md5sums=('SKIP')

package() {
	cd $srcdir/$pkgname
	make DESTDIR=${pkgdir} install
}

