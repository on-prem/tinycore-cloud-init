# Makefile

include config.make

.PHONY: all deps setup build tcz

all: deps setup build tcz

setup:
		sudo ln -sf /usr/local/bin/perl /usr/bin/perl
		sudo cp -a dpkg-architecture /usr/local/bin
		curl -L -o $(package_name) $(package_source)
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
