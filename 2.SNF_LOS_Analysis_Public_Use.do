/*******************************************************************************************************
*Create tables and figures for AJHE publication 
*******************************************************************************************************/

use "/secure/project/PACUse_RWerner/Mingyu/SNF_LOS/Data/snf_los_county_ma_1016_final_E.dta", replace 



***Table 1. Characteristics of study sample (in the full study sample and stratified by observed length of SNF stays)

**Whole sample 

	sum age_adm
	tab sex_num  
	tab race_num 
	tab married_im 
	sum med_hoshd_inc
	sum unemplmt_rate 
	sum povty_rate 
	sum soi 
	sum prior_pmt_amt_sum 
	sum hosp_days_all 

	gen drg_470=1 if drg_cd == 470
	replace drg_470=0 if drg_cd != 470
	
	gen drg_871=1 if drg_cd == 871
	replace drg_871=0 if drg_cd != 871
	
	gen drg_481=1 if drg_cd == 481
	replace drg_481=0 if drg_cd != 481
	
	gen drg_690=1 if drg_cd == 690
	replace drg_690=0 if drg_cd != 690
	
	gen drg_291=1 if drg_cd == 291
	replace drg_291=0 if drg_cd != 291
	
	tab drg_470 
	tab drg_871 
	tab drg_481 
	tab drg_690 
	tab drg_291 

**subsamples by observed SNF LOS

*Create a categorical variable based on observed SNF LOS
	gen snflos_group = 1 if util_day_snf>=1 & util_day_snf<=14
	replace snflos_group = 2 if util_day_snf>14 & util_day_snf<=20
	replace snflos_group = 3 if util_day_snf>20 & util_day_snf<=30
	replace snflos_group = 4 if util_day_snf>30 
	tab snflos_group, m

*Check patient covariates by observed SNF LOS group
	version 16: table snflos_group, c(mean age_adm sd age_adm)
	tab sex_num  snflos_group, col
	tab race_num snflos_group, col
	tab married_im snflos_group, col
	version 16: table snflos_group, c(mean med_hoshd_inc sd med_hoshd_inc)
	version 16: table snflos_group, c(mean unemplmt_rate sd unemplmt_rate)
	version 16: table snflos_group, c(mean povty_rate sd povty_rate)
	version 16: table snflos_group, c(mean soi sd soi)
	version 16: table snflos_group, c(mean prior_pmt_amt_sum sd prior_pmt_amt_sum)
	version 16: table snflos_group, c(mean hosp_days_all sd hosp_days_all)

*Check number and percentage of 5 most common DRGs by observed SNF LOS group
	
	tab drg_470 snflos_group, col
	tab drg_871 snflos_group, col
	tab drg_481 snflos_group, col
	tab drg_690 snflos_group, col
	tab drg_291 snflos_group, col

	
	
***Table 2. Effects of SNF length of stay on patient outcomes and Medicarepayment, estimated using ordinary least squares and two-stage least squares

*Summarize outcome variables 	
 	sum util_day_snf, d
 	sum radm7snf
 	sum radm14snf
 	sum radm30snf
  	sum successful_discharge
 	sum pmt_amt_snf
 	sum pmt_after_snf_30_pac
 	sum pmt_after_snf_30_sum_acute
 	sum pmt_after_snf_30_all
 	
*OLS regressions on whole sample
	
	quietly xtreg radm7snf util_day_snf $pt_covar ndays7_snf, i(snf_providernum) fe vce(robust)
		estimates store radm7snf
	quietly xtreg radm14snf util_day_snf $pt_covar ndays14_snf, i(snf_providernum) fe vce(robust)
		estimates store radm14snf
	quietly xtreg radm30snf util_day_snf $pt_covar ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store radm30snf
	quietly xtreg successful_discharge util_day_snf $pt_covar, i(snf_providernum) fe vce(robust)
		estimates store suc_dschrg
	quietly xtreg pmt_amt_snf util_day_snf $pt_covar, i(snf_providernum) fe vce(robust)
		estimates store pmt_amt_snf
	quietly xtreg pmt_after_snf_30_pac util_day_snf $pt_covar ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_pac
	quietly xtreg pmt_after_snf_30_sum_acute util_day_snf $pt_covar ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_acute
	quietly xtreg pmt_after_snf_30_all util_day_snf $pt_covar ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_all
	est table radm7snf radm14snf radm30snf suc_dschrg pmt_amt_snf pmt_snf_30_pac pmt_snf_30_acute pmt_snf_30_all, keep(util_day_snf) b se t p stats(N) title("OLS on Whole Sample)")
	eststo clear

*2SLS regressions on whole sample with SNF fixed-effects
	
	*First stage
	quietly xtreg util_day_snf county_year_ma_pct $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store first_stage
		predict pr_snflos if e(sample)
		est table first_stage, keep(county_year_ma_pct) b se t p stats(N) title("1st Stage") 
		eststo clear
	
	*Summary of predicted SNF LOS
	sum pr_snflos, d
	
	*Second stage 
	quietly xtreg radm7snf pr_snflos $pt_covar2 ndays7_snf, i(snf_providernum) fe vce(robust)
		estimates store radm7snf
	quietly xtreg radm14snf pr_snflos $pt_covar2 ndays14_snf, i(snf_providernum) fe vce(robust)
		estimates store radm14snf
	quietly xtreg radm30snf pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store radm30snf
	quietly xtreg successful_discharge pr_snflos $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store suc_dschrg
	quietly xtreg pmt_amt_snf pr_snflos $pt_covar, i(snf_providernum) fe vce(robust)
		estimates store pmt_amt_snf
	quietly xtreg pmt_after_snf_30_pac pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_pac
	quietly xtreg pmt_after_snf_30_sum_acute pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_acute
	quietly xtreg pmt_after_snf_30_all pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_all
	est table radm7snf radm14snf radm30snf suc_dschrg pmt_amt_snf pmt_snf_30_pac pmt_snf_30_acute pmt_snf_30_all, keep(pr_snflos) b se t p stats(N) title("2nd Stage")
	eststo clear

