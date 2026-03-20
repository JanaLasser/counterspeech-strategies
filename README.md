# Collective moderation of hate, toxicity, and extremity in online discussions

This repository includes data processing and analysis scripts for the publication Lasser, Herderich, et al. (2025): Collective moderation of hate, toxicity, and extremity in online discussions. *PNAS Nexus, 4*(11), pgaf369. https://doi.org/10.1093/pnasnexus/pgaf369. Please note, that due to Twitter's terms of use, we cannot publish the raw tweet texts to replicate the labels inferred with the machine learning models. However, we publish the tweet-ids alongside the inferred variables to replicate the statistical analysis on OSF. Please see paragraph "Data" for details.

Data
- provide data structure
- provide OSF link
- say that we share raw tweet texts upon request (see data transfer statement in appendix of publication)

Structure of this repository
- `training`: py scripts for training the classifiers on strategy, group, goal, hate, target
- `labeling`:
  * `interrater reliability.ipynb`: code to compute IRR of human annotations for each of the batches
  * `sample_trees`: drawing annotation data for iterative annotation
- `inference`: scripts for performing inference on emotions, goal, group, hate, language, strategy, target
- `data preparation`: code for back translation (data augmentation) and selecting confident examples
- `analysis`: statistical analysis for reply pair, conversation, and day level
  * `ardl`: meso, macro, stata
  * `matching`: micro, R
  * `descriptive statistics.ipynb`
