# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

UNI_PV="10.0.0"
DESCRIPTION="Miscellaneous files"
HOMEPAGE="https://savannah.gnu.org/projects/miscfiles/"
# https://www.unicode.org/Public/${UNI_PV}/ucd/UnicodeData.txt
SRC_URI="mirror://gnu/miscfiles/${P}.tar.gz
	mirror://gentoo/0b/UnicodeData-${UNI_PV}.txt.xz"

LICENSE="GPL-2 unicode"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~loong ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos"
IUSE="minimal"

src_prepare() {
	default

	mv "${WORKDIR}"/UnicodeData-${UNI_PV}.txt unicode || die
}

src_configure() {
	econf --datadir="${EPREFIX}"/usr/share/misc
}

src_install() {
	emake install DESTDIR="${D}"
	dodoc NEWS ORIGIN README dict-README

	# not sure if this is still needed ...
	dodir /usr/share/dict
	cd "${ED}"/usr/share/misc || die
	mv $(awk '$1=="dictfiles"{$1="";$2="";print}' "${S}"/Makefile) ../dict/ || die
	cd ../dict || die
	ln -s web2 words || die
	ln -s web2a extra.words || die

	if use minimal ; then
		pushd "${ED}"/usr/share/dict || die
		rm -f words extra.words || die
		gzip -9 * || die
		ln -s web2.gz words || die
		ln -s web2a.gz extra.words || die
		ln -s connectives{.gz,} || die
		ln -s propernames{.gz,} || die
		popd || die
		rm -r "${ED}"/usr/share/misc || die
	fi
}

pkg_postinst() {
	if [[ -z ${ROOT} ]] && type -P create-cracklib-dict >/dev/null ; then
		ebegin "Regenerating cracklib dictionary"
		create-cracklib-dict "${EPREFIX}"/usr/share/dict/* > /dev/null
		eend $?
	fi

	# pkg_postinst isn't supposed to fail
	return 0
}
