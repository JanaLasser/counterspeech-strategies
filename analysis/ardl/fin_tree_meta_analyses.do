// //// meta analysis of coefficients for trees ////


local j=0
foreach x in tox_joint_rob3 extsp_joint_rob3 hate_joint_rob3 extind_joint_rob3 { 

local j=`j'+1
if `j'==1 { 
local fvar = "L1_zee_tox" 
}
if `j'==2 { 
local fvar = "L1_zee_extreme_score" 
}
if `j'==3 { 
local fvar = "L1_zee_speech_hate_yes" 
}
if `j'==4 { 
local fvar = "L1_zee_user_group_70e" 
}


cd "C:\Users\mirta\Dropbox\SFI Reconquista\00 strategies\analyses\trees100\" 
cd `x'

import excel "for_meta.xlsx", sheet("Sheet1") firstrow clear
save "for_meta.dta", replace
use "for_meta.dta", clear 

// return list

// save estimates
putexcel set metaresults, replace
putexcel A1 = "variable"
putexcel B1 = "weghted average coef."
putexcel C1 = "coef CI low"
putexcel D1 = "coef CI high"
putexcel E1 = "I2"
putexcel F1 = "I2 CI low"
putexcel G1 = "I2 CI high"
putexcel H1 = "tau2"
putexcel I1 = "tau2 CI low"
putexcel J1 = "tau2 CI high"
putexcel K1 = "df"

//rename se__cons se_cons

