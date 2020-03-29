# Config values

VERSION ?= 0.8.35
package := ifupdown
package_name := $(package)_$(VERSION).tar.xz
package_source := https://deb.debian.org/debian/pool/main/i/ifupdown/$(package_name)
package_license := "GPL-2.0"
compile_deps := perl5 squashfs-tools curl openssl-1.1.1-dev
