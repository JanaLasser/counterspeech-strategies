List of analysis files (matlab .m, Stata .do):

Basic preparation of data: fin_data_prep.m*

Preparation of day-by-day data: fin_data_prep_day.m
ARDL for day-by-day data: fin_ardl_days.do
Plot day-by-day data: fin_plot_days.m

Preparation of tree data: fin_data_prep_trees.m
ARDL for tree data: fin_ardl_trees_tox.do, fin_ardl_trees_hate.do, fin_ardl_trees_extreme_score.do, fin_ardl_trees_extreme_user.do

Preparation of ARDL results for meta analyses: fin_tree_ardl_prep_for_meta.m

Preparation of ARDL results for meta analyses by type of user: fin_tree_ardl_prep_for_meta_by_type.m

Meta analyses of tree data, deriving additional tree data, conducting meta regressions: fin_tree_meta_analyses.do, fin_tree_meta_analyses_by_type.do

Plot tree data and make meta-regression tables: fin_plot_trees.m

Plot initial figures: fin_trends_joint_figure.m

*Requires data file "data.csv" - available on request from authors.