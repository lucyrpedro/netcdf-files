FIGDIR = ./figures/

PDFFIGS := $(wildcard $(FIGDIR)*.pdf)
CROP_FILES:= $(PDFFIGS:.pdf=.pdfcrop)

all: $(CROP_FILES)

$(FIGDIR)%.pdfcrop: $(FIGDIR)%.pdf
	pdfcrop $< $< && touch $@
