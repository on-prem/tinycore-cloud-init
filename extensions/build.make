# Generic variables

CFLAGS = -mtune=generic -Os -pipe
CXXFLAGS = -mtune=generic -Os -pipe -fno-exceptions -fno-rtti
PKG_CONFIG_PATH = /usr/local/lib/pkgconfig:/usr/lib/pkgconfig

.PHONY: deps tcz clean

deps:
		su - tc -c "tce-load -il $(compile_deps)"

tcz:
		cd /tmp && \
		find $(package) -type d | xargs -r chmod -v 755 && \
		find $(package) | xargs file | grep ELF | cut -f 1 -d : | xargs -r chmod -v 755 && \
		find $(package) | xargs file | grep ELF | cut -f 1 -d : | xargs -r strip --strip-unneeded && \
		mksquashfs $(package) $(package).tcz -b 4096

clean:
		rm -rf $(package) $(package_name) /tmp/$(package)