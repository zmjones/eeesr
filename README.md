Code for "An Empirical Evaluation of Explanations for State Repression," by [Daniel Hill](http://myweb.fsu.edu/dwh06c/) and [Zachary Jones](http://zmjones.com).

[Open an issue](https://github.com/zmjones/eeesr/issues/new) or send me an [email](mailto:zmj@zmjones.com) if you have any suggestions.

You can download the data necessary to run this code [here](http://zmjones.com/static/data/eeesr_data.zip). The code expects the data to be in a subdirectory labeled `data`. Dependencies are automatically checked for and installed by each script.

You can clone this repository using git or [download](https://github.com/zmjones/eeesr/archive/master.zip) it as a `.zip` archive.

 - `data.R` joins and cleans up the various data sets we use for this analysis
 - `setup.R` sets global variables (e.g. folds, iterations, etc.), defines model specifications and labels
 - `all.R` estimates models on all the data and computes p-values
 - `cv.R` cross-validates ordinal logistic regression and ols models
 - `imp.R` calculates variable importance based on random forest models
 - `mi.R` performs multiple imputation
 - `plot.R` ...creates plots
