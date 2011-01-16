# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
GCONF_DEBUG="no"

inherit autotools gnome2

DESCRIPTION="Library to access weather information from online services"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2"
SLOT="3"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="+introspection doc"

# libsoup-gnome is to be used because libsoup[gnome] might not
# get libsoup-gnome installed by the time ${P} is built
#
# Need libgweather:2 for the icons, see src_install below
RDEPEND=">=x11-libs/gtk+-2.90.0:3[introspection]
	>=dev-libs/glib-2.13
	>=gnome-base/gconf-2.8
	>=net-libs/libsoup-gnome-2.25.1:2.4
	>=dev-libs/libxml2-2.6.0
	>=sys-libs/timezone-data-2010k

	introspection? ( >=dev-libs/gobject-introspection-0.6.7 )

	!!<dev-libs/libgweather-2.30.3-r200
	!<gnome-base/gnome-applets-2.22.0"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.40.3
	>=dev-util/pkgconfig-0.19
	>=dev-util/gtk-doc-am-1.9
	sys-devel/gettext
	doc? ( >=dev-util/gtk-doc-1.9 )"
PDEPEND="dev-libs/libgweather:2"
DOCS="AUTHORS ChangeLog MAINTAINERS NEWS"

pkg_setup() {
	G2CONF="${G2CONF}
		--enable-locations-compression
		--disable-maintainer-mode
		--disable-all-translations-in-one-xml
		--disable-static"
}

src_install() {
	gnome2_src_install

	# Don't install these here, libgweather:2 also provides them
	# IMPORTANT: Don't let the files diverge
	rm -rf "${D}"/usr/share/icons || die "Removing icons failed"
	rm -rf "${D}"/usr/share/libgweather || die "Removing locations failed"
	rm -rf "${D}"/etc/gconf/schemas/gweather.schemas || die "Removing schemas failed"

	python_clean_installation_image
}