*2SLS regressions on whole sample with year fixed-effects 
	
	*First stage
	quietly xtreg util_day_snf county_year_ma_pct $pt_covar2, i(dschrg_year) fe vce(robust)
		estimates store first_stage
		predict pr_snflos if e(sample)
		est table first_stage, keep(county_year_ma_pct) b se t p stats(N) title("1st Stage") 
		eststo clear
	
	*Summary of predicted SNF LOS
	sum pr_snflos, d
	
	*Second stage 
	quietly xtreg radm7snf pr_snflos $pt_covar2 ndays7_snf, i(dschrg_year) fe vce(robust)
		estimates store radm7snf
	quietly xtreg radm14snf pr_snflos $pt_covar2 ndays14_snf, i(dschrg_year) fe vce(robust)
		estimates store radm14snf
	quietly xtreg radm30snf pr_snflos $pt_covar2 ndays30_snf, i(dschrg_year) fe vce(robust)
		estimates store radm30snf
	quietly xtreg successful_discharge pr_snflos $pt_covar2, i(dschrg_year) fe vce(robust)
		estimates store suc_dschrg
	quietly xtreg pmt_amt_snf pr_snflos $pt_covar, i(dschrg_year) fe vce(robust)
		estimates store pmt_amt_snf
	quietly xtreg pmt_after_snf_30_pac pr_snflos $pt_covar2 ndays30_snf, i(dschrg_year) fe vce(robust)
		estimates store pmt_snf_30_pac
	quietly xtreg pmt_after_snf_30_sum_acute pr_snflos $pt_covar2 ndays30_snf, i(dschrg_year) fe vce(robust)
		estimates store pmt_snf_30_acute
	quietly xtreg pmt_after_snf_30_all pr_snflos $pt_covar2 ndays30_snf, i(dschrg_year) fe vce(robust)
		estimates store pmt_snf_30_all
	est table radm7snf radm14snf radm30snf suc_dschrg pmt_amt_snf pmt_snf_30_pac pmt_snf_30_acute pmt_snf_30_all, keep(pr_snflos) b se t p stats(N) title("2nd Stage")
	eststo clear

	
	
***Table 3. Effects of SNF length of stay on patient outcomes and Medicare payment estimated using two-stage least squares,stratified by clinical complexity (estimated by predicted length of SNF stay)

*Use Medicare Advantage Cohort
	clear all
	use "/secure/project/PACUse_RWerner/Mingyu/SNF_LOS/Data/snf_los_county_ma_1016_ma_E.dta", replace 

*Define patient covariates
	global pt_covar1 age_adm i.race_num i.sex_num i.drg_cd i.married_im med_hoshd_inc unemplmt_rate povty_rate hosp_days_all hxinfection otherinfectious metacancer severecancer othercancer diabetes malnutrition liverdisease hematological alcohol psychological motordisfunction seizure chf cadcvd arrhythmias copd lungdisorder ondialysis ulcers septicemia metabolicdisorder irondeficiency cardiorespiratory renalfailure pancreaticdisease arthritis respiratordependence transplants coagulopathy hipfracture
	
*Use same covariates used in main analysis to predict SNF LOS in MA sample
	quietly xtreg util_day_mds $pt_covar1, i(snf_providernum) fe vce(robust)
	estimates store snflos_ma
	predict pr_snflos_ma 

*Summary of predicted SNF LOS in MA sample
	sum pr_snflos_ma, d
	
*Use coefficients obtained from above model to predict SNF LOS in FFS sample
	use "/secure/project/PACUse_RWerner/Mingyu/SNF_LOS/Data/snf_los_county_ma_1016_final_E.dta", replace 
	predict pr_snflos_ffs 

***Summary of predicted SNF LOS in FFS sample
	sum pr_snflos_ffs, d
	
*Define patient covariates
	global pt_covar2 age_adm i.race_num i.sex_num i.drg_cd i.rug4num i.married_im med_hoshd_inc unemplmt_rate povty_rate hosp_days_all prior_pmt_amt_sum hxinfection otherinfectious metacancer severecancer othercancer diabetes malnutrition liverdisease hematological alcohol psychological motordisfunction seizure chf cadcvd arrhythmias copd lungdisorder ondialysis ulcers septicemia metabolicdisorder irondeficiency cardiorespiratory renalfailure pancreaticdisease arthritis respiratordependence transplants coagulopathy hipfracture

*Run IV regressions in bins: <=14, 14<LOS<=20, 20<LOS<=30, LOS>30

/******************
 SNF LOS <=14
******************/
 	preserve 
 	keep if pr_snflos_ffs <= 14 
 	
 	sum util_day_snf, d
 	sum radm7snf
 	sum radm14snf
 	sum radm30snf
 	sum successful_discharge
	sum pmt_amt_snf
 	sum pmt_after_snf_30_pac
 	sum pmt_after_snf_30_sum_acute
 	sum pmt_after_snf_30_all

 	
*2SLS regressions with county-year level %MA as IV
	
	*First stage
	quietly xtreg util_day_snf county_year_ma_pct $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store first_stage
		predict pr_snflos if e(sample)
		est table first_stage, keep(county_year_ma_pct) b se t p stats(N) title("1st Stage") 
		eststo clear
	
	*Summary of predicted SNF LOS
	sum pr_snflos, d
	
	*Second stage 
	quietly xtreg radm7snf pr_snflos $pt_covar2 ndays7_snf, i(snf_providernum) fe vce(robust)
		estimates store radm7snf
	quietly xtreg radm14snf pr_snflos $pt_covar2 ndays14_snf, i(snf_providernum) fe vce(robust)
		estimates store radm14snf
	quietly xtreg radm30snf pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store radm30snf
	quietly xtreg successful_discharge pr_snflos $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store suc_dschrg
	quietly xtreg pmt_amt_snf pr_snflos $pt_covar, i(snf_providernum) fe vce(robust)
		estimates store pmt_amt_snf
	quietly xtreg pmt_after_snf_30_pac pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_pac
	quietly xtreg pmt_after_snf_30_sum_acute pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_acute
	quietly xtreg pmt_after_snf_30_all pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_all
	est table radm7snf radm14snf radm30snf suc_dschrg pmt_amt_snf pmt_snf_30_pac pmt_snf_30_acute pmt_snf_30_all, keep(pr_snflos) b se t p stats(N) title("2nd Stage")
	eststo clear
	
	restore 

