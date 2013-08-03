repo: data/rep.csv setup all cv imp plot hll_jones_hr.pdf clean

data/rep.csv: data.R
	R CMD BATCH --no-save data.R

setup: setup.R
	R CMD BATCH setup.R

all: all.R setup.R
	R CMD BATCH all.R

cv: cv.R setup.R
	R CMD BATCH cv.R

imp: imp.R setup.R
	R CMD BATCH imp.R

plot: plot.R all cv imp
	R CMD BATCH plot.R

TEXCMD := pdflatex -interaction=batchmode
hill_jones_hr.pdf: ./hill_jones_hr.tex ./figures/*.png
	$(TEXCMD) $<
	bibtex *.aux
	$(TEXCMD) $<
	$(TEXCMD) $<

clean:
	find . | egrep ".*((\.(aux|log|blg|bbl|out|Rout|Rhistory|DS_Store|RData))|~)$$" | xargs rm
	rm -rf auto
