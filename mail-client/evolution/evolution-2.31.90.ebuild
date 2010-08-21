# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/mail-client/evolution/evolution-2.30.2.ebuild,v 1.1 2010/06/23 14:05:13 pacho Exp $

EAPI="2"
GCONF_DEBUG="no"

inherit autotools gnome2 flag-o-matic python

DESCRIPTION="Integrated mail, addressbook and calendaring functionality"
HOMEPAGE="http://www.gnome.org/projects/evolution/"

LICENSE="GPL-2 LGPL-2 OPENLDAP"
SLOT="2.0"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"

IUSE="crypt clutter kerberos ldap networkmanager profile python ssl gstreamer gtk3 +sound"
# pst
# mono - disabled because it just crashes on startup :S

# Pango dependency required to avoid font rendering problems
# We need a graphical pinentry frontend to be able to ask for the GPG
# password from inside evolution, bug 160302
RDEPEND=">=dev-libs/glib-2.25.12
	gtk3? (
		>=x11-libs/gtk+-2.90.4:3
		>=dev-libs/libunique-2.90
		>=gnome-base/gnome-desktop-2.90
		sound? ( >=media-libs/libcanberra-0.25[gtk3] )
		>=dev-libs/libgweather-2.90.0_pre1
		>=x11-libs/libnotify-0.5.1
	)
	!gtk3? (
		>=x11-libs/gtk+-2.20.0:2
		>=dev-libs/libunique-1.1.2
		>=gnome-base/gnome-desktop-2.26.0
		sound? ( media-libs/libcanberra )
		>=dev-libs/libgweather-2.25.3
		>=x11-libs/libnotify-0.3.0
	)
	>=gnome-extra/gtkhtml-3.31.3
	x11-libs/pango
	>=gnome-extra/evolution-data-server-2.31.4[gtk3?]
	>=gnome-base/gnome-desktop-2.26.0
	>=gnome-extra/gtkhtml-3.31.90
	>=gnome-base/gconf-2
	>=gnome-base/libgnomecanvas-2
	dev-libs/atk
	>=dev-libs/libxml2-2.7.3
	>=net-libs/libsoup-2.4
	>=x11-misc/shared-mime-info-0.22
	>=x11-themes/gnome-icon-theme-2.30.2.1

	crypt? ( || (
				  ( >=app-crypt/gnupg-2.0.1-r2
					|| ( app-crypt/pinentry[gtk] app-crypt/pinentry[qt3] ) )
				  =app-crypt/gnupg-1.4* ) )
	clutter? (
		x11-libs/mx
		>=media-libs/clutter-1.0.0 )
	gstreamer? (
		>=media-libs/gstreamer-0.10
		>=media-libs/gst-plugins-base-0.10 )
	kerberos? ( virtual/krb5 )
	ldap? ( >=net-nds/openldap-2 )
	networkmanager? ( >=net-misc/networkmanager-0.7 )
	python? ( >=dev-lang/python-2.4 )
	ssl? (
		>=dev-libs/nspr-4.6.1
		>=dev-libs/nss-3.11 )"
# champlain, geoclue, gtkimageview
#	mono? ( >=dev-lang/mono-1 )
#   gtkimageview? ( >=media-libs/gtkimageview-2 ) - when released

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.16
	>=dev-util/intltool-0.35.5
	sys-devel/gettext
	sys-devel/bison
	app-text/scrollkeeper
	>=gnome-base/gnome-common-2.12.0
	>=app-text/gnome-doc-utils-0.9.1"

DOCS="AUTHORS ChangeLog* HACKING MAINTAINERS NEWS* README"
ELTCONF="--reverse-deps"

pkg_setup() {
	G2CONF="${G2CONF}
		--without-kde-applnk-path
		--enable-plugins=experimental
		--enable-image-inline
		--enable-weather
		--enable-gtk3
		$(use_enable ssl nss)
		$(use_enable ssl smime)
		$(use_enable networkmanager nm)
		$(use_enable gstreamer audio-inline)
		$(use_enable sound canberra)
		--disable-pst-import
		$(use_enable profile profiling)
		$(use_enable python)
		$(use_with ldap openldap)
		$(use_with kerberos krb5 /usr)
		--disable-contacts-map
		--disable-image-inline"

#		$(use_enable mono)
#       --enable-image-inline

	# dang - I've changed this to do --enable-plugins=experimental.  This will
	# autodetect new-mail-notify and exchange, but that cannot be helped for the
	# moment.  They should be changed to depend on a --enable-<foo> like mono
	# is.  This cleans up a ton of crap from this ebuild.
}

src_prepare() {
	gnome2_src_prepare

	# FIXME: Fix compilation flags crazyness
	sed 's/CFLAGS="$CFLAGS $WARNING_FLAGS"//' \
		-i configure.ac configure || die "sed 1 failed"

	intltoolize --force --copy --automake || die "intltoolize failed"
	eautoreconf

	# Use NSS/NSPR only if 'ssl' is enabled.
	if use ssl ; then
		sed -i -e "s|mozilla-nss|nss|
			s|mozilla-nspr|nspr|" "${S}"/configure || die "sed 1 failed"
		G2CONF="${G2CONF} --enable-nss=yes"
	else
		G2CONF="${G2CONF} --without-nspr-libs --without-nspr-includes \
			--without-nss-libs --without-nss-includes"
	fi
}

pkg_postinst() {
	gnome2_pkg_postinst

	elog "To change the default browser if you are not using GNOME, do:"
	elog "gconftool-2 --set /desktop/gnome/url-handlers/http/command -t string 'mozilla %s'"
	elog "gconftool-2 --set /desktop/gnome/url-handlers/https/command -t string 'mozilla %s'"
	elog ""
	elog "Replace 'mozilla %s' with which ever browser you use."
	elog ""
	elog "Junk filters are now a run-time choice. You will get a choice of"
	elog "bogofilter or spamassassin based on which you have installed"
	elog ""
	elog "You have to install one of these for the spam filtering to actually work"
}