/******************
 SNF LOS (14, 20]
******************/
 	preserve 
 	keep if pr_snflos_ffs > 14 & pr_snflos_ffs <= 20
 	
 	sum util_day_snf, d
 	sum radm7snf
 	sum radm14snf
 	sum radm30snf
 	sum successful_discharge
	sum pmt_amt_snf
 	sum pmt_after_snf_30_pac
 	sum pmt_after_snf_30_sum_acute
 	sum pmt_after_snf_30_all

 	
*2SLS regressions with county-year level %MA as IV
	
	*First stage
	quietly xtreg util_day_snf county_year_ma_pct $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store first_stage
		predict pr_snflos if e(sample)
		est table first_stage, keep(county_year_ma_pct) b se t p stats(N) title("1st Stage") 
		eststo clear
	
	*Summary of predicted SNF LOS
	sum pr_snflos, d
	
	*Second stage 
	quietly xtreg radm7snf pr_snflos $pt_covar2 ndays7_snf, i(snf_providernum) fe vce(robust)
		estimates store radm7snf
	quietly xtreg radm14snf pr_snflos $pt_covar2 ndays14_snf, i(snf_providernum) fe vce(robust)
		estimates store radm14snf
	quietly xtreg radm30snf pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store radm30snf
	quietly xtreg successful_discharge pr_snflos $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store suc_dschrg
	quietly xtreg pmt_amt_snf pr_snflos $pt_covar, i(snf_providernum) fe vce(robust)
		estimates store pmt_amt_snf
	quietly xtreg pmt_after_snf_30_pac pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_pac
	quietly xtreg pmt_after_snf_30_sum_acute pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_acute
	quietly xtreg pmt_after_snf_30_all pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_all
	est table radm7snf radm14snf radm30snf suc_dschrg pmt_amt_snf pmt_snf_30_pac pmt_snf_30_acute pmt_snf_30_all, keep(pr_snflos) b se t p stats(N) title("2nd Stage")
	eststo clear
	
	restore 

/******************
 SNF LOS (20,30]
******************/
 	preserve 
 	keep if pr_snflos_ffs > 20 & pr_snflos_ffs <= 30
 	
 	sum util_day_snf, d
 	sum radm7snf
 	sum radm14snf
 	sum radm30snf
 	sum successful_discharge
	sum pmt_amt_snf
 	sum pmt_after_snf_30_pac
 	sum pmt_after_snf_30_sum_acute
 	sum pmt_after_snf_30_all

 	
*2SLS regressions with county-year level %MA as IV
	
	*First stage
	quietly xtreg util_day_snf county_year_ma_pct $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store first_stage
		predict pr_snflos if e(sample)
		est table first_stage, keep(county_year_ma_pct) b se t p stats(N) title("1st Stage") 
		eststo clear
	
	*Summary of predicted SNF LOS
	sum pr_snflos, d
	
	*Second stage 
	quietly xtreg radm7snf pr_snflos $pt_covar2 ndays7_snf, i(snf_providernum) fe vce(robust)
		estimates store radm7snf
	quietly xtreg radm14snf pr_snflos $pt_covar2 ndays14_snf, i(snf_providernum) fe vce(robust)
		estimates store radm14snf
	quietly xtreg radm30snf pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store radm30snf
	quietly xtreg successful_discharge pr_snflos $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store suc_dschrg
	quietly xtreg pmt_amt_snf pr_snflos $pt_covar, i(snf_providernum) fe vce(robust)
		estimates store pmt_amt_snf
	quietly xtreg pmt_after_snf_30_pac pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_pac
	quietly xtreg pmt_after_snf_30_sum_acute pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_acute
	quietly xtreg pmt_after_snf_30_all pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_all
	est table radm7snf radm14snf radm30snf suc_dschrg pmt_amt_snf pmt_snf_30_pac pmt_snf_30_acute pmt_snf_30_all, keep(pr_snflos) b se t p stats(N) title("2nd Stage")
	eststo clear
	
	restore 

/******************
 SNF LOS >30
******************/
 	preserve 
 	keep if pr_snflos_ffs > 30
 	
 	sum util_day_snf, d
 	sum radm7snf
 	sum radm14snf
 	sum radm30snf
 	sum successful_discharge
	sum pmt_amt_snf
 	sum pmt_after_snf_30_pac
 	sum pmt_after_snf_30_sum_acute
 	sum pmt_after_snf_30_all

 	
*2SLS regressions with county-year level %MA as IV
	
	*First stage
	quietly xtreg util_day_snf county_year_ma_pct $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store first_stage
		predict pr_snflos if e(sample)
		est table first_stage, keep(county_year_ma_pct) b se t p stats(N) title("1st Stage") 
		eststo clear
	
	*Summary of predicted SNF LOS
	sum pr_snflos, d
	
	*Second stage 
	quietly xtreg radm7snf pr_snflos $pt_covar2 ndays7_snf, i(snf_providernum) fe vce(robust)
		estimates store radm7snf
	quietly xtreg radm14snf pr_snflos $pt_covar2 ndays14_snf, i(snf_providernum) fe vce(robust)
		estimates store radm14snf
	quietly xtreg radm30snf pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store radm30snf
	quietly xtreg successful_discharge pr_snflos $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store suc_dschrg
	quietly xtreg pmt_amt_snf pr_snflos $pt_covar, i(snf_providernum) fe vce(robust)
		estimates store pmt_amt_snf
	quietly xtreg pmt_after_snf_30_pac pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_pac
	quietly xtreg pmt_after_snf_30_sum_acute pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_acute
	quietly xtreg pmt_after_snf_30_all pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_all
	est table radm7snf radm14snf radm30snf suc_dschrg pmt_amt_snf pmt_snf_30_pac pmt_snf_30_acute pmt_snf_30_all, keep(pr_snflos) b se t p stats(N) title("2nd Stage")
	eststo clear
	
	restore 
	
	
***Table 4.Effects of SNF length of stay on patient outcomes and Medicare payment estimated using two-stage least squares,stratified by marital status and SNF profit status

/**********************************************************
 Married Patients
**********************************************************/	
	keep if married_im==1
	
/******************
 SNF LOS <=14
******************/
 	preserve 
 	keep if pr_snflos_ffs <= 14 
 	
 	sum util_day_snf, d
 	sum radm7snf
 	sum radm14snf
 	sum radm30snf
 	sum successful_discharge
	sum pmt_amt_snf
 	sum pmt_after_snf_30_pac
 	sum pmt_after_snf_30_sum_acute
 	sum pmt_after_snf_30_all

 	
