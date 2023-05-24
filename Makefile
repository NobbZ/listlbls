NAME    = listlbls
SHELL   = bash
PWD     = $(shell pwd)
TEMP   := $(shell mktemp -d)
TDIR    = $(TEMP)/$(NAME)
VERS    = $(shell ltxfileinfo -v $(NAME).dtx)
LOCAL   = $(shell kpsewhich --var-value TEXMFLOCAL)
UTREE   = $(shell kpsewhich --var-value TEXMFHOME)
PREFIX ?= $(LOCAL)
LATEX   = xelatex
SUDO    = sudo

all: $(NAME).pdf README.md README
	$(MAKE) clean

README: README.txt
	cp README.txt README

README.txt: $(NAME).pdf

README.md: $(NAME).pdf

$(NAME).pdf: $(NAME).dtx
	$(LATEX) -shell-escape -recorder $(NAME).dtx
	if [ -f $(NAME).glo ]; then makeindex -q -s gglo.ist -o $(NAME).gls $(NAME).glo; fi
	if [ -f $(NAME).idx ]; then makeindex -q -s gind.ist -o $(NAME).ind $(NAME).idx; fi
	$(LATEX) -shell-escape -recorder -interaction=scrollmode $(NAME).dtx
	$(LATEX) -shell-escape -recorder -interaction=scrollmode $(NAME).dtx
	$(LATEX) -shell-escape -recorder -interaction=scrollmode $(NAME).dtx

clean:
	rm -f *.fls
	rm -f $(NAME).{aux,toc,fls,glo,gls,hd,idx,ilg,ind,ins,log,out}

distclean: clean
	rm -f $(NAME).{pdf,sty} README{,.{md,txt}}

inst: all
	$(MAKE) install PREFIX=$(UTREE) SUDO=""

install: all
	$(SUDO) mkdir -p $(PREFIX)/{tex,source,doc}/latex/$(NAME)
	$(SUDO) cp $(NAME).dtx $(PREFIX)/source/latex/$(NAME)
	$(SUDO) cp $(NAME).sty $(PREFIX)/tex/latex/$(NAME)
	$(SUDO) cp $(NAME).pdf $(PREFIX)/doc/latex/$(NAME)

zip: all
	mkdir $(TDIR)
	cp $(NAME).{pdf,dtx} Makefile README $(TDIR)
	cd $(TEMP); zip -Drq $(PWD)/$(NAME)-$(VERS).zip $(NAME)
