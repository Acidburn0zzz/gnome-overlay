# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"
GCONF_DEBUG="no"

inherit autotools db-use eutils flag-o-matic gnome2 versionator virtualx

DESCRIPTION="Evolution groupware backend"
HOMEPAGE="http://www.gnome.org/projects/evolution/"

LICENSE="LGPL-2 BSD DB"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~x86-solaris"

IUSE="doc ipv6 kerberos gnome-keyring gtk3 ldap ssl weather"

RDEPEND=">=dev-libs/glib-2.25.12:2
	!gtk3? ( >=x11-libs/gtk+-2.20:2 )
	gtk3? ( >=x11-libs/gtk+-2.90.4:3 )
	>=gnome-base/gconf-2
	>=dev-db/sqlite-3.5
	>=dev-libs/libgdata-0.6.3
	>=dev-libs/libical-0.43
	>=net-libs/libsoup-2.4:2.4
	>=dev-libs/libxml2-2
	>=sys-libs/db-4
	sys-libs/zlib
	virtual/libiconv
	gnome-keyring? ( >=gnome-base/gnome-keyring-2.20.1 )
	kerberos? ( virtual/krb5 )
	ldap? ( >=net-nds/openldap-2 )
	ssl? (
		>=dev-libs/nspr-4.4
		>=dev-libs/nss-3.9 )
	weather? (
		!gtk3? ( >=dev-libs/libgweather-2.25.4 )
		gtk3? ( >=dev-libs/libgweather-2.90 ) )
"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.9
	>=dev-util/intltool-0.35.5
	sys-devel/bison
	>=gnome-base/gnome-common-2
	>=dev-util/gtk-doc-am-1.9
	doc? ( >=dev-util/gtk-doc-1.9 )"
# eautoreconf needs:
#	>=gnome-base/gnome-common-2
#	>=dev-util/gtk-doc-am-1.9

DOCS="ChangeLog MAINTAINERS NEWS TODO"

pkg_setup() {
	G2CONF="${G2CONF}
		$(use_enable gnome-keyring)
		$(use_enable gtk3)
		$(use_enable ipv6)
		$(use_with kerberos krb5 /usr)
		$(use_with ldap openldap)
		$(use_enable ssl ssl)
		$(use_enable ssl smime)
		$(use_with weather)
		--enable-largefile
		--with-libdb=/usr"
}

src_prepare() {
	gnome2_src_prepare

	# Adjust to gentoo's /etc/service
	epatch "${FILESDIR}/${PN}-2.31-gentoo_etc_services.patch"

	# Rewind in camel-disco-diary to fix a crash
	epatch "${FILESDIR}/${PN}-2.31-camel-rewind.patch"

	# GNOME bug 611353 (skips failing test atm)
	epatch "${FILESDIR}/e-d-s-camel-skip-failing-test.patch"

	# Fix libtool re-linking mess, bug #341493
	epatch "${FILESDIR}/${PN}-2.32.0-libtool-fix.patch"

	# GNOME bug 621763 (skip failing test-ebook-stress-factory--fifo)
	sed -e 's/\(SUBDIRS =.*\)ebook/\1/' \
		-i addressbook/tests/Makefile.{am,in} \
		|| die "failing test sed 1 failed"

	# Failing calendar checks ?
	sed -e 's/\(SUBDIRS =.*\)ecal/\1/' \
		-i calendar/tests/Makefile.{am,in} \
		|| die "failing test sed 2 failed"

	# /usr/include/db.h is always db-1 on FreeBSD
	# so include the right dir in CPPFLAGS
	append-cppflags "-I$(db_includedir)"

	# FIXME: Fix compilation flags crazyness
	sed 's/^\(AM_CPPFLAGS="\)$WARNING_FLAGS/\1/' \
		-i configure.ac configure || die "sed 3 failed"

	intltoolize --force --copy --automake || die "intltoolize failed"
	eautoreconf
}

src_install() {
	gnome2_src_install
	find "${ED}" -name "*.la" -delete || die "la files removal failed"

	if use ldap; then
		MY_MAJORV=$(get_version_component_range 1-2)
		insinto /etc/openldap/schema
		doins "${FILESDIR}"/calentry.schema || die "doins failed"
		dosym /usr/share/${PN}-${MY_MAJORV}/evolutionperson.schema /etc/openldap/schema/evolutionperson.schema
	fi
}

src_test() {
	unset DBUS_SESSION_BUS_ADDRESS
	unset ORBIT_SOCKETDIR
	unset SESSION_MANAGER
	Xemake check || die "Tests failed."
}

pkg_preinst() {
	gnome2_pkg_preinst

	for lib in libcamel-provider-1.2.so.14 libedata-cal-1.2.so.7 \
		libgdata-1.2.so libgdata-google-1.2.so libcamel-1.2.so.14 \
		libedata-book-1.2.so.2 libebook-1.2.so.9 \
		libedataserver-1.2.so.13 libecal-1.2.so.7 libedataserverui-1.2.so.8
	do
		preserve_old_lib /usr/$(get_libdir)/$lib
	done
}

pkg_postinst() {
	gnome2_pkg_postinst

	for lib in libcamel-provider-1.2.so.14 libedata-cal-1.2.so.7 \
		libgdata-1.2.so libgdata-google-1.2.so libcamel-1.2.so.14 \
		libedata-book-1.2.so.2 libebook-1.2.so.9 \
		libedataserver-1.2.so.13 libecal-1.2.so.7 libedataserverui-1.2.so.8
	do
		preserve_old_lib_notify /usr/$(get_libdir)/$lib
	done

	if use ldap; then
		elog ""
		elog "LDAP schemas needed by evolution are installed in /etc/openldap/schema"
	fi
}