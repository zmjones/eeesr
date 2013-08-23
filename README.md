Code for "An Empirical Evaluation of Explanations for State Repression," by [Daniel Hill](http://myweb.fsu.edu/dwh06c/) and [Zachary Jones](http://zmjones.com).

> The empirical literature that examines cross-national patterns of state repression seeks to discover a set of political, economic, and social conditions that are consistently associated with government violations of human rights. Null hypothesis significance testing is the most common way of examining the relationship  between repression and concepts of interest, but we argue that it is inadequate for this goal, and has produced potentially misleading results. To remedy this deficiency in the literature we use cross-validation and random forests to determine the {\em predictive} power of measures of concepts the literature identifies as important causes of repression. We find that few of these measures are able to substantially improve the predictive power of statistical models of repression. Further, the most studied concept in the literature, democratic political institutions, predicts certain kinds of repression much more accurately than others. We argue that this is due to conceptual overlap between democracy and certain kinds of state repression. Finally, we argue that the impressive performance of certain features of domestic legal systems, as well as some economic and demographic factors, justifies a stronger focus on these concepts in future studies of repression.

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