local i=2
foreach var of varlist `fvar' - cons {   // change start var
	capture metaan `var' se_`var', pl
	putexcel A`i' = "`var'"
	putexcel B`i' = (r(eff))
	putexcel C`i' = (r(efflo))
	putexcel D`i' = (r(effup))
	putexcel E`i' = (r(Isq))
	putexcel F`i' = (r(Isq_lo))
	putexcel G`i' = (r(Isq_up))
	putexcel H`i' = (r(tausq_pl))
	putexcel I`i' = (r(tausqlo_pl))
	putexcel J`i' = (r(tausqup_pl))	
	putexcel K`i' = (r(df))	
	local i=`i'+1
}
}


// //// extract tree data from tree files ////
cd "C:\Users\mirta\Dropbox\SFI Reconquista\00 strategies\analyses\trees100" 
local files : dir "C:\Users\mirta\Dropbox\SFI Reconquista\00 strategies\analyses\trees100" files "*.xlsx"

set matsize 10000
matrix tree_data = J(3660,10,.)
//matrix colname tree_data = Junior

forvalues i=1/3660 {
 
  import excel d_basic_50_`i'.xlsx, sheet("Sheet1") firstrow clear
    
  matrix tree_data[`i',1] = `i'
  
  quietly sum dayn  
  matrix tree_data[`i',2] = r(min)
  
  quietly sum tree_max4  
  matrix tree_data[`i',3] = r(min)

  quietly sum root_account2  
  matrix tree_data[`i',4] = r(min)
  
  quietly sum date
  matrix tree_data[`i',5] = r(min)
  matrix tree_data[`i',6] = r(max)
  matrix tree_data[`i',7] = (r(max)-r(min))/1000/60/60 // to get hours
  
  quietly unique user_twitter_id
  matrix tree_data[`i',8] = r(unique) 

  quietly tab user_group_70rg if user_group_70rg==1
  matrix tree_data[`i',9] = r(N) 
  
  quietly tab user_group_70ri if user_group_70ri==1
  matrix tree_data[`i',10] = r(N) 

  }

matrix list tree_data
putexcel set "tree_data.xls", replace
putexcel A1=matrix(tree_data)

cd "C:\Users\mirta\Dropbox\SFI Reconquista\00 strategies\analyses\trees100" 
import excel "tree_data.xls", sheet("Sheet1") clear
rename (A B C D E F G H I J) (regnum dayn tree_max4 root_account2 mindate maxdate difhours uniqusers rgt rit)
recode root_account2 (1=1) (4=1) (6=1) (11=1) (13=1) (14=1) (17=1) (21=1) ///
 (8=2) (15=2) (18=2) (10=2) (3=2) (20=2) (16=2) ///
 (22=3) (9=3) (5=3) (12=3) (2=3) (7=3) (19=3), generate(root_type) // 1 news, 2 journ, 3 polit
save "tree_data.dta", replace

use  "tree_data.dta", clear


// //// meta regressions of tree-level ardl analyses ////
local j=0
foreach x in tox_joint_rob3 extsp_joint_rob3 hate_joint_rob3 extind_joint_rob3 { 

cd "C:\Users\mirta\Dropbox\SFI Reconquista\00 strategies\analyses\trees50\" 
cd `x'

use "for_meta.dta", clear 

drop if regnum==.

quietly merge 1:1 regnum using "C:\Users\mirta\Dropbox\SFI Reconquista\00 strategies\analyses\trees50\tree_data.dta"

generate rgi1_=0
generate rgi2_=0
generate rgi3_=0
replace rgi1_=1 if dayn<=1462 // before Jan 1 2017
replace rgi2_=1 if dayn>=1463 & dayn<=1947 // between Jan 1 2017 and April 30 2018
replace rgi3_=1 if dayn>=1948 // from May 1 2018

generate jour=0
generate polit=0
replace jour=1 if root_account2==8 | root_account2==15 | root_account2==18 | root_account2==10 | ///
	root_account2==3 | root_account2==20 | root_account2==16
replace polit=1 if root_account2==22 | root_account2==9 | root_account2==5 | root_account2==12 | ///
	root_account2==2 | root_account2==7 | root_account2==19

generate prgt=rgt/tree_max4
generate prit=rit/tree_max4

norm rgi2_ rgi3_ jour polit tree_max4 difhours uniqusers prgt prit, method(zee)


eststo clear
	
quietly metareg zee_strategy_opin zee_rgi2_ zee_rgi3_ zee_jour zee_polit zee_tree_max4 zee_difhours zee_uniqusers zee_prgt zee_prit,  wsse(se_zee_strategy_opin)
estimates store m1, title(opin)

quietly metareg zee_strategy_sarc zee_rgi2_ zee_rgi3_ zee_jour zee_polit zee_tree_max4 zee_difhours zee_uniqusers zee_prgt zee_prit,  wsse(se_zee_strategy_sarc)
estimates store m2, title(sarc)

quietly metareg zee_strategy_construct zee_rgi2_ zee_rgi3_ zee_jour zee_polit zee_tree_max4 zee_difhours zee_uniqusers zee_prgt zee_prit,  wsse(se_zee_strategy_construct)
estimates store m3, title(const)

quietly metareg zee_goal2_out_negative zee_rgi2_ zee_rgi3_ zee_jour zee_polit zee_tree_max4 zee_difhours zee_uniqusers zee_prgt zee_prit,  wsse(se_zee_goal2_out_negative)
estimates store m4, title(gneg)

quietly metareg zee_goal2_in_both_positive zee_rgi2_ zee_rgi3_ zee_jour zee_polit zee_tree_max4 zee_difhours zee_uniqusers zee_prgt zee_prit,  wsse(se_zee_goal2_in_both_positive)
estimates store m5, title(gpos)

quietly metareg zee_anger zee_rgi2_ zee_rgi3_ zee_jour zee_polit zee_tree_max4 zee_difhours zee_uniqusers zee_prgt zee_prit,  wsse(se_zee_anger)
estimates store m6, title(ang)

quietly metareg zee_fear zee_rgi2_ zee_rgi3_ zee_jour zee_polit zee_tree_max4 zee_difhours zee_uniqusers zee_prgt zee_prit,  wsse(se_zee_fear)
estimates store m7, title(fear)

quietly metareg zee_disgust zee_rgi2_ zee_rgi3_ zee_jour zee_polit zee_tree_max4 zee_difhours zee_uniqusers zee_prgt zee_prit,  wsse(se_zee_disgust)
estimates store m8, title(disg)

quietly metareg zee_sadness zee_rgi2_ zee_rgi3_ zee_jour zee_polit zee_tree_max4 zee_difhours zee_uniqusers zee_prgt zee_prit,  wsse(se_zee_sadness)
estimates store m9, title(sad)

quietly metareg zee_enthop zee_rgi2_ zee_rgi3_ zee_jour zee_polit zee_tree_max4 zee_difhours zee_uniqusers zee_prgt zee_prit,  wsse(se_zee_enthop)
estimates store m10, title(enth)

quietly metareg zee_prijoy zee_rgi2_ zee_rgi3_ zee_jour zee_polit zee_tree_max4 zee_difhours zee_uniqusers zee_prgt zee_prit,  wsse(se_zee_prijoy)
estimates store m11, title(prij)

estout m1 m2 m3 m4 m5 m6 m7 m8 m9 m10 m11, cells(b(star fmt(3)) se(par fmt(3)) p(par fmt(3))) ///
   legend label varlabels(_cons Constant) ///
   stats(aic) starlevels(+ 0.10 * 0.05 ** 0.01)  
   
// putexcel set "metareg.xls", replace
// putexcel A1=matrix(r(coefs))   
//   
   }

