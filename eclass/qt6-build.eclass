# Copyright 2021-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: qt6-build.eclass
# @MAINTAINER:
# qt@gentoo.org
# @SUPPORTED_EAPIS: 8
# @PROVIDES: cmake
# @BLURB: Eclass for Qt6 split ebuilds.
# @DESCRIPTION:
# This eclass contains various functions that are used when building Qt6.

case ${EAPI} in
	8) ;;
	*) die "${ECLASS}: EAPI ${EAPI:-0} not supported" ;;
esac

if [[ -z ${_QT6_BUILD_ECLASS} ]]; then
_QT6_BUILD_ECLASS=1

[[ ${CATEGORY} != dev-qt ]] &&
	die "${ECLASS} is only to be used for building Qt6"

inherit cmake flag-o-matic

# @ECLASS_VARIABLE: QT6_MODULE
# @PRE_INHERIT
# @DESCRIPTION:
# The upstream name of the module this package belongs to.
# Used for SRC_URI and EGIT_REPO_URI.
: "${QT6_MODULE:=${PN}}"

case ${PV} in
	6.9999)
		# git dev branch
		readonly QT6_BUILD_TYPE=live
		EGIT_BRANCH=dev
		;;
	6.*.9999)
		# git stable branch
		readonly QT6_BUILD_TYPE=live
		EGIT_BRANCH=${PV%.9999}
		;;
	*_alpha*|*_beta*|*_rc*)
		# development release
		readonly QT6_BUILD_TYPE=release
		QT6_P=${QT6_MODULE}-everywhere-src-${PV/_/-}
		SRC_URI="https://download.qt.io/development_releases/qt/${PV%.*}/${PV/_/-}/submodules/${QT6_P}.tar.xz"
		S=${WORKDIR}/${QT6_P}
		;;
	*)
		# official stable release
		readonly QT6_BUILD_TYPE=release
		QT6_P=${QT6_MODULE}-everywhere-src-${PV}
		SRC_URI="https://download.qt.io/official_releases/qt/${PV%.*}/${PV}/submodules/${QT6_P}.tar.xz"
		S=${WORKDIR}/${QT6_P}
		;;
esac
unset QT6_P

if [[ ${QT6_BUILD_TYPE} == live ]]; then
	inherit git-r3
	EGIT_REPO_URI=(
		"https://code.qt.io/qt/${QT6_MODULE}.git"
		"https://github.com/qt/${QT6_MODULE}.git"
	)
fi

HOMEPAGE="https://www.qt.io/"
LICENSE="|| ( GPL-2 GPL-3 LGPL-3 ) FDL-1.3"
SLOT=6/${PV%.*}

if [[ ${PN} != qttranslations ]]; then
	IUSE="test"
	RESTRICT="!test? ( test )"
fi

BDEPEND="
	dev-lang/perl
	virtual/pkgconfig
"

######  Phase functions  ######

# @FUNCTION: qt6-build_src_prepare
# @DESCRIPTION:
# Run cmake_src_prepare, prepare the environment (such as set
# QT6_PREFIX, QT6_LIBDIR, and others), and handle anything else
# generic as needed.
qt6-build_src_prepare() {
	cmake_src_prepare

	if in_iuse test && use test && [[ -e tests/auto/CMakeLists.txt ]]; then
		# upstream seems to install before running tests, and cmake
		# subdir that is present in about half of the Qt6 components
		# cause a dependency on itself and sometimes install test junk
		sed -i '/add_subdirectory(cmake)/d' tests/auto/CMakeLists.txt || die
	fi

	_qt6-build_prepare_env
}

# @FUNCTION: qt6-build_src_configure
# @DESCRIPTION:
# Run cmake_src_configure and handle anything else generic as needed.
qt6-build_src_configure() {
	if [[ ${mycmakeargs@a} == *a* ]]; then
		local mycmakeargs=("${mycmakeargs[@]}")
	else
		local mycmakeargs=()
	fi

	mycmakeargs+=(
		# note that if qtbase was built with tests, this is default ON
		-DQT_BUILD_TESTS=$(in_iuse test && usev test ON || echo OFF)
	)

	[[ ${PN} != qttranslations ]] && # compiles nothing (unused option)
		mycmakeargs+=( -DQT_USE_DEFAULT_CMAKE_OPTIMIZATION_FLAGS=ON ) #911822

	# LTO cause test failures in several components (e.g. qtcharts,
	# multimedia, scxml, wayland, webchannel, ...).
	#
	# Exact extent/causes unknown, but for some related-sounding bugs:
	# https://bugreports.qt.io/browse/QTBUG-112332
	# https://bugreports.qt.io/browse/QTBUG-115731
	#
	# Does not manifest itself with clang:16 (did with gcc-13.2.0), but
	# still assumed to be generally unsafe either way in current state.
	filter-lto

	cmake_src_configure
}

