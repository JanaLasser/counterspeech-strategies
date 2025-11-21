cd "C:\Users\mirta\Dropbox\SFI Reconquista\00 strategies\analyses" 
use "d_basic_byday.dta", clear 
set matsize 10000

// time
tsset dbd_dayn

// neutral score
cor dbd_tox dbd_speech_hate_yes
generate dbd_neutral_score=-abs(.5-dbd_hate_score)

// shorten names
rename dbd_goal2_in_both_positive dbd_goal2_in_both_pos
norm dbd_speech_hate_yes  dbd_tox dbd_extreme_score dbd_user_group_70e ///
 dbd_strategy_opin dbd_strategy_sarc dbd_strategy_leave_fact dbd_strategy_construct dbd_strategy_other ///
 dbd_topic2_in_both dbd_topic2_out dbd_topic_out dbd_topic_not_out dbd_goal2_in_both_pos dbd_goal2_out_negative dbd_goal2_neutral_unint ///
 dbd_threat dbd_anger dbd_fear dbd_disgust dbd_sadness dbd_joy dbd_enthusiasm dbd_pride dbd_hope dbd_enthop dbd_prijoy ///
 dbd_valence dbd_arousal dbd_dominance dbd_power dbd_danger dbd_structure, method(zee)

// dummies time
generate rgi1=0
generate rgi2=0
generate rgi3=0
replace rgi1=1 if dbd_dayn<=1462 // before Jan 1 2017
replace rgi2=1 if dbd_dayn>=1463 & dbd_dayn<=1947 // between Jan 1 2017 and April 30 2018
replace rgi3=1 if dbd_dayn>=1948 // from May 1 2018
tab1 rgi1 rgi2 rgi3
 
// interactions with time periods - to be included as exog, short run dynamics
generate rgi1_strategy_opin = rgi1*zee_dbd_strategy_opin
generate rgi1_strategy_sarc = rgi1*zee_dbd_strategy_sarc
generate rgi1_strategy_construct = rgi1*zee_dbd_strategy_construct
generate rgi1_goal2_out_negative = rgi1*zee_dbd_goal2_out_negative
generate rgi1_goal2_in_both_pos = rgi1*zee_dbd_goal2_in_both_pos
generate rgi1_anger = rgi1*zee_dbd_anger
generate rgi1_fear = rgi1*zee_dbd_fear
generate rgi1_disgust = rgi1*zee_dbd_disgust
generate rgi1_sadness = rgi1*zee_dbd_sadness
generate rgi1_enthop = rgi1*zee_dbd_enthop
generate rgi1_prijoy = rgi1*zee_dbd_prijoy
generate rgi1_power = rgi1*dbd_power
generate rgi1_danger = rgi1*dbd_danger

generate rgi2_strategy_opin = rgi2*zee_dbd_strategy_opin
generate rgi2_strategy_sarc = rgi2*zee_dbd_strategy_sarc
generate rgi2_strategy_construct = rgi2*zee_dbd_strategy_construct
generate rgi2_goal2_out_negative = rgi2*zee_dbd_goal2_out_negative
generate rgi2_goal2_in_both_pos = rgi2*zee_dbd_goal2_in_both_pos
generate rgi2_anger = rgi2*zee_dbd_anger
generate rgi2_fear = rgi2*zee_dbd_fear
generate rgi2_disgust = rgi2*zee_dbd_disgust
generate rgi2_sadness = rgi2*zee_dbd_sadness
generate rgi2_enthop = rgi2*zee_dbd_enthop
generate rgi2_prijoy = rgi2*zee_dbd_prijoy
generate rgi2_power = rgi2*zee_dbd_power
generate rgi2_danger = rgi2*zee_dbd_danger

