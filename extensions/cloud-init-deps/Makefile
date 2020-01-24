# Makefile

include config.make

.PHONY: all deps setup build tcz

all: deps setup build tcz

setup:
		curl -L -o $(package_name) $(package_source)
		tar -xzf $(package_name)

build:
		mv cloud-init-$(VERSION) $(package)
		cd $(package) && \
		pip3 install -r ./requirements.txt --root $(artifact)/$(package)

include ../build.make
