# Makefile for ubiquity-slideshow-ubuntu

SOURCE=.
BUILD=$(SOURCE)/build
SOURCESLIDES=$(SOURCE)/slideshows

all: clean build_kodibuntu translations

build_init:
	mkdir -p $(BUILD)

build_kodibuntu: build_init
	cp -rL $(SOURCESLIDES)/kodibuntu $(BUILD)

translations:
	./generate-local-slides.sh kodibuntu

.PHONY : clean

clean:
	-rm -rf $(BUILD)
