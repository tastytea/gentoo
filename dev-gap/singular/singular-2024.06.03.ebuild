# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit gap-pkg

DESCRIPTION="GAP interface to sci-mathematics/singular"
SRC_URI="https://github.com/gap-packages/${PN}/releases/download/v${PV}/${P}.tar.gz"
LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~riscv"

RDEPEND="sci-mathematics/singular"

DOCS=( README.md CHANGES.md )

GAP_PKG_EXTRA_INSTALL=( contrib )
gap-pkg_enable_tests
