TEXCMD := pdflatex -interaction=batchmode
eeesr_manuscript.pdf: eeesr_manuscript.tex
	$(TEXCMD) $<
	bibtex *.aux
	$(TEXCMD) $<
	$(TEXCMD) $<
	find . | egrep ".*((\.(aux|log|blg|bbl|out|DS_Store)))$$" | xargs rm
	rm -rf auto
