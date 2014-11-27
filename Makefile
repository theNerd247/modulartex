##############################
# @file Makefile for strlab
##############################
#
#-- PROJECT {{{ ------------------------------------------------------
SHELL=/bin/sh
PROJECT=main
VERSION=0.1
#-- END PROJECT }}} --------------------------------------------------

#-- DIRS {{{ ---------------------------------------------------------
PREFIX=.
CLEAN=
TEXDIR=$(PREFIX)/tex
DATADIR=$(PREFIX)/data
#-- END DIRS }}} -----------------------------------------------------

#-- FILES {{{ --------------------------------------------------------
#-- END FILES }}} ----------------------------------------------------

#-- TARGETS {{{ ------------------------------------------------------
PDFTARGET=$(PREFIX)/$(PROJECT).pdf
SUBMAKE=$(MAKE) -C $(DATADIR)
#-- END TARGETS }}} --------------------------------------------------

.PHONY: all setup clean submake pdf

all: submake pdf

submake:
	$(SUBMAKE)

pdf: 
	cd $(TEXDIR);\
	pdflatex -shell-escape -include-directory=$(PDFINC) $(PROJECT).tex
	mv $(TEXDIR)/$(PROJECT).pdf . 
## END TARGETS ############################
