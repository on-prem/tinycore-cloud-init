# Config values

VERSION ?= 19.3
package := cloud-init
package_name := $(package)-$(VERSION).tar.gz
package_source := https://github.com/canonical/cloud-init/archive/$(VERSION).tar.gz
package_license := "GPL-3.0"
compile_deps := python3.6 squashfs-tools curl libffi