*2SLS regressions with county-year level %MA as IV
	
	*First stage
	quietly xtreg util_day_snf county_year_ma_pct $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store first_stage
		predict pr_snflos if e(sample)
		est table first_stage, keep(county_year_ma_pct) b se t p stats(N) title("1st Stage") 
		eststo clear
	
	*Summary of predicted SNF LOS
	sum pr_snflos, d
	
	*Second stage 
	quietly xtreg radm7snf pr_snflos $pt_covar2 ndays7_snf, i(snf_providernum) fe vce(robust)
		estimates store radm7snf
	quietly xtreg radm14snf pr_snflos $pt_covar2 ndays14_snf, i(snf_providernum) fe vce(robust)
		estimates store radm14snf
	quietly xtreg radm30snf pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store radm30snf
	quietly xtreg successful_discharge pr_snflos $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store suc_dschrg
	quietly xtreg pmt_amt_snf pr_snflos $pt_covar, i(snf_providernum) fe vce(robust)
		estimates store pmt_amt_snf
	quietly xtreg pmt_after_snf_30_pac pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_pac
	quietly xtreg pmt_after_snf_30_sum_acute pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_acute
	quietly xtreg pmt_after_snf_30_all pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_all
	est table radm7snf radm14snf radm30snf suc_dschrg pmt_amt_snf pmt_snf_30_pac pmt_snf_30_acute pmt_snf_30_all, keep(pr_snflos) b se t p stats(N) title("2nd Stage")
	eststo clear
	
	restore 

/******************
 SNF LOS (14, 20]
******************/
 	preserve 
 	keep if pr_snflos_ffs > 14 & pr_snflos_ffs <= 20
 	
 	sum util_day_snf, d
 	sum radm7snf
 	sum radm14snf
 	sum radm30snf
 	sum successful_discharge
	sum pmt_amt_snf
 	sum pmt_after_snf_30_pac
 	sum pmt_after_snf_30_sum_acute
 	sum pmt_after_snf_30_all

 	
*2SLS regressions with county-year level %MA as IV
	
	*First stage
	quietly xtreg util_day_snf county_year_ma_pct $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store first_stage
		predict pr_snflos if e(sample)
		est table first_stage, keep(county_year_ma_pct) b se t p stats(N) title("1st Stage") 
		eststo clear
	
	*Summary of predicted SNF LOS
	sum pr_snflos, d
	
	*Second stage 
	quietly xtreg radm7snf pr_snflos $pt_covar2 ndays7_snf, i(snf_providernum) fe vce(robust)
		estimates store radm7snf
	quietly xtreg radm14snf pr_snflos $pt_covar2 ndays14_snf, i(snf_providernum) fe vce(robust)
		estimates store radm14snf
	quietly xtreg radm30snf pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store radm30snf
	quietly xtreg successful_discharge pr_snflos $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store suc_dschrg
	quietly xtreg pmt_amt_snf pr_snflos $pt_covar, i(snf_providernum) fe vce(robust)
		estimates store pmt_amt_snf
	quietly xtreg pmt_after_snf_30_pac pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_pac
	quietly xtreg pmt_after_snf_30_sum_acute pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_acute
	quietly xtreg pmt_after_snf_30_all pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_all
	est table radm7snf radm14snf radm30snf suc_dschrg pmt_amt_snf pmt_snf_30_pac pmt_snf_30_acute pmt_snf_30_all, keep(pr_snflos) b se t p stats(N) title("2nd Stage")
	eststo clear
	
	restore 

/******************
 SNF LOS (20,30]
******************/
 	preserve 
 	keep if pr_snflos_ffs > 20 & pr_snflos_ffs <= 30
 	
 	sum util_day_snf, d
 	sum radm7snf
 	sum radm14snf
 	sum radm30snf
 	sum successful_discharge
	sum pmt_amt_snf
 	sum pmt_after_snf_30_pac
 	sum pmt_after_snf_30_sum_acute
 	sum pmt_after_snf_30_all

 	
*2SLS regressions with county-year level %MA as IV
	
	*First stage
	quietly xtreg util_day_snf county_year_ma_pct $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store first_stage
		predict pr_snflos if e(sample)
		est table first_stage, keep(county_year_ma_pct) b se t p stats(N) title("1st Stage") 
		eststo clear
	
	*Summary of predicted SNF LOS
	sum pr_snflos, d
	
	*Second stage 
	quietly xtreg radm7snf pr_snflos $pt_covar2 ndays7_snf, i(snf_providernum) fe vce(robust)
		estimates store radm7snf
	quietly xtreg radm14snf pr_snflos $pt_covar2 ndays14_snf, i(snf_providernum) fe vce(robust)
		estimates store radm14snf
	quietly xtreg radm30snf pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store radm30snf
	quietly xtreg successful_discharge pr_snflos $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store suc_dschrg
	quietly xtreg pmt_amt_snf pr_snflos $pt_covar, i(snf_providernum) fe vce(robust)
		estimates store pmt_amt_snf
	quietly xtreg pmt_after_snf_30_pac pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_pac
	quietly xtreg pmt_after_snf_30_sum_acute pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_acute
	quietly xtreg pmt_after_snf_30_all pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_all
	est table radm7snf radm14snf radm30snf suc_dschrg pmt_amt_snf pmt_snf_30_pac pmt_snf_30_acute pmt_snf_30_all, keep(pr_snflos) b se t p stats(N) title("2nd Stage")
	eststo clear
	
	restore 

/******************
 SNF LOS >30
******************/
 	preserve 
 	keep if pr_snflos_ffs > 30
 	
 	sum util_day_snf, d
 	sum radm7snf
 	sum radm14snf
 	sum radm30snf
 	sum successful_discharge
	sum pmt_amt_snf
 	sum pmt_after_snf_30_pac
 	sum pmt_after_snf_30_sum_acute
 	sum pmt_after_snf_30_all

 	
