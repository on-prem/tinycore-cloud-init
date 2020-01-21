# Makefile

VERSION ?= 19.3
package := cloud-init
package_name := $(package)-$(VERSION).tar.gz
compile_deps := python3.6 squashfs-tools curl libffi cloud-init-deps

.PHONY: all deps setup build tcz clean

all: deps setup build tcz clean

setup:
		rm -rf /tmp/$(package) /tmp/$(package).tcz
		curl -L -o $(package_name) https://github.com/canonical/cloud-init/archive/$(VERSION).tar.gz
		tar -xzf $(package_name)

build:
		cd $(package)-$(VERSION) && \
		pip3 install --root /tmp/$(package) .

include ../build.make
