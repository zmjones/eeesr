all: eeesr_manuscript.pdf eeesr_appendix.pdf clean_tex

TEXCMD := pdflatex -interaction=batchmode
eeesr_manuscript.pdf: eeesr_manuscript.tex
	$(TEXCMD) $<
	bibtex eeesr_manuscript.aux
	$(TEXCMD) $<
	$(TEXCMD) $<

eeesr_appendix.pdf: eeesr_appendix.tex
	$(TEXCMD) $<
	bibtex eeesr_appendix.aux
	$(TEXCMD) $<
	$(TEXCMD) $<

clean_tex:
	find . | egrep ".*((\.(aux|log|blg|bbl|out|DS_Store)))$$" | xargs rm
	rm -rf auto
