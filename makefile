all: data analysis paper
paper: plot.Rout tree.Rout subdirs
analysis: all.Rout imp.Rout cv_setup.Rout cv.Rout
data: un_utilities.Rout data/rep.csv setup.Rout mi.Rout

SUBDIRS = manuscript ## presentation
.PHONY: subdirs $(SUBDIRS)
subdirs: $(SUBDIRS)
$(SUBDIRS):
	make -C $@

un_utilities.Rout: get_un.sh
	source get_un.sh
	R CMD BATCH un_utilities.R

data/rep.csv: data.R get_un.sh
	R CMD BATCH data.R
	rm .RData

setup.Rout: setup.R data/rep.csv
	R CMD BATCH setup.R

mi.Rout: mi.R setup.Rout
	R CMD BATCH mi.R

all.Rout: all.R setup.Rout mi.Rout
	R CMD BATCH all.R

imp.Rout: imp.R setup.Rout
	R CMD BATCH imp.R

cv_setup.Rout: cv_setup.R
	R CMD BATCH cv_setup.R

cv.Rout: cv.R cv_setup.Rout setup.Rout mi.Rout
	R CMD BATCH cv.R

plot.Rout: plot.R all.Rout cv.Rout imp.Rout mi.Rout
	mkdir -p figures
	R CMD BATCH plot.R

tree.Rout: tree.R
	R CMD BATCH tree.R

clean_all:
	find . | egrep ".*((\.(Rout|Rhistory))|~)$$" | xargs rm
	rm -rf auto
	rm .RData
