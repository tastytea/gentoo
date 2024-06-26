# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# ebuild generated by hackport 0.8.4.0.9999

CABAL_HACKAGE_REVISION=2

CABAL_FEATURES="lib profile haddock hoogle hscolour test-suite"
inherit haskell-cabal

DESCRIPTION="Mustache templates for Haskell"
HOMEPAGE="https://github.com/haskellari/microstache"

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~arm64 ~ppc64 ~riscv ~x86"

RDEPEND=">=dev-haskell/parsec-3.1.11:=[profile?] <dev-haskell/parsec-3.2:=[profile?]
	>=dev-haskell/unordered-containers-0.2.5:=[profile?] <dev-haskell/unordered-containers-0.3:=[profile?]
	>=dev-haskell/vector-0.11:=[profile?] <dev-haskell/vector-0.14:=[profile?]
	>=dev-lang/ghc-8.8.1:=
	>=dev-haskell/aeson-0.11:=[profile?] <dev-haskell/aeson-2.3:=[profile?]
	>=dev-haskell/text-1.2.3.0:=[profile?] <dev-haskell/text-2.1:=[profile?]
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-3.0.0.0
	test? ( dev-haskell/aeson
		>=dev-haskell/base-orphans-0.8.7 <dev-haskell/base-orphans-0.10
		>=dev-haskell/tasty-1.4.0.1 <dev-haskell/tasty-1.5
		>=dev-haskell/tasty-hunit-0.10.0.3 <dev-haskell/tasty-hunit-0.11
		dev-haskell/text )
"
