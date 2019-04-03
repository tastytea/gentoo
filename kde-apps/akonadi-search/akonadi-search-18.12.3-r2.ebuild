# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

KDE_TEST="forceoptional"
VIRTUALX_REQUIRED="test"
inherit kde5

DESCRIPTION="Libraries and daemons to implement searching in Akonadi"
HOMEPAGE="https://cgit.kde.org/akonadi-search.git"
LICENSE="GPL-2+ LGPL-2.1+"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE=""

BDEPEND="
	test? ( $(add_kdeapps_dep akonadi 'tools' 18.12.3-r1) )
"
COMMON_DEPEND="
	$(add_frameworks_dep kcmutils)
	$(add_frameworks_dep kcodecs)
	$(add_frameworks_dep kconfig)
	$(add_frameworks_dep kconfigwidgets)
	$(add_frameworks_dep kcoreaddons)
	$(add_frameworks_dep kdbusaddons)
	$(add_frameworks_dep kio)
	$(add_frameworks_dep ki18n)
	$(add_frameworks_dep krunner)
	$(add_kdeapps_dep akonadi '' 18.12.3-r1)
	$(add_kdeapps_dep akonadi-mime)
	$(add_kdeapps_dep kcalcore)
	$(add_kdeapps_dep kcontacts)
	$(add_kdeapps_dep kmime)
	$(add_qt_dep qtdbus)
	$(add_qt_dep qtgui)
	$(add_qt_dep qtwidgets)
	>=dev-libs/xapian-1.3:=[chert(+)]
"
DEPEND="${COMMON_DEPEND}
	dev-libs/boost
	test? ( $(add_kdeapps_dep akonadi 'mysql,postgres,sqlite' 18.12.3-r1) )
"
RDEPEND="${COMMON_DEPEND}
	!kde-apps/kdepim-l10n
"

PATCHES=( "${FILESDIR}/${PN}-18.12.0-cmake.patch" )
