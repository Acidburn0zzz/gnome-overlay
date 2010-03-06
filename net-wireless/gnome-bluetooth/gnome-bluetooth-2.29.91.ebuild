# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/gnome-bluetooth/gnome-bluetooth-2.28.6.ebuild,v 1.3 2010/02/04 21:06:00 jer Exp $

EAPI="2"

inherit gnome2

DESCRIPTION="Fork of bluez-gnome focused on integration with GNOME"
HOMEPAGE="http://live.gnome.org/GnomeBluetooth"
LICENSE="GPL-2 LGPL-2.1"
SLOT="2"
IUSE="doc nautilus"
KEYWORDS="~amd64 ~hppa ~x86"

#TODO: Is it lies about 2.19.1 as well?
# XXX: gtk+-2.18 required, configure.ac lies, bug 298534
COMMON_DEPEND=">=dev-libs/glib-2.19.1
	>=x11-libs/gtk+-2.18
	>=x11-libs/libnotify-0.4.3
	>=gnome-base/gconf-2.6
	>=dev-libs/dbus-glib-0.74
	dev-libs/libunique
	nautilus? ( >=gnome-extra/nautilus-sendto-2.28.0.1 )"
RDEPEND="${COMMON_DEPEND}
	>=net-wireless/bluez-4.34
	app-mobilephone/obexd"
DEPEND="${COMMON_DEPEND}
	!!net-wireless/bluez-gnome
	app-text/gnome-doc-utils
	app-text/scrollkeeper
	dev-libs/libxml2
	dev-util/intltool
	dev-util/pkgconfig
	sys-devel/gettext
	x11-proto/xproto
	gnome-base/gnome-common
	dev-util/gtk-doc-am
	doc? ( >=dev-util/gtk-doc-1.9 )"

DOCS="AUTHORS README NEWS ChangeLog"

pkg_setup() {
	G2CONF="${G2CONF}
	        $(use_enable nautilus nautilus-sendto)
	        --disable-moblin
	        --disable-desktop-update
	        --disable-icon-update
	        --disable-introspection"
}
