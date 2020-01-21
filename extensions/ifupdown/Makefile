# Makefile

VERSION ?= 0.8.35
package := ifupdown
package_name := $(package)_$(VERSION).tar.xz
compile_deps := perl5 squashfs-tools curl

.PHONY: all deps setup build tcz clean

all: deps setup build tcz clean

setup:
		ln -sf /usr/local/bin/perl /usr/bin/perl
		rm -rf /tmp/$(package) /tmp/$(package).tcz
		cp -a dpkg-architecture /usr/local/bin
		curl -L -o $(package_name) https://deb.debian.org/debian/pool/main/i/ifupdown/$(package_name)
		tar -xJf $(package_name)

build:
		cd ifupdown && \
		patch -p1 < ../ifupdown.patch && \
		$(MAKE) all && \
		$(MAKE) install DESTDIR=/tmp/$(package)
		mkdir -p /tmp/$(package)/sbin
		ln -sf /usr/local/sbin/ip /tmp/$(package)/sbin/ip
		rm -f /usr/local/bin/dpkg-architecture /usr/bin/perl

include ../build.make