generate rgi3_strategy_opin = rgi3*zee_dbd_strategy_opin
generate rgi3_strategy_sarc = rgi3*zee_dbd_strategy_sarc
generate rgi3_strategy_construct = rgi3*zee_dbd_strategy_construct
generate rgi3_goal2_out_negative = rgi3*zee_dbd_goal2_out_negative
generate rgi3_goal2_in_both_pos = rgi3*zee_dbd_goal2_in_both_pos
generate rgi3_anger = rgi3*zee_dbd_anger
generate rgi3_fear = rgi3*zee_dbd_fear
generate rgi3_disgust = rgi3*zee_dbd_disgust
generate rgi3_sadness = rgi3*zee_dbd_sadness
generate rgi3_enthop = rgi3*zee_dbd_enthop
generate rgi3_prijoy = rgi3*zee_dbd_prijoy
generate rgi3_power = rgi3*zee_dbd_power
generate rgi3_danger = rgi3*zee_dbd_danger

generate zee_dbd_enthop2 = zee_dbd_enthop*zee_dbd_enthop

 
// correlations
corr zee_dbd_speech_hate_yes  zee_dbd_tox zee_dbd_extreme_score zee_dbd_user_group_70e ///
zee_dbd_strategy_opin zee_dbd_strategy_construct zee_dbd_strategy_sarc dbd_strategy_leave_fact zee_dbd_strategy_other ///
zee_dbd_topic_out zee_dbd_topic_not_out ///
zee_dbd_goal2_in_both_pos zee_dbd_goal2_out_negative zee_dbd_goal2_neutral_unint ///
zee_dbd_anger zee_dbd_fear zee_dbd_disgust zee_dbd_sadness zee_dbd_enthop zee_dbd_prijoy 

