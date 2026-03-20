# Collective moderation of hate, toxicity, and extremity in online discussions (respository for publication)

This repository includes data processing and analysis scripts for the publication Lasser, Herderich, et al. (2025): Collective moderation of hate, toxicity, and extremity in online discussions. *PNAS Nexus, 4*(11), pgaf369. https://doi.org/10.1093/pnasnexus/pgaf369. Please note, that due to Twitter's terms of service, we cannot publish the raw tweet texts to replicate the labels inferred with the machine learning models. However, we publish the tweet-ids alongside the inferred variables to replicate the statistical analysis on OSF. Please see paragraph "Data" for details.

## Data
Due to GitHub's file size constraints, we publish the data necessary to replicate the statistical analysis on OSF under https://osf.io/x4we6. The `inferred_data.csv` contains
- tweet id, user id, conversation id, as well as additional conversation variables such as root post
- membership of hate and counter speech group of the tweeter
- toxicity, hate and extremity of speech scores
- scores for emotions anger, fear, disgust, sadness, joy, enthusiasm, pride, hope
- model scores for argumentation strategy, and outgroup content
- human labels for argumentation strategy, outgroup content, and hate
- labeling batch

Due to Twitter's terms of service, we do not publish the raw tweet text. To obtain the raw data (upon reasonable request), please fill out the data transfer agreement in the appendix of the accompanying publication and send it to alina.herderich@uni-graz.at.

## Structure of this repository
- `training`:  includes Python scripts for training the classifiers on argumentation strategy (strategy), outgroup thinking (group, goal), and hate (hate, target) 
- `labeling`:
  - `interrater_reliability.ipynb`: code to compute interrater reliability of human annotations for each of the annotation rounds (batches)
  - `sample_trees`: Python code for drawing batches of annotation data (iterative annotation)
- `inference`: Python scripts for performing inference on strategy, group, goal, hate, target, language, and emotions 
- `data preparation`: code for back translation (used for data augmentation) and selecting confident examples (to train the customized classifiers for strategy, group, goal, hate, and target)
- `analysis`: statistical analysis for three levels of aggregation - reply pairs, conversations, and day level
  - `ardl`: analysis on conversation and day level (in Stata)
  - `matching`: analysis on reply pair level (in R)
  - `descriptive_statistics.ipynb`: descriptive analysis (in Python)
