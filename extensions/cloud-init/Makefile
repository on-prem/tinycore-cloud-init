# Makefile

include config.make

.PHONY: all deps setup build tcz

all: deps setup build tcz

setup:
		curl -L -o $(package_name) $(package_source)
		tar -xzf $(package_name)

build:
		cd $(package)-$(VERSION) && \
		sudo pip3 install -r ./requirements.txt && \
		pip3 install --root $(artifact)/$(package) .
		cp -v $(package).tcz.dep $(artifact)

include ../build.make
