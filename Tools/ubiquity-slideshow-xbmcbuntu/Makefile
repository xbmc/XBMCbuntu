# Makefile for ubiquity-slideshow-xbmcbuntu

SOURCE=.
BUILD=$(SOURCE)/build
SOURCESLIDES=$(SOURCE)/slideshows

all: clean build_ubuntu build_oem_config_ubuntu translations

build_init:
	mkdir -p $(BUILD)

build_ubuntu: build_init
	cp -rL $(SOURCESLIDES)/ubuntu $(BUILD)

build_oem_config_ubuntu: build_init
	cp -rL $(SOURCESLIDES)/oem-config-ubuntu $(BUILD)

translations:
	./generate-local-slides.sh ubuntu
	./generate-local-slides.sh oem-config-ubuntu

.PHONY : clean

clean:
	-rm -rf $(BUILD)
