# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DIST_AUTHOR=DAGOLDEN
DIST_VERSION=1.1105
inherit perl-module

DESCRIPTION="Capture STDOUT and STDERR from Perl code, subprocesses or XS"

SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 ~hppa ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x64-solaris"

RDEPEND="
	virtual/perl-Carp
	virtual/perl-Exporter
	>=virtual/perl-File-Temp-0.160.0
"
BDEPEND="${RDEPEND}
	>=virtual/perl-ExtUtils-MakeMaker-6.170.0
	test? (
		>=virtual/perl-File-Spec-3.270.0
		virtual/perl-IO
		>=virtual/perl-Test-Simple-0.620.0
	)
"
