Code for "An Empirical Evaluation of Explanations for State Repression," by [Daniel Hill](http://myweb.fsu.edu/dwh06c/) and [Zachary Jones](http://zmjones.com).

You can download the data necessary to run this code [here](http://zmjones.com/static/data/eeesr_data.zip). The code expects the data to be in a subdirectory labeled `data`. Dependencies are listed at the top of `functions.R`.

There are three model blocks in `models.R`. The first (labeled `all`) estimates, extracts, and plots coefficients from models estimated on all of the data. The second (labeled `cv`) performs 10-fold cross-validation with 500 resampling iterations, extracts the sampling distribution of the discrepancy statistic (either Somer's D or root mean squared error), and plots it. The third estimates a series of conditional inference trees, extracts each variable's importance score, and plots that. You can control the number of cores the script uses by modifying `CORES` which is located at the top of `models.R`.
