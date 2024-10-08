# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..13} )

inherit distutils-r1

DESCRIPTION="Record terminal sessions as SVG animations"
HOMEPAGE="https://github.com/nbedos/termtosvg"
SRC_URI="https://github.com/nbedos/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	dev-python/lxml[${PYTHON_USEDEP}]
	>=dev-python/pyte-0.8.0[${PYTHON_USEDEP}]
	dev-python/wcwidth[${PYTHON_USEDEP}]
"

distutils_enable_tests unittest