*2SLS regressions with county-year level %MA as IV
	
	*First stage
	quietly xtreg util_day_snf county_year_ma_pct $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store first_stage
		predict pr_snflos if e(sample)
		est table first_stage, keep(county_year_ma_pct) b se t p stats(N) title("1st Stage") 
		eststo clear
	
	*Summary of predicted SNF LOS
	sum pr_snflos, d
	
	*Second stage 
	quietly xtreg radm7snf pr_snflos $pt_covar2 ndays7_snf, i(snf_providernum) fe vce(robust)
		estimates store radm7snf
	quietly xtreg radm14snf pr_snflos $pt_covar2 ndays14_snf, i(snf_providernum) fe vce(robust)
		estimates store radm14snf
	quietly xtreg radm30snf pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store radm30snf
	quietly xtreg successful_discharge pr_snflos $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store suc_dschrg
	quietly xtreg pmt_amt_snf pr_snflos $pt_covar, i(snf_providernum) fe vce(robust)
		estimates store pmt_amt_snf
	quietly xtreg pmt_after_snf_30_pac pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_pac
	quietly xtreg pmt_after_snf_30_sum_acute pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_acute
	quietly xtreg pmt_after_snf_30_all pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_all
	est table radm7snf radm14snf radm30snf suc_dschrg pmt_amt_snf pmt_snf_30_pac pmt_snf_30_acute pmt_snf_30_all, keep(pr_snflos) b se t p stats(N) title("2nd Stage")
	eststo clear
	
	restore 

/**********************************************************
 Single Patients
**********************************************************/	
	keep if married_im==0
	
/******************
 SNF LOS <=14
******************/
 	preserve 
 	keep if pr_snflos_ffs <= 14 
 	
 	sum util_day_snf, d
 	sum radm7snf
 	sum radm14snf
 	sum radm30snf
 	sum successful_discharge
	sum pmt_amt_snf
 	sum pmt_after_snf_30_pac
 	sum pmt_after_snf_30_sum_acute
 	sum pmt_after_snf_30_all

 	
*2SLS regressions with county-year level %MA as IV
	
	*First stage
	quietly xtreg util_day_snf county_year_ma_pct $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store first_stage
		predict pr_snflos if e(sample)
		est table first_stage, keep(county_year_ma_pct) b se t p stats(N) title("1st Stage") 
		eststo clear
	
	*Summary of predicted SNF LOS
	sum pr_snflos, d
	
	*Second stage 
	quietly xtreg radm7snf pr_snflos $pt_covar2 ndays7_snf, i(snf_providernum) fe vce(robust)
		estimates store radm7snf
	quietly xtreg radm14snf pr_snflos $pt_covar2 ndays14_snf, i(snf_providernum) fe vce(robust)
		estimates store radm14snf
	quietly xtreg radm30snf pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store radm30snf
	quietly xtreg successful_discharge pr_snflos $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store suc_dschrg
	quietly xtreg pmt_amt_snf pr_snflos $pt_covar, i(snf_providernum) fe vce(robust)
		estimates store pmt_amt_snf
	quietly xtreg pmt_after_snf_30_pac pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_pac
	quietly xtreg pmt_after_snf_30_sum_acute pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_acute
	quietly xtreg pmt_after_snf_30_all pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_all
	est table radm7snf radm14snf radm30snf suc_dschrg pmt_amt_snf pmt_snf_30_pac pmt_snf_30_acute pmt_snf_30_all, keep(pr_snflos) b se t p stats(N) title("2nd Stage")
	eststo clear
	
	restore 

/******************
 SNF LOS (14, 20]
******************/
 	preserve 
 	keep if pr_snflos_ffs > 14 & pr_snflos_ffs <= 20
 	
 	sum util_day_snf, d
 	sum radm7snf
 	sum radm14snf
 	sum radm30snf
 	sum successful_discharge
	sum pmt_amt_snf
 	sum pmt_after_snf_30_pac
 	sum pmt_after_snf_30_sum_acute
 	sum pmt_after_snf_30_all

 	
*2SLS regressions with county-year level %MA as IV
	
	*First stage
	quietly xtreg util_day_snf county_year_ma_pct $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store first_stage
		predict pr_snflos if e(sample)
		est table first_stage, keep(county_year_ma_pct) b se t p stats(N) title("1st Stage") 
		eststo clear
	
	*Summary of predicted SNF LOS
	sum pr_snflos, d
	
	*Second stage 
	quietly xtreg radm7snf pr_snflos $pt_covar2 ndays7_snf, i(snf_providernum) fe vce(robust)
		estimates store radm7snf
	quietly xtreg radm14snf pr_snflos $pt_covar2 ndays14_snf, i(snf_providernum) fe vce(robust)
		estimates store radm14snf
	quietly xtreg radm30snf pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store radm30snf
	quietly xtreg successful_discharge pr_snflos $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store suc_dschrg
	quietly xtreg pmt_amt_snf pr_snflos $pt_covar, i(snf_providernum) fe vce(robust)
		estimates store pmt_amt_snf
	quietly xtreg pmt_after_snf_30_pac pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_pac
	quietly xtreg pmt_after_snf_30_sum_acute pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_acute
	quietly xtreg pmt_after_snf_30_all pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_all
	est table radm7snf radm14snf radm30snf suc_dschrg pmt_amt_snf pmt_snf_30_pac pmt_snf_30_acute pmt_snf_30_all, keep(pr_snflos) b se t p stats(N) title("2nd Stage")
	eststo clear
	
	restore 

/******************
 SNF LOS (20,30]
******************/
 	preserve 
 	keep if pr_snflos_ffs > 20 & pr_snflos_ffs <= 30
 	
 	sum util_day_snf, d
 	sum radm7snf
 	sum radm14snf
 	sum radm30snf
 	sum successful_discharge
	sum pmt_amt_snf
 	sum pmt_after_snf_30_pac
 	sum pmt_after_snf_30_sum_acute
 	sum pmt_after_snf_30_all

 	
