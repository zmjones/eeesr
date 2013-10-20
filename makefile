repo: data/rep.csv setup.Rout mi.Rout imp.Rout all.Rout cv_setup.Rout cv.Rout plot.Rout eeesr_manuscript.pdf eeesr_presentation.pdf clean_tex

data/rep.csv: data.R
	R CMD BATCH --no-save data.R

setup.Rout: setup.R
	R CMD BATCH setup.R

mi.Rout: mi.R setup.R
	R CMD BATCH mi.R

all.Rout: all.R setup.R mi.R
	R CMD BATCH all.R

imp.Rout: imp.R setup.R
	R CMD BATCH imp.R

cv_setup.Rout: cv_setup.R
	R CMD BATCH cv_setup.R

cv.Rout: cv.R cv_setup.R setup.R mi.R
	R CMD BATCH cv.R

plot.Rout: plot.R all.R cv.R imp.R mi.R
	R CMD BATCH plot.R

TEXCMD := pdflatex -interaction=batchmode
# eeesr_manuscript.pdf: eeesr_manuscript.tex plot.Rout
# 	$(TEXCMD) $<
# 	bibtex *.aux
# 	$(TEXCMD) $<
# 	$(TEXCMD) $<

eeesr_presentation.pdf: eeesr_presentation.tex plot.Rout
	$(TEXCMD) $<

clean_tex:
	find . | egrep ".*((\.(aux|log|blg|bbl|out|DS_Store|nav|toc|snm))|~)$$" | xargs rm
	rm -rf auto

clean_r:
	find . | egrep ".*((\.(Rout|RData|Rhistory))|~)$$" | xargs rm
	rm -rf auto
