# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 )
inherit python-single-r1 bash-completion-r1

if [[ ${PV} == "9999" ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/sqlmapproject/sqlmap.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/sqlmapproject/sqlmap/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

DESCRIPTION="Automatic SQL injection and database takeover tool "

LICENSE="GPL-2"
SLOT="0"
IUSE="ntlm"

DEPEND=""
RDEPEND="ntlm? ( dev-python/python-ntlm[${PYTHON_USEDEP}] )"

QA_PREBUILT="
	usr/share/${PN}/udf/mysql/linux/32/lib_mysqludf_sys.so
	usr/share/${PN}/udf/mysql/linux/64/lib_mysqludf_sys.so
	usr/share/${PN}/udf/postgresql/linux/32/8.2/lib_postgresqludf_sys.so
	usr/share/${PN}/udf/postgresql/linux/32/8.3/lib_postgresqludf_sys.so
	usr/share/${PN}/udf/postgresql/linux/32/8.4/lib_postgresqludf_sys.so
	usr/share/${PN}/udf/postgresql/linux/32/9.0/lib_postgresqludf_sys.so
	usr/share/${PN}/udf/postgresql/linux/32/9.1/lib_postgresqludf_sys.so
	usr/share/${PN}/udf/postgresql/linux/64/8.2/lib_postgresqludf_sys.so
	usr/share/${PN}/udf/postgresql/linux/64/8.3/lib_postgresqludf_sys.so
	usr/share/${PN}/udf/postgresql/linux/64/8.4/lib_postgresqludf_sys.so
	usr/share/${PN}/udf/postgresql/linux/64/9.0/lib_postgresqludf_sys.so"

src_install () {
	if [[ ${PV} == "9999" ]]; then
		# fix broken tarball
		find ./ -name .git | xargs rm -rf
		# Don't forget to disable the revision check since we removed the SVN files
		sed -i -e 's/= getRevisionNumber()/= "Unknown revision"/' lib/core/settings.py
	fi
	dodoc -r doc/*
	rm -rf doc/
	dodir /usr/share/${PN}/

	cp -R * "${ED}"/usr/share/${PN}/
	python_fix_shebang "${ED}"/usr/share/${PN}
	dosym "${EPREFIX}"/usr/share/${PN}/sqlmap.py /usr/bin/${PN}

	newbashcomp "${FILESDIR}"/sqlmap.bash-completion sqlmap
}