*2SLS regressions with county-year level %MA as IV
	
	*First stage
	quietly xtreg util_day_snf county_year_ma_pct $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store first_stage
		predict pr_snflos if e(sample)
		est table first_stage, keep(county_year_ma_pct) b se t p stats(N) title("1st Stage") 
		eststo clear
	
	*Summary of predicted SNF LOS
	sum pr_snflos, d
	
	*Second stage 
	quietly xtreg radm7snf pr_snflos $pt_covar2 ndays7_snf, i(snf_providernum) fe vce(robust)
		estimates store radm7snf
	quietly xtreg radm14snf pr_snflos $pt_covar2 ndays14_snf, i(snf_providernum) fe vce(robust)
		estimates store radm14snf
	quietly xtreg radm30snf pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store radm30snf
	quietly xtreg successful_discharge pr_snflos $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store suc_dschrg
	quietly xtreg pmt_amt_snf pr_snflos $pt_covar, i(snf_providernum) fe vce(robust)
		estimates store pmt_amt_snf
	quietly xtreg pmt_after_snf_30_pac pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_pac
	quietly xtreg pmt_after_snf_30_sum_acute pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_acute
	quietly xtreg pmt_after_snf_30_all pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_all
	est table radm7snf radm14snf radm30snf suc_dschrg pmt_amt_snf pmt_snf_30_pac pmt_snf_30_acute pmt_snf_30_all, keep(pr_snflos) b se t p stats(N) title("2nd Stage")
	eststo clear
	
	restore 

/******************
 SNF LOS >30
******************/
 	preserve 
 	keep if pr_snflos_ffs > 30
 	
 	sum util_day_snf, d
 	sum radm7snf
 	sum radm14snf
 	sum radm30snf
 	sum successful_discharge
	sum pmt_amt_snf
 	sum pmt_after_snf_30_pac
 	sum pmt_after_snf_30_sum_acute
 	sum pmt_after_snf_30_all

 	
*2SLS regressions with county-year level %MA as IV
	
	*First stage
	quietly xtreg util_day_snf county_year_ma_pct $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store first_stage
		predict pr_snflos if e(sample)
		est table first_stage, keep(county_year_ma_pct) b se t p stats(N) title("1st Stage") 
		eststo clear
	
	*Summary of predicted SNF LOS
	sum pr_snflos, d
	
	*Second stage 
	quietly xtreg radm7snf pr_snflos $pt_covar2 ndays7_snf, i(snf_providernum) fe vce(robust)
		estimates store radm7snf
	quietly xtreg radm14snf pr_snflos $pt_covar2 ndays14_snf, i(snf_providernum) fe vce(robust)
		estimates store radm14snf
	quietly xtreg radm30snf pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store radm30snf
	quietly xtreg successful_discharge pr_snflos $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store suc_dschrg
	quietly xtreg pmt_amt_snf pr_snflos $pt_covar, i(snf_providernum) fe vce(robust)
		estimates store pmt_amt_snf
	quietly xtreg pmt_after_snf_30_pac pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_pac
	quietly xtreg pmt_after_snf_30_sum_acute pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_acute
	quietly xtreg pmt_after_snf_30_all pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_all
	est table radm7snf radm14snf radm30snf suc_dschrg pmt_amt_snf pmt_snf_30_pac pmt_snf_30_acute pmt_snf_30_all, keep(pr_snflos) b se t p stats(N) title("2nd Stage")
	eststo clear
	
	restore 

/**********************************************************
 For-profit SNF
**********************************************************/	
	keep if for_profit_snf==1	

/******************
 SNF LOS <=14
******************/
 	preserve 
 	keep if pr_snflos_ffs <= 14 
 	
 	sum util_day_snf, d
 	sum radm7snf
 	sum radm14snf
 	sum radm30snf
 	sum successful_discharge
	sum pmt_amt_snf
 	sum pmt_after_snf_30_pac
 	sum pmt_after_snf_30_sum_acute
 	sum pmt_after_snf_30_all

 	
*2SLS regressions with county-year level %MA as IV
	
	*First stage
	quietly xtreg util_day_snf county_year_ma_pct $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store first_stage
		predict pr_snflos if e(sample)
		est table first_stage, keep(county_year_ma_pct) b se t p stats(N) title("1st Stage") 
		eststo clear
	
	*Summary of predicted SNF LOS
	sum pr_snflos, d
	
	*Second stage 
	quietly xtreg radm7snf pr_snflos $pt_covar2 ndays7_snf, i(snf_providernum) fe vce(robust)
		estimates store radm7snf
	quietly xtreg radm14snf pr_snflos $pt_covar2 ndays14_snf, i(snf_providernum) fe vce(robust)
		estimates store radm14snf
	quietly xtreg radm30snf pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store radm30snf
	quietly xtreg successful_discharge pr_snflos $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store suc_dschrg
	quietly xtreg pmt_amt_snf pr_snflos $pt_covar, i(snf_providernum) fe vce(robust)
		estimates store pmt_amt_snf
	quietly xtreg pmt_after_snf_30_pac pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_pac
	quietly xtreg pmt_after_snf_30_sum_acute pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_acute
	quietly xtreg pmt_after_snf_30_all pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_all
	est table radm7snf radm14snf radm30snf suc_dschrg pmt_amt_snf pmt_snf_30_pac pmt_snf_30_acute pmt_snf_30_all, keep(pr_snflos) b se t p stats(N) title("2nd Stage")
	eststo clear
	
	restore 

/******************
 SNF LOS (14, 20]
******************/
 	preserve 
 	keep if pr_snflos_ffs > 14 & pr_snflos_ffs <= 20
 	
 	sum util_day_snf, d
 	sum radm7snf
 	sum radm14snf
 	sum radm30snf
 	sum successful_discharge
	sum pmt_amt_snf
 	sum pmt_after_snf_30_pac
 	sum pmt_after_snf_30_sum_acute
 	sum pmt_after_snf_30_all

 	
*2SLS regressions with county-year level %MA as IV
	
	*First stage
	quietly xtreg util_day_snf county_year_ma_pct $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store first_stage
		predict pr_snflos if e(sample)
		est table first_stage, keep(county_year_ma_pct) b se t p stats(N) title("1st Stage") 
		eststo clear
	
	*Summary of predicted SNF LOS
	sum pr_snflos, d
	
	*Second stage 
	quietly xtreg radm7snf pr_snflos $pt_covar2 ndays7_snf, i(snf_providernum) fe vce(robust)
		estimates store radm7snf
	quietly xtreg radm14snf pr_snflos $pt_covar2 ndays14_snf, i(snf_providernum) fe vce(robust)
		estimates store radm14snf
	quietly xtreg radm30snf pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store radm30snf
	quietly xtreg successful_discharge pr_snflos $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store suc_dschrg
	quietly xtreg pmt_amt_snf pr_snflos $pt_covar, i(snf_providernum) fe vce(robust)
		estimates store pmt_amt_snf
	quietly xtreg pmt_after_snf_30_pac pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_pac
	quietly xtreg pmt_after_snf_30_sum_acute pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_acute
	quietly xtreg pmt_after_snf_30_all pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_all
	est table radm7snf radm14snf radm30snf suc_dschrg pmt_amt_snf pmt_snf_30_pac pmt_snf_30_acute pmt_snf_30_all, keep(pr_snflos) b se t p stats(N) title("2nd Stage")
	eststo clear
	
	restore 

