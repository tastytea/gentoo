# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DIST_AUTHOR=BHALLISSY
DIST_VERSION=1.06
inherit perl-module

DESCRIPTION="Module for compiling and altering fonts"

LICENSE="Artistic-2 OFL-1.1"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~loong ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux"

RDEPEND="
	virtual/perl-IO-Compress
	dev-perl/IO-String
	dev-perl/XML-Parser
"
BDEPEND="${RDEPEND}
	virtual/perl-ExtUtils-MakeMaker
"
PERL_RM_FILES=(
	t/changes.t
)
