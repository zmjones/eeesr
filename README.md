Code for "[An Empirical Evaluation of Explanations for State Repression](http://zmjones.com/static/papers/eeesr_manuscript.pdf)," by [Daniel Hill](http://myweb.fsu.edu/dwh06c/) and [Zachary Jones](http://zmjones.com). Published in the [*American Political Science Review* 108:3 (pp. 661-667)](http://journals.cambridge.org/action/displayAbstract?fromPage=online&aid=9327383&fulltextType=RA&fileId=S0003055414000306).

> The empirical literature that examines cross-national patterns of state repression seeks to discover a set of political, economic, and social conditions that are consistently associated with government violations of human rights. Null hypothesis significance testing is the most common way of examining the relationship  between repression and concepts of interest, but we argue that it is inadequate for this goal, and has produced potentially misleading results. To remedy this deficiency in the literature we use cross-validation and random forests to determine the *predictive* power of measures of concepts the literature identifies as important causes of repression. We find that few of these measures are able to substantially improve the predictive power of statistical models of repression. Further, the most studied concept in the literature, democratic political institutions, predicts certain kinds of repression much more accurately than others. We argue that this is due to conceptual and operational overlap between democracy and certain kinds of state repression. Finally, we argue that the impressive performance of certain features of domestic legal systems, as well as some economic and demographic factors, justifies a stronger focus on these concepts in future studies of repression.

See Google Scholar's [citation count](http://scholar.google.com/citations?view_op=view_citation&hl=en&user=hdxn_v4AAAAJ&citation_for_view=hdxn_v4AAAAJ:9yKSN-GCB0IC).

You can also see the [anynomous referree reviews](http://zmjones.com/static/papers/eeesr_reviews.pdf), and our responses to them (rounds [1](http://zmjones.com/static/papers/eeesr_memo_1.pdf) and [2](http://zmjones.com/static/papers/eeesr_memo_2.pdf)), as well as our [online appendix](http://zmjones.com/static/papers/eeesr_appendix.pdf). There is also a short [post](http://zmjones.com/eeesr/) I wrote that summarizes the paper.

	@article{hill2014empirical,
	  title={An Empirical Evaluation of Explanations for State Repression},
	  author={Hill Jr., Daniel W. and Jones, Zachary M.},
	  journal={American Political Science Reivew},
	  year={2014},
	  volume={108},
	  issue={3},
	  pages={661-687}
	}

[Open an issue](https://github.com/zmjones/eeesr/issues/new) or send me an [email](mailto:zmj@zmjones.com) if you have any problems or suggestions. Even though this paper is published I intend on making sure it remains replicable.

This repository contains the complete history of the manuscript and code since we started the project. You can look at the [commits](https://github.com/zmjones/eeesr/commits/master) to see how the paper and code changed over time.

## Getting the Code and Data

You can clone this repository using git or [download](https://github.com/zmjones/eeesr/archive/master.zip) it as a `.zip` archive. You can download the data necessary to run this code [here](http://zmjones.com/static/data/eeesr_data.zip). The code expects the data to be in a subdirectory labeled `data`. If you have [git](http://git-scm.com/), [wget](https://www.gnu.org/software/wget/), and unzip available, the following code will automate the procedure.

	git clone https://github.com/zmjones/eeesr.git && cd eeesr
	wget http://zmjones.com/static/data/eeesr_data.zip && unzip eeesr_data

## Running the Code

This build process has only been tested on OSX. It was originally run on Amazon's EC2 using an Ubuntu server, but the most recent revisions have been run on Penn State's Lion cluster. Some parts of the code are runnable on a laptop, but the cross-validation and permutation importance scripts are very computationally intensive and it is probably a good idea to run these on a high performance computing system.

The [makefile](https://github.com/zmjones/eeesr/blob/master/makefile) allows you to build everything with one command, or to only build subsets of the entire project. You can build everything: `make all`, the paper only: `make paper`, the analysis only `make analysis`, or the data only `make data`. If you don't want to use the makefile, be sure to run the scripts in the order specified in the makefile (also shown below).

To rebuild the replication data you'll need to make `get_un.sh` executable: `chmod +x get_un.sh`. This also requires git (it clones another repository). The relevant data files scraped by [untreaties](http://github.com/zmjones/untreaties/) are already in the data archive though. You'll also need the package dependencies that are listed at the top of each script.

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
