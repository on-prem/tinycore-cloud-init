# Generic variables

CFLAGS = -mtune=generic -Os -pipe
CXXFLAGS = -mtune=generic -Os -pipe -fno-exceptions -fno-rtti
PKG_CONFIG_PATH = /usr/local/lib/pkgconfig:/usr/lib/pkgconfig

TC_VERSION ?= 9.0-x86_64
artifact := $(HOME)/artifacts/$(package)-tc$(TC_VERSION)

.PHONY: deps tcz perms clean

deps:
		tce-load -wicl $(compile_deps)

perms:
		cd $(artifact) && \
		find $(package) -type d | xargs -r chmod -v 755 && \
		find $(package) | xargs file | grep ELF | cut -f 1 -d : | xargs -r chmod -v 755 && \
		find $(package) | xargs file | grep ELF | cut -f 1 -d : | xargs -r strip --strip-unneeded && \
		sudo chown -R 0:0 $(package)

tcz:
		$(MAKE) perms
		cd $(artifact) && \
		sudo mksquashfs $(package) $(package).tcz -b 4096 && \
		md5sum $(package).tcz > $(package).tcz.md5.txt && \
		sha256sum $(package).tcz > $(package).tcz.sha256.txt && \
		find $(package) -not -type d -printf '%P\n' | sort > $(package).tcz.list && \
		echo "Version: $(VERSION)" > $(package).tcz.info
		$(MAKE) clean

clean:
		sudo rm -rf $(package) $(package_name) $(artifact)/$(package)