# @FUNCTION: qt6-build_src_test
# @USAGE: [<cmake_src_test argument>...]
# @DESCRIPTION:
# Run cmake_src_test and handle anything else generic as-needed.
qt6-build_src_test() {
	# helps a few tests but is not always respected
	local -x QML_IMPORT_PATH=${BUILD_DIR}${QT6_QMLDIR#"${QT6_PREFIX}"}

	local -x QT_QPA_PLATFORM=offscreen

	# TODO?: CMAKE_SKIP_TESTS skips a whole group of tests and, when
	# only want to skip a sepcific sub-test, the BLACKLIST files
	# could potentially be modified by implementing a QT6_SKIP_TESTS

	cmake_src_test "${@}"
}

# @FUNCTION: qt6-build_src_install
# @DESCRIPTION:
# Run cmake_src_install and handle anything else generic as needed.
qt6-build_src_install() {
	cmake_src_install

	# hack: trim typical junk with currently no known "proper" way
	# to avoid that primarily happens with tests (e.g. qt5compat and
	# qtsvg tests, but qtbase[gui,-test] currently does some too)
	rm -rf -- "${D}${QT6_PREFIX}"/tests \
		"${D}${QT6_LIBDIR}/objects-${CMAKE_BUILD_TYPE}" || die
}

######  Public helpers  ######

# @FUNCTION: qt_feature
# @USAGE: <flag> [feature]
# @DESCRIPTION:
# <flag> is the name of a flag in IUSE.
qt_feature() {
	[[ ${#} -ge 1 ]] || die "${FUNCNAME}() requires at least one argument"

	echo "-DQT_FEATURE_${2:-${1}}=$(usex ${1} ON OFF)"
}

# @FUNCTION: qt6_symlink_binary_to_path
# @USAGE: <target binary name> [suffix]
# @DESCRIPTION:
# Symlink a given binary from QT6_BINDIR to QT6_PREFIX/bin, with
# optional suffix.
qt6_symlink_binary_to_path() {
	[[ ${#} -ge 1 ]] || die "${FUNCNAME}() requires at least one argument"

	dosym -r "${QT6_BINDIR}"/${1} /usr/bin/${1}${2}
}

######  Internal functions  ######

# @FUNCTION: _qt6-build_prepare_env
# @INTERNAL
# @DESCRIPTION:
# Prepares the environment for building Qt.
_qt6-build_prepare_env() {
	# setup installation directories
	# note: keep paths in sync with qmake-utils.eclass
	readonly QT6_PREFIX=${EPREFIX}/usr
	readonly QT6_DATADIR=${QT6_PREFIX}/share/qt6
	readonly QT6_LIBDIR=${QT6_PREFIX}/$(get_libdir)

	readonly QT6_ARCHDATADIR=${QT6_LIBDIR}/qt6

	readonly QT6_BINDIR=${QT6_ARCHDATADIR}/bin
	readonly QT6_DOCDIR=${QT6_PREFIX}/share/qt6-doc
	readonly QT6_EXAMPLESDIR=${QT6_DATADIR}/examples
	readonly QT6_HEADERDIR=${QT6_PREFIX}/include/qt6
	readonly QT6_IMPORTDIR=${QT6_ARCHDATADIR}/imports
	readonly QT6_LIBEXECDIR=${QT6_ARCHDATADIR}/libexec
	readonly QT6_MKSPECSDIR=${QT6_ARCHDATADIR}/mkspecs
	readonly QT6_PLUGINDIR=${QT6_ARCHDATADIR}/plugins
	readonly QT6_QMLDIR=${QT6_ARCHDATADIR}/qml
	readonly QT6_SYSCONFDIR=${EPREFIX}/etc/xdg
	readonly QT6_TRANSLATIONDIR=${QT6_DATADIR}/translations
}

fi

EXPORT_FUNCTIONS src_prepare src_configure src_test src_install
