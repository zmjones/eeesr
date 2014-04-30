Code for "[An Empirical Evaluation of Explanations for State Repression](http://zmjones.com/static/papers/eeesr_manuscript.pdf)," by [Daniel Hill](http://myweb.fsu.edu/dwh06c/) and [Zachary Jones](http://zmjones.com). Forthcoming at the *American Political Science Review*.

	@article{hill2014empirical,
	  title={An Empirical Evaluation of Explanations for State Repression},
	  author={Hill Jr., Daniel W. and Jones, Zachary M.},
	  journal={American Political Science Reivew},
	  year={2014}
	}

[Open an issue](https://github.com/zmjones/eeesr/issues/new) or send me an [email](mailto:zmj@zmjones.com) if you have any problems or suggestions. This repository contains the complete history of the manuscript and code since we started the project. You can look at the [commits](https://github.com/zmjones/eeesr/commits/master) to see how the paper changed over time.

## Getting the Code and Data

You can clone this repository using git or [download](https://github.com/zmjones/eeesr/archive/master.zip) it as a `.zip` archive. You can download the data necessary to run this code [here](http://zmjones.com/static/data/eeesr_data.zip). The code expects the data to be in a subdirectory labeled `data`. If you have [git](http://git-scm.com/), [wget](https://www.gnu.org/software/wget/), and unzip available, the following code will automate the procedure.

	git clone https://github.com/zmjones/eeesr.git && cd eeesr
	wget http://zmjones.com/static/data/eeesr_data.zip && unzip eeesr_data

## Running the Code

This build process has only been tested on OSX and Ubuntu.

The [makefile](https://github.com/zmjones/eeesr/blob/master/makefile) allows you to build everything with one command, or to only build subsets of the entire project. You can build everything: `make all`, the paper only: `make paper`, the analysis only `make analysis`, or the data only `make data`. Note that the analysis is very computationally intensive and should probably be run on a cluster. We used [Amazon's Elastic Compute Cloud](http://aws.amazon.com/ec2/). If you don't want to use the makefile, be sure to run the scripts in the order specified in the makefile (also shown below). 

To rebuild the replication data you'll need to make `get_un.sh` executable: `chmod 755 get_un.sh`. This also requires git (it clones another repository). The relevant data files scraped by [untreaties](http://github.com/zmjones/untreaties/) are already in the data archive though. You'll also need the package dependencies that are automatically checked for and installed by `setup.R` and loaded in each script. This should be automatic, but if a package fails to install, you don't have a mirror selected, or a personal package library setup already, the automation will fail.

The approximate runtime of each script varies widely as a function of the number of cross-validation iterations, bootstrap iterations, number of imputations performed, and the number of cores the computation is distributed across (all of these variables are set in `setup.R`).

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
