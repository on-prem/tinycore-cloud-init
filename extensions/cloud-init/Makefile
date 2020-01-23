# Makefile

VERSION ?= 19.3
package := cloud-init
package_name := $(package)-$(VERSION).tar.gz
compile_deps := python3.6 squashfs-tools curl libffi

.PHONY: all deps setup build tcz

all: deps setup build tcz

setup:
		rm -rf $(artifact)
		curl -L -o $(package_name) https://github.com/canonical/cloud-init/archive/$(VERSION).tar.gz
		tar -xzf $(package_name)

build:
		cd $(package)-$(VERSION) && \
		sudo pip3 install -r ./requirements.txt && \
		pip3 install --root $(artifact)/$(package) .
		cp -v $(package).tcz.dep $(artifact)

include ../build.make