/******************
 SNF LOS (20,30]
******************/
 	preserve 
 	keep if pr_snflos_ffs > 20 & pr_snflos_ffs <= 30
 	
 	sum util_day_snf, d
 	sum radm7snf
 	sum radm14snf
 	sum radm30snf
 	sum successful_discharge
	sum pmt_amt_snf
 	sum pmt_after_snf_30_pac
 	sum pmt_after_snf_30_sum_acute
 	sum pmt_after_snf_30_all

 	
*2SLS regressions with county-year level %MA as IV
	
	*First stage
	quietly xtreg util_day_snf county_year_ma_pct $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store first_stage
		predict pr_snflos if e(sample)
		est table first_stage, keep(county_year_ma_pct) b se t p stats(N) title("1st Stage") 
		eststo clear
	
	*Summary of predicted SNF LOS
	sum pr_snflos, d
	
	*Second stage 
	quietly xtreg radm7snf pr_snflos $pt_covar2 ndays7_snf, i(snf_providernum) fe vce(robust)
		estimates store radm7snf
	quietly xtreg radm14snf pr_snflos $pt_covar2 ndays14_snf, i(snf_providernum) fe vce(robust)
		estimates store radm14snf
	quietly xtreg radm30snf pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store radm30snf
	quietly xtreg successful_discharge pr_snflos $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store suc_dschrg
	quietly xtreg pmt_amt_snf pr_snflos $pt_covar, i(snf_providernum) fe vce(robust)
		estimates store pmt_amt_snf
	quietly xtreg pmt_after_snf_30_pac pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_pac
	quietly xtreg pmt_after_snf_30_sum_acute pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_acute
	quietly xtreg pmt_after_snf_30_all pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_all
	est table radm7snf radm14snf radm30snf suc_dschrg pmt_amt_snf pmt_snf_30_pac pmt_snf_30_acute pmt_snf_30_all, keep(pr_snflos) b se t p stats(N) title("2nd Stage")
	eststo clear
	
	restore 

/******************
 SNF LOS >30
******************/
 	preserve 
 	keep if pr_snflos_ffs > 30
 	
 	sum util_day_snf, d
 	sum radm7snf
 	sum radm14snf
 	sum radm30snf
 	sum successful_discharge
	sum pmt_amt_snf
 	sum pmt_after_snf_30_pac
 	sum pmt_after_snf_30_sum_acute
 	sum pmt_after_snf_30_all

 	
*2SLS regressions with county-year level %MA as IV
	
	*First stage
	quietly xtreg util_day_snf county_year_ma_pct $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store first_stage
		predict pr_snflos if e(sample)
		est table first_stage, keep(county_year_ma_pct) b se t p stats(N) title("1st Stage") 
		eststo clear
	
	*Summary of predicted SNF LOS
	sum pr_snflos, d
	
	*Second stage 
	quietly xtreg radm7snf pr_snflos $pt_covar2 ndays7_snf, i(snf_providernum) fe vce(robust)
		estimates store radm7snf
	quietly xtreg radm14snf pr_snflos $pt_covar2 ndays14_snf, i(snf_providernum) fe vce(robust)
		estimates store radm14snf
	quietly xtreg radm30snf pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store radm30snf
	quietly xtreg successful_discharge pr_snflos $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store suc_dschrg
	quietly xtreg pmt_amt_snf pr_snflos $pt_covar, i(snf_providernum) fe vce(robust)
		estimates store pmt_amt_snf
	quietly xtreg pmt_after_snf_30_pac pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_pac
	quietly xtreg pmt_after_snf_30_sum_acute pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_acute
	quietly xtreg pmt_after_snf_30_all pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_all
	est table radm7snf radm14snf radm30snf suc_dschrg pmt_amt_snf pmt_snf_30_pac pmt_snf_30_acute pmt_snf_30_all, keep(pr_snflos) b se t p stats(N) title("2nd Stage")
	eststo clear
	
	restore

	
/**********************************************************
 Not-for-profit SNF
**********************************************************/	
	keep if for_profit_snf==0

/******************
 SNF LOS <=14
******************/
 	preserve 
 	keep if pr_snflos_ffs <= 14 
 	
 	sum util_day_snf, d
 	sum radm7snf
 	sum radm14snf
 	sum radm30snf
 	sum successful_discharge
	sum pmt_amt_snf
 	sum pmt_after_snf_30_pac
 	sum pmt_after_snf_30_sum_acute
 	sum pmt_after_snf_30_all

 	
*2SLS regressions with county-year level %MA as IV
	
	*First stage
	quietly xtreg util_day_snf county_year_ma_pct $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store first_stage
		predict pr_snflos if e(sample)
		est table first_stage, keep(county_year_ma_pct) b se t p stats(N) title("1st Stage") 
		eststo clear
	
	*Summary of predicted SNF LOS
	sum pr_snflos, d
	
	*Second stage 
	quietly xtreg radm7snf pr_snflos $pt_covar2 ndays7_snf, i(snf_providernum) fe vce(robust)
		estimates store radm7snf
	quietly xtreg radm14snf pr_snflos $pt_covar2 ndays14_snf, i(snf_providernum) fe vce(robust)
		estimates store radm14snf
	quietly xtreg radm30snf pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store radm30snf
	quietly xtreg successful_discharge pr_snflos $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store suc_dschrg
	quietly xtreg pmt_amt_snf pr_snflos $pt_covar, i(snf_providernum) fe vce(robust)
		estimates store pmt_amt_snf
	quietly xtreg pmt_after_snf_30_pac pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_pac
	quietly xtreg pmt_after_snf_30_sum_acute pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_acute
	quietly xtreg pmt_after_snf_30_all pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_all
	est table radm7snf radm14snf radm30snf suc_dschrg pmt_amt_snf pmt_snf_30_pac pmt_snf_30_acute pmt_snf_30_all, keep(pr_snflos) b se t p stats(N) title("2nd Stage")
	eststo clear
	
	restore 

