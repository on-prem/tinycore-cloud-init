# Makefile

VERSION ?= 0.8.35
package := ifupdown
package_name := $(package)_$(VERSION).tar.xz
compile_deps := perl5 squashfs-tools curl

.PHONY: all deps setup build tcz

all: deps setup build tcz

setup:
		sudo ln -sf /usr/local/bin/perl /usr/bin/perl
		sudo cp -a dpkg-architecture /usr/local/bin
		curl -L -o $(package_name) https://deb.debian.org/debian/pool/main/i/ifupdown/$(package_name)
		tar -xJf $(package_name)

build:
		mkdir -p $(artifact)
		cd ifupdown && \
		patch -p1 < ../ifupdown.patch && \
		$(MAKE) all && \
		$(MAKE) install DESTDIR=$(artifact)/$(package)
		cp -v $(package).tcz.dep $(artifact)
		mkdir -p $(artifact)/$(package)/sbin
		ln -sf /usr/local/sbin/ip $(artifact)/$(package)/sbin/ip
		sudo rm -f /usr/local/bin/dpkg-architecture /usr/bin/perl

include ../build.make
