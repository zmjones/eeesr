repo: data/rep.csv setup.Rout mi.Rout all.Rout cv_setup.Rout cv.Rout imp.Rout plot.Rout hill_jones_hr.pdf clean_tex

data/rep.csv: data.R
	R CMD BATCH --no-save data.R

setup.Rout: setup.R
	R CMD BATCH setup.R

mi.Rout: mi.R setup.R
	R CMD BATCH mi.R

all.Rout: all.R setup.R mi.R
	R CMD BATCH all.R

cv_setup.Rout: cv_setup.R
	R CMD BATCH cv_setup.R

cv.Rout: cv.R cv_setup.R setup.R mi.R
	R CMD BATCH cv.R

imp.Rout: imp.R setup.R
	R CMD BATCH imp.R

plot.Rout: plot.R all.R cv.R imp.R mi.R
	R CMD BATCH plot.R

TEXCMD := pdflatex -interaction=batchmode
hill_jones_hr.pdf: hill_jones_hr.tex plot.Rout
	$(TEXCMD) $<
	bibtex *.aux
	$(TEXCMD) $<
	$(TEXCMD) $<

clean_tex:
	find . | egrep ".*((\.(aux|log|blg|bbl|out|DS_Store))|~)$$" | xargs rm
	rm -rf auto

clean_r:
	find . | egrep ".*((\.(Rout|RData|Rhistory))|~)$$" | xargs rm
	rm -rf auto
