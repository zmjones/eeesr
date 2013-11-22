Code for "[An Empirical Evaluation of Explanations for State Repression](http://zmjones.com/data/eeesr_manuscript.pdf)," by [Daniel Hill](http://myweb.fsu.edu/dwh06c/) and [Zachary Jones](http://zmjones.com).

[Open an issue](https://github.com/zmjones/eeesr/issues/new) or send me an [email](mailto:zmj@zmjones.com) if you have any problems or suggestions.

You can download the data necessary to run this code [here](http://zmjones.com/static/data/eeesr_data.zip). The code expects the data to be in a subdirectory labeled `data`. The UN Treaty data is downloaded by `get_un.sh` which requires [git](http://git-scm.com/). However, you can skip the data wrangling stage of the computation by only re-running the analysis (`make analysis`) or re-making the plots and the manuscript, as described in the makefile (`make paper`).

Package dependencies are automatically checked for and installed by `setup.R` and loaded in each script.

You can clone this repository using git or [download](https://github.com/zmjones/eeesr/archive/master.zip) it as a `.zip` archive. If you don't want to use the makefile, be sure to run the scripts in the order specified in the makefile (also shown below).

The approximate runtime of each script varies widely as a function of the number of cross-validation iterations, bootstrap iterations, number of imputations performed, and the number of cores the computation is distributed across (all of these variables are set in `setup.R`). All of the analysis was run on [Amazon's Elastic Compute Cloud](http://aws.amazon.com/ec2/).

 - `get_un.sh` fetches the [untreaties](http://github.com/zmjones/untreaties) utility, grabs the appropriate treaties, and transforms them
 - `data.R` joins and cleans up the various data sets we use for this analysis
 - `setup.R` sets global variables (e.g. folds, iterations, etc.), defines model specifications and labels
 - `mi.R` performs multiple imputation
 - `imp.R` calculates bootstrapped variable importance based on random forest models
 - `all.R` estimates models on all the (imputed) data
 - `cv_setup.R` sets up functions and variables for cross-validation procedure
 - `cv.R` cross-validates all models and combines results
 - `plot.R` creates descriptive and model plots
 - `tree.R` creates decision tree plot for random forest explanation section