/******************
 SNF LOS (14, 20]
******************/
 	preserve 
 	keep if pr_snflos_ffs > 14 & pr_snflos_ffs <= 20
 	
 	sum util_day_snf, d
 	sum radm7snf
 	sum radm14snf
 	sum radm30snf
 	sum successful_discharge
	sum pmt_amt_snf
 	sum pmt_after_snf_30_pac
 	sum pmt_after_snf_30_sum_acute
 	sum pmt_after_snf_30_all

 	
*2SLS regressions with county-year level %MA as IV
	
	*First stage
	quietly xtreg util_day_snf county_year_ma_pct $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store first_stage
		predict pr_snflos if e(sample)
		est table first_stage, keep(county_year_ma_pct) b se t p stats(N) title("1st Stage") 
		eststo clear
	
	*Summary of predicted SNF LOS
	sum pr_snflos, d
	
	*Second stage 
	quietly xtreg radm7snf pr_snflos $pt_covar2 ndays7_snf, i(snf_providernum) fe vce(robust)
		estimates store radm7snf
	quietly xtreg radm14snf pr_snflos $pt_covar2 ndays14_snf, i(snf_providernum) fe vce(robust)
		estimates store radm14snf
	quietly xtreg radm30snf pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store radm30snf
	quietly xtreg successful_discharge pr_snflos $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store suc_dschrg
	quietly xtreg pmt_amt_snf pr_snflos $pt_covar, i(snf_providernum) fe vce(robust)
		estimates store pmt_amt_snf
	quietly xtreg pmt_after_snf_30_pac pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_pac
	quietly xtreg pmt_after_snf_30_sum_acute pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_acute
	quietly xtreg pmt_after_snf_30_all pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_all
	est table radm7snf radm14snf radm30snf suc_dschrg pmt_amt_snf pmt_snf_30_pac pmt_snf_30_acute pmt_snf_30_all, keep(pr_snflos) b se t p stats(N) title("2nd Stage")
	eststo clear
	
	restore 

/******************
 SNF LOS (20,30]
******************/
 	preserve 
 	keep if pr_snflos_ffs > 20 & pr_snflos_ffs <= 30
 	
 	sum util_day_snf, d
 	sum radm7snf
 	sum radm14snf
 	sum radm30snf
 	sum successful_discharge
	sum pmt_amt_snf
 	sum pmt_after_snf_30_pac
 	sum pmt_after_snf_30_sum_acute
 	sum pmt_after_snf_30_all

 	
*2SLS regressions with county-year level %MA as IV
	
	*First stage
	quietly xtreg util_day_snf county_year_ma_pct $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store first_stage
		predict pr_snflos if e(sample)
		est table first_stage, keep(county_year_ma_pct) b se t p stats(N) title("1st Stage") 
		eststo clear
	
	*Summary of predicted SNF LOS
	sum pr_snflos, d
	
	*Second stage 
	quietly xtreg radm7snf pr_snflos $pt_covar2 ndays7_snf, i(snf_providernum) fe vce(robust)
		estimates store radm7snf
	quietly xtreg radm14snf pr_snflos $pt_covar2 ndays14_snf, i(snf_providernum) fe vce(robust)
		estimates store radm14snf
	quietly xtreg radm30snf pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store radm30snf
	quietly xtreg successful_discharge pr_snflos $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store suc_dschrg
	quietly xtreg pmt_amt_snf pr_snflos $pt_covar, i(snf_providernum) fe vce(robust)
		estimates store pmt_amt_snf
	quietly xtreg pmt_after_snf_30_pac pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_pac
	quietly xtreg pmt_after_snf_30_sum_acute pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_acute
	quietly xtreg pmt_after_snf_30_all pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_all
	est table radm7snf radm14snf radm30snf suc_dschrg pmt_amt_snf pmt_snf_30_pac pmt_snf_30_acute pmt_snf_30_all, keep(pr_snflos) b se t p stats(N) title("2nd Stage")
	eststo clear
	
	restore 

/******************
 SNF LOS >30
******************/
 	preserve 
 	keep if pr_snflos_ffs > 30
 	
 	sum util_day_snf, d
 	sum radm7snf
 	sum radm14snf
 	sum radm30snf
 	sum successful_discharge
	sum pmt_amt_snf
 	sum pmt_after_snf_30_pac
 	sum pmt_after_snf_30_sum_acute
 	sum pmt_after_snf_30_all

 	
*2SLS regressions with county-year level %MA as IV
	
	*First stage
	quietly xtreg util_day_snf county_year_ma_pct $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store first_stage
		predict pr_snflos if e(sample)
		est table first_stage, keep(county_year_ma_pct) b se t p stats(N) title("1st Stage") 
		eststo clear
	
	*Summary of predicted SNF LOS
	sum pr_snflos, d
	
	*Second stage 
	quietly xtreg radm7snf pr_snflos $pt_covar2 ndays7_snf, i(snf_providernum) fe vce(robust)
		estimates store radm7snf
	quietly xtreg radm14snf pr_snflos $pt_covar2 ndays14_snf, i(snf_providernum) fe vce(robust)
		estimates store radm14snf
	quietly xtreg radm30snf pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store radm30snf
	quietly xtreg successful_discharge pr_snflos $pt_covar2, i(snf_providernum) fe vce(robust)
		estimates store suc_dschrg
	quietly xtreg pmt_amt_snf pr_snflos $pt_covar, i(snf_providernum) fe vce(robust)
		estimates store pmt_amt_snf
	quietly xtreg pmt_after_snf_30_pac pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_pac
	quietly xtreg pmt_after_snf_30_sum_acute pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_acute
	quietly xtreg pmt_after_snf_30_all pr_snflos $pt_covar2 ndays30_snf, i(snf_providernum) fe vce(robust)
		estimates store pmt_snf_30_all
	est table radm7snf radm14snf radm30snf suc_dschrg pmt_amt_snf pmt_snf_30_pac pmt_snf_30_acute pmt_snf_30_all, keep(pr_snflos) b se t p stats(N) title("2nd Stage")
	eststo clear
	
	restore
	