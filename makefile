repo: data/rep.csv setup.Rout all.Rout cv.Rout imp.Rout plot.Rout hill_jones_hr.pdf

data/rep.csv: data.R
	R CMD BATCH --no-save data.R

setup.Rout: setup.R
	R CMD BATCH setup.R

all.Rout: all.R setup.R
	R CMD BATCH all.R

cv.Rout: cv.R setup.R
	R CMD BATCH cv.R

imp.Rout: imp.R setup.R
	R CMD BATCH imp.R

plot.Rout: plot.R all.R cv.R imp.R
	R CMD BATCH plot.R

TEXCMD := pdflatex -interaction=batchmode
hill_jones_hr.pdf: hill_jones_hr.tex plot.Rout
	$(TEXCMD) $<
	bibtex *.aux
	$(TEXCMD) $<
	$(TEXCMD) $<

clean:
	find . | egrep ".*((\.(aux|log|blg|bbl|out|Rhistory|DS_Store))|~)$$" | xargs rm
	rm -rf auto
