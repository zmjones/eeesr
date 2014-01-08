eeesr_presentation.pdf: eeesr_presentation.tex
	$(TEXCMD) $<
	$(TEXCMD) $<
	find . | egrep ".*((\.(aux|log|out|DS_Store|nav|toc|snm)))$$" | xargs rm
	rm -rf auto
