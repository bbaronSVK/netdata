#!/usr/bin/env bash

. $(dirname "${0}")/../functions.sh "${@}" || exit 1

fetch "curl-curl-7_53_1" "https://github.com/curl/curl/archive/curl-7_53_1.tar.gz"

export LDFLAGS="-static"
export PKG_CONFIG="pkg-config --static"

run ./buildconf

run ./configure \
	--prefix=${NETDATA_INSTALL_PATH} \
	--enable-optimize \
	--disable-shared \
	--enable-static \
	--enable-http \
	--enable-proxy \
	--enable-ipv6 \
	--enable-cookies \
	${NULL}

# Curl autoconf does not honour the curl_LDFLAGS environment variable
run sed -i -e "s/curl_LDFLAGS =/curl_LDFLAGS = -all-static/" src/Makefile

run make clean
run make -j${PROCESSORS}
run make install

if [ ${NETDATA_BUILD_WITH_DEBUG} -eq 0 ]
then
    run strip ${NETDATA_INSTALL_PATH}/bin/curl
fi
