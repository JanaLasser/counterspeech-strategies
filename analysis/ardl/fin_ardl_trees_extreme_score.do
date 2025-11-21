// ardl trees - extreme score

set matsize 10000

cd "C:\Users\mirta\Dropbox\SFI Reconquista\00 strategies\analyses\trees100d\trees100d" 
local files : dir "C:\Users\mirta\Dropbox\SFI Reconquista\00 strategies\analyses\trees100d\trees100d" files "*.xlsx"
foreach file in `files' {

  capture noisily eststo clear   
  
  capture noisily dir `file'
  
  capture noisily import excel `file', sheet("Sheet1") firstrow clear

  capture noisily tsset tweet_nr3
  
  capture noisily generate extreme_score=abs(.5-hate_score)
  capture noisily egen enthop=rowmean(enthusiasm hope)
  capture noisily egen prijoy=rowmean(pride joy)
   
  norm extreme_score strategy_opin strategy_sarc strategy_construct goal2_out_negative goal2_in_both_pos anger fear ///
  disgust sadness enthop prijoy , method(zee)
		
  capture noisily ardl zee_extreme_score zee_strategy_opin zee_strategy_sarc zee_strategy_construct ///
  zee_goal2_out_negative zee_goal2_in_both_pos zee_anger zee_fear ///
  zee_disgust zee_sadness zee_enthop zee_prijoy , ///
	maxlags(2) maxcombs(100000000) aic fast regstore(ecreg) trendvar(tweet_nr3) dots perfect
  capture noisily eststo: estimates restore ecreg
  capture noisily `e(cmdline)' vce(robust)

  estadd matrix x=e(b)  
  capture esttab using "C:\Users\mirta\Dropbox\SFI Reconquista\00 strategies\analyses\trees100d\extsp_joint_rob3\regs_extsp_`file'.csv", se nostar 
}

// tests
estimates restore ecreg
estat imtest, white
rvfplot
drop resid
predict resid, residuals
sktest resid
hist resid, normal
qnorm resid
estat bgodfrey, lags(1/3) small
estat sbcusum, ols ylabel(, angle(horizontal))

