# Makefile to manage gettext files

DOMAIN=live-helper
ECHO_FUNCTIONS="Echo_message Echo_verbose Echo_warning Echo_debug Echo_error Echo_breakage Echo"

POFILES=$(wildcard *.po)
MOFILES=$(patsubst %.po,%.mo,$(POFILES))
LINGUAS=$(basename $(POFILES))
GETTEXTFILES=$(shell find ../scripts/build ../functions -type f)
POTFILE=$(DOMAIN).pot
DESTDIR=/
XGETTEXT_KEYWORDS=$(shell echo $(ECHO_FUNCTIONS) |sed -e 's,\S\+,-k&,g')

%.mo: %.po
	msgfmt --statistics -o $@ $<

%.po: $(DOMAIN).pot
	msgmerge -U $*.po $(DOMAIN).pot

$(DOMAIN).pot: $(GETTEXTFILES)
	$(shell xgettext $(XGETTEXT_KEYWORDS) -L Shell -o $(DOMAIN).pot $(GETTEXTFILES))

update-po: live-helper.pot
	-for lang in $(LINGUAS); do\
	    msgmerge -U $$lang.po $(DOMAIN).pot; \
	done

install: $(MOFILES)
	-for lang in $(LINGUAS); do\
	    install -d $(DESTDIR)/usr/share/locale/$$lang/LC_MESSAGES/; \
	    install -m 644 $$lang.mo $(DESTDIR)/usr/share/locale/$$lang/LC_MESSAGES/$(DOMAIN).mo; \
	done

all: update-po $(MOFILES)

clean:
	- rm *.mo *~

.PHONY: update-po