// adf for each variable
foreach x in zee_dbd_speech_hate_yes  zee_dbd_tox zee_dbd_extreme_score zee_dbd_user_group_70e zee_dbd_strategy_opin zee_dbd_strategy_sarc zee_dbd_strategy_construct zee_dbd_goal2_out_negative zee_dbd_goal2_in_both_pos zee_dbd_anger zee_dbd_fear zee_dbd_disgust zee_dbd_sadness zee_dbd_enthop zee_dbd_prijoy {
dfuller `x', lags(2) trend regress
}

// ardl days - tox
eststo clear
ardl zee_dbd_tox zee_dbd_strategy_opin zee_dbd_strategy_sarc zee_dbd_strategy_construct zee_dbd_goal2_out_negative zee_dbd_goal2_in_both_pos zee_dbd_anger zee_dbd_fear ///
zee_dbd_disgust zee_dbd_sadness zee_dbd_enthop zee_dbd_prijoy, ///
maxlags(2) maxcombs(100000000) exog(rgi2 rgi3 ///
rgi2_strategy_opin rgi2_strategy_sarc rgi2_strategy_construct rgi2_goal2_out_negative ///
rgi2_goal2_in_both_pos rgi2_anger rgi2_fear rgi2_disgust rgi2_sadness rgi2_enthop rgi2_prijoy ///
rgi3_strategy_opin rgi3_strategy_sarc rgi3_strategy_construct rgi3_goal2_out_negative ///
rgi3_goal2_in_both_pos rgi3_anger rgi3_fear rgi3_disgust rgi3_sadness rgi3_enthop rgi3_prijoy) ///
aic fast regstore(ecreg) trendvar(dbd_dayn) dots perfect 
estat ic
estimates restore ecreg 
`e(cmdline)' vce(robust)
estimates store ecreg_rob
eststo ecreg_rob
vif
estadd matrix x=e(b)
esttab ecreg_rob using reg_byday_joint_tox_rob.csv, se nostar

// ardl days - extreme score
eststo clear
ardl zee_dbd_extreme_score zee_dbd_strategy_opin zee_dbd_strategy_sarc zee_dbd_strategy_construct zee_dbd_goal2_out_negative zee_dbd_goal2_in_both_pos zee_dbd_anger zee_dbd_fear ///
zee_dbd_disgust zee_dbd_sadness zee_dbd_enthop zee_dbd_prijoy, ///
maxlags(2) maxcombs(100000000) exog(rgi2 rgi3 ///
rgi2_strategy_opin rgi2_strategy_sarc rgi2_strategy_construct rgi2_goal2_out_negative ///
rgi2_goal2_in_both_pos rgi2_anger rgi2_fear rgi2_disgust rgi2_sadness rgi2_enthop rgi2_prijoy ///
rgi3_strategy_opin rgi3_strategy_sarc rgi3_strategy_construct rgi3_goal2_out_negative ///
rgi3_goal2_in_both_pos rgi3_anger rgi3_fear rgi3_disgust rgi3_sadness rgi3_enthop rgi3_prijoy) ///
aic fast regstore(ecreg) trendvar(dbd_dayn) dots perfect 
estat ic
estimates restore ecreg 
`e(cmdline)' vce(robust)
estimates store ecreg_rob
eststo ecreg_rob
vif
estadd matrix x=e(b)
esttab ecreg_rob using reg_byday_joint_extsp_rob.csv, se nostar

// ardl days - hate speech
eststo clear
ardl zee_dbd_speech_hate_yes zee_dbd_strategy_opin zee_dbd_strategy_sarc zee_dbd_strategy_construct zee_dbd_goal2_out_negative zee_dbd_goal2_in_both_pos zee_dbd_anger zee_dbd_fear ///
zee_dbd_disgust zee_dbd_sadness zee_dbd_enthop zee_dbd_prijoy, ///
maxlags(2) maxcombs(100000000)  ///
aic fast regstore(ecreg) trendvar(dbd_dayn) dots perfect 
estat ic
estimates restore ecreg 
`e(cmdline)' vce(robust)
estimates store ecreg_rob
eststo ecreg_rob
vif
estadd matrix x=e(b)
esttab ecreg_rob using reg_byday_joint_hate_rob.csv, se nostar

estimates restore ecreg_rob
estat imtest, white
rvfplot
graph save rvfplot_dbd_hate, replace
drop resid
predict resid, residuals
sktest resid
hist resid, normal
graph save histres_dbd_hate, replace
qnorm resid
graph save qnorm_dbd_hate, replace
estat bgodfrey, lags(1/3) small
estat sbcusum, ols ylabel(, angle(horizontal))
graph save cusum_dbd_hate, replace


// ardl days - extreme users
eststo clear
ardl zee_dbd_user_group_70e zee_dbd_strategy_opin zee_dbd_strategy_sarc zee_dbd_strategy_construct zee_dbd_goal2_out_negative zee_dbd_goal2_in_both_pos zee_dbd_anger zee_dbd_fear ///
zee_dbd_disgust zee_dbd_sadness zee_dbd_enthop zee_dbd_prijoy, ///
maxlags(2) maxcombs(100000000) exog(rgi2 rgi3 ///
rgi2_strategy_opin rgi2_strategy_sarc rgi2_strategy_construct rgi2_goal2_out_negative ///
rgi2_goal2_in_both_pos rgi2_anger rgi2_fear rgi2_disgust rgi2_sadness rgi2_enthop rgi2_prijoy ///
rgi3_strategy_opin rgi3_strategy_sarc rgi3_strategy_construct rgi3_goal2_out_negative ///
rgi3_goal2_in_both_pos rgi3_anger rgi3_fear rgi3_disgust rgi3_sadness rgi3_enthop rgi3_prijoy) ///
aic fast regstore(ecreg) trendvar(dbd_dayn) dots perfect 
estat ic
estimates restore ecreg 
`e(cmdline)' vce(robust)
estimates store ecreg_rob
eststo ecreg_rob
vif
estadd matrix x=e(b)
esttab ecreg_rob using reg_byday_joint_extind_rob.csv, se nostar

// post tests
estimates restore ecreg_rob
estat imtest, white
rvfplot
graph save rvfplot_dbd_extind, replace
drop resid
predict resid, residuals
sktest resid
hist resid, normal
graph save histres_dbd_extind, replace
qnorm resid
graph save qnorm_dbd_extind, replace
estat bgodfrey, lags(1/3) small
estat sbcusum, ols ylabel(, angle(horizontal))
graph save cusum_dbd_extind, replace



