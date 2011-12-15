# Makefile for ubiquity-slideshow-ubuntu

SOURCE=.
BUILD=$(SOURCE)/build
SOURCESLIDES=$(SOURCE)/slideshows

all: clean build_xbmcbuntu translations

build_init:
	mkdir -p $(BUILD)

build_xbmcbuntu: build_init
	cp -rL $(SOURCESLIDES)/xbmcbuntu $(BUILD)

translations:
	./generate-local-slides.sh xbmcbuntu

.PHONY : clean

clean:
	-rm -rf $(BUILD)
