/**********************************************************************************************************************************************************
 Step 1: Create a long panel of index hospitalizations using MedPAR and Denominator data sets
**********************************************************************************************************************************************************/

*Read in data from 2010-2016 MedPAR data sets;
data MedPAR2010_16;
    set Medpar.Mp100mod_2010 Medpar.Mp100mod_2011 Medpar.Mp100mod_2012 Medpar.Mp100mod_2013 Medpar.Mp100mod_2014 Medpar.Mp100mod_2015 Medpar.Mp100mod_2016;
    if (substr(PRVDR_NUM,3,1) in ('0','M','R','S','T') or substr(PRVDR_NUM,3,2)='13') & SPCLUNIT not in ('M','R','S','T') then output;
    keep BENE_ID DSCHRGDT ADMSNDT DSCHRGCD DSTNTNCD MEDPAR_ID DRG_CD PMT_AMT PRVDR_NUM BENE_ZIP UTIL_DAY 
        DGNS_CD01 DGNS_CD02 DGNS_CD03 DGNS_CD04 DGNS_CD05 DGNS_CD06 DGNS_CD07 DGNS_CD08 DGNS_CD09 DGNS_CD10 DGNS_CD11 DGNS_CD12 DGNS_CD13 DGNS_CD14 
        DGNS_CD15 DGNS_CD16 DGNS_CD17 DGNS_CD18 DGNS_CD19 DGNS_CD20 DGNS_CD21 DGNS_CD22 DGNS_CD23 DGNS_CD24 DGNS_CD25  
        PRCDR_CD1-PRCDR_CD25 SRC_ADMS TYPE_ADM 
        DGNS_E_1_CD DGNS_E_2_CD DGNS_E_3_CD DGNS_E_4_CD DGNS_E_5_CD DGNS_E_6_CD DGNS_E_7_CD DGNS_E_8_CD DGNS_E_9_CD DGNS_E_10_CD DGNS_E_11_CD DGNS_E_12_CD;
run; *96,091,346; 

proc sql;
    create table MedPAR2010_16_2 as
    select * from MedPAR2010_16
    where DSCHRGCD eq 'A' & ADMSNDT ge 18263 & DSCHRGDT+90 le 20819;
quit; *89,402,405 records are admitted later than 01/01/2010 and discharged 90 days before 12/31/2016 (Updated);	

proc sort data=MedPAR2010_16_2; by BENE_ID ADMSNDT; run;

data MedPAR2010_16_3;
    set MedPAR2010_16_2;
    by BENE_ID ADMSNDT;
    if first.ADMSNDT;
run; *89,237,485;

*Read in data from 2010-2016 Denominator data sets;
data Denominator2010_16_data;
    set Denom.Dn100mod_2010 Denom.Dn100mod_2011 Denom.Dn100mod_2012 Denom.Dn100mod_2013 Denom.Dn100mod_2014 Denom.Dn100mod_2015 Denom.Dn100mod_2016;
    rename  BUYIN01=BUYIN1 BUYIN02=BUYIN2 BUYIN03=BUYIN3 BUYIN04=BUYIN4 BUYIN05=BUYIN5 BUYIN06=BUYIN6 BUYIN07=BUYIN7 BUYIN08=BUYIN8 BUYIN09=BUYIN9
            HMOIND01=HMOIND1 HMOIND02=HMOIND2 HMOIND03=HMOIND3 HMOIND04=HMOIND4 HMOIND05=HMOIND5 HMOIND06=HMOIND6 HMOIND07=HMOIND7 HMOIND08=HMOIND8 HMOIND09=HMOIND9;	         
    keep BENE_ID BENE_DOB DEATH_DT RFRNC_YR SEX RACE HMOIND: BUYIN: ;
run; *385,661,111;

data Dn100mod_2010; set Denominator2010_16_data; where RFRNC_YR=2010; rename DEATH_DT=DEATH_DT_10; run;
data Dn100mod_2011; set Denominator2010_16_data; where RFRNC_YR=2011; rename BUYIN1-BUYIN12=BUYIN13-BUYIN24; rename HMOIND1-HMOIND12=HMOIND13-HMOIND24; rename DEATH_DT=DEATH_DT_11; run;
data Dn100mod_2012; set Denominator2010_16_data; where RFRNC_YR=2012; rename BUYIN1-BUYIN12=BUYIN25-BUYIN36; rename HMOIND1-HMOIND12=HMOIND25-HMOIND36; rename DEATH_DT=DEATH_DT_12; run;
data Dn100mod_2013; set Denominator2010_16_data; where RFRNC_YR=2013; rename BUYIN1-BUYIN12=BUYIN37-BUYIN48; rename HMOIND1-HMOIND12=HMOIND37-HMOIND48; rename DEATH_DT=DEATH_DT_13; run;
data Dn100mod_2014; set Denominator2010_16_data; where RFRNC_YR=2014; rename BUYIN1-BUYIN12=BUYIN49-BUYIN60; rename HMOIND1-HMOIND12=HMOIND49-HMOIND60; rename DEATH_DT=DEATH_DT_14; run;
data Dn100mod_2015; set Denominator2010_16_data; where RFRNC_YR=2015; rename BUYIN1-BUYIN12=BUYIN61-BUYIN72; rename HMOIND1-HMOIND12=HMOIND61-HMOIND72; rename DEATH_DT=DEATH_DT_15; run;
data Dn100mod_2016; set Denominator2010_16_data; where RFRNC_YR=2016; rename BUYIN1-BUYIN12=BUYIN73-BUYIN84; rename HMOIND1-HMOIND12=HMOIND73-HMOIND84; rename DEATH_DT=DEATH_DT_16; run;

proc sort data=Dn100mod_2010; by BENE_ID; run;
proc sort data=Dn100mod_2011; by BENE_ID; run;
proc sort data=Dn100mod_2012; by BENE_ID; run;
proc sort data=Dn100mod_2013; by BENE_ID; run;
proc sort data=Dn100mod_2014; by BENE_ID; run;
proc sort data=Dn100mod_2015; by BENE_ID; run;
proc sort data=Dn100mod_2016; by BENE_ID; run;

data Denominator2010_16_data;
    merge Dn100mod_2010 Dn100mod_2011 Dn100mod_2012 Dn100mod_2013 Dn100mod_2014 Dn100mod_2015 Dn100mod_2016;
    by BENE_ID;
run; *72,872,500;

*Generate death date variable by combining death date information from each dataset;
data Denominator2010_16_data_2;
    set Denominator2010_16_data;
    DEATH_DT=DEATH_DT_10;
    if DEATH_DT_10 eq . & DEATH_DT_11 ne . then DEATH_DT=DEATH_DT_11;
    else if DEATH_DT_10 eq . & DEATH_DT_11 eq . & DEATH_DT_12 ne . then DEATH_DT=DEATH_DT_12;
    else if DEATH_DT_10 eq . & DEATH_DT_11 eq . & DEATH_DT_12 eq . & DEATH_DT_13 ne . then DEATH_DT=DEATH_DT_13;
    else if DEATH_DT_10 eq . & DEATH_DT_11 eq . & DEATH_DT_12 eq . & DEATH_DT_13 eq . & DEATH_DT_14 ne . then DEATH_DT=DEATH_DT_14;
    else if DEATH_DT_10 eq . & DEATH_DT_11 eq . & DEATH_DT_12 eq . & DEATH_DT_13 eq . & DEATH_DT_14 eq . & DEATH_DT_15 ne . then DEATH_DT=DEATH_DT_15;
    else if DEATH_DT_10 eq . & DEATH_DT_11 eq . & DEATH_DT_12 eq . & DEATH_DT_13 eq . & DEATH_DT_14 eq . & DEATH_DT_15 eq . & DEATH_DT_16 ne . then DEATH_DT=DEATH_DT_16;
run; *72,872,500;

*Merge MedPAR and Denominator data sets together;
proc sql;
    create table MedPAR2010_16_4 as
    select medpar.*, denom.* 
    from MedPAR2010_16_3 as medpar
    left join Denominator2010_16_data_2 as denom
    on medpar.BENE_ID=denom.BENE_ID;
quit; *89,237,485;

*Exclude records of beneficiaries less than 66 years old at admission;
data MedPAR2010_16_5;
    set MedPAR2010_16_4;
    age_adm=floor((intck('month',BENE_DOB,ADMSNDT)-(day(ADMSNDT)<day(BENE_DOB)))/12);
run; 

data MedPAR2010_16_6;
    set MedPAR2010_16_5;
    where age_adm ge 66;
run; *69,565,202;

*Limit records to those have part A and part B, not HMO from admission to post discharge;
data MedPAR2010_16_7;
    set MedPAR2010_16_6;
    array buyin{84} BUYIN1-BUYIN84;
    array hmoin{84} HMOIND1-HMOIND84;
    array enroll_indicator{84} enroll_1-enroll_84;
    array elig_period{84} elig_period_1-elig_period_84;
    array elig_indicator{84} elig_indicator_1-elig_indicator_84;
    array MA_indicator(84) MA_indicator_1-MA_indicator_84;
    array MA_elig_indicator(84) MA_elig_indicator_1-MA_elig_indicator_84;
    array FFS_indicator(84) FFS_indicator_1-FFS_indicator_84;
    array FFS_elig_indicator(84) FFS_elig_indicator_1-FFS_elig_indicator_84;
    if DEATH_DT ne . & DEATH_DT ge DSCHRGDT then post_dischdt=min(DSCHRGDT+90,DEATH_DT); else post_dischdt=DSCHRGDT+90;
    do i=1 to 84;
        *Eligible for Part A & B coverage;
        if buyin(i) in ('3','C') then enroll_indicator(i)=1; else enroll_indicator(i)=0;
        if (year(ADMSNDT)-2010)*12+month(ADMSNDT) le i le (year(post_dischdt)-2010)*12+month(post_dischdt) then elig_period(i)=1; 
        else elig_period(i)=0; 
        elig_indicator(i)=enroll_indicator(i)*elig_period(i);
        *Eligible for Part A & B - enrolled in MA;
        if buyin(i) in ('3','C') & hmoin(i) not in (' ','0','4') then MA_indicator(i)=1; else MA_indicator(i)=0;
        MA_elig_indicator(i)=MA_indicator(i)*elig_period(i);
        *Eligible for Part A & B - enrolled in FFS;
        if buyin(i) in ('3','C') & hmoin(i) in (' ','0','4') then FFS_indicator(i)=1; else FFS_indicator(i)=0;
        FFS_elig_indicator(i)=FFS_indicator(i)*elig_period(i);
    end; 
    drop i;
    elig_sum=sum(of elig_indicator_1-elig_indicator_84);
    MA_elig_sum=sum(of MA_elig_indicator_1-MA_elig_indicator_84);
    FFS_elig_sum=sum(of FFS_elig_indicator_1-FFS_elig_indicator_84);

    *Continuously eligible for Part A & B;
    if elig_sum eq (year(post_dischdt)-year(ADMSNDT))*12+month(post_dischdt)-month(ADMSNDT)+1 then enrollment_elig=1; else enrollment_elig=0;

    *Continuously eligible for Part A & B - continuously enrolled in MA;
    if MA_elig_sum eq (year(post_dischdt)-year(ADMSNDT))*12+month(post_dischdt)-month(ADMSNDT)+1 then MA_enrollment_elig=1; else MA_enrollment_elig=0;

    *Continuously eligible for Part A & B - continuously enrolled in FFS;
    if FFS_elig_sum eq (year(post_dischdt)-year(ADMSNDT))*12+month(post_dischdt)-month(ADMSNDT)+1 then FFS_enrollment_elig=1; else FFS_enrollment_elig=0;

    label MA_enrollment_elig="Continuous Enrollment in Medicare Advantage" 
        FFS_enrollment_elig="Continuous Enrollment in Fee-for-Service";
run; *69,565,202;

data MedPAR2010_16_8;
    set MedPAR2010_16_7;
    where enrollment_elig=1 & (FFS_enrollment_elig=1 | MA_enrollment_elig=1);
run; *67,477,764;

data snf.prior_hosp_2010_2016(rename=(util_day=Hosp_Days_All));
    set MedPAR2010_16_8;
    * Mortality;
    if DSCHRGDT le DEATH_DT le DSCHRGDT+30 then DeathIn30Days=1; else DeathIn30Days=0;
    * Create discharge year and month variable;
    dschrg_year=year(dschrgdt);
    dschrg_month=month(dschrgdt);
    *Recode string variables to numeric;
    if sex="1" then sex_num=1;
    else if sex="2" then sex_num=2;
    else if sex="0" then sex_num=3;
    if race="0" then race_num=7;
    else if race="1" then race_num=1;
    else if race="2" then race_num=2; 
    else if race="3" then race_num=3;
    else if race="4" then race_num=4;
    else if race="5" then race_num=5;
    else if race="6" then race_num=6;
    keep BENE_ID ADMSNDT DSCHRGDT RACE SEX BENE_DOB DEATH_DT age_adm DRG_CD DSTNTNCD MEDPAR_ID DeathIn30Days 
        PMT_AMT PRVDR_NUM BENE_ZIP UTIL_DAY 
        DGNS_CD01 DGNS_CD02 DGNS_CD03 DGNS_CD04 DGNS_CD05 DGNS_CD06 DGNS_CD07 DGNS_CD08 DGNS_CD09 DGNS_CD10 
        DGNS_CD11 DGNS_CD12 DGNS_CD13 DGNS_CD14 DGNS_CD15 DGNS_CD16 DGNS_CD17 DGNS_CD18 DGNS_CD19 DGNS_CD20 DGNS_CD21 DGNS_CD22 DGNS_CD23 DGNS_CD24 DGNS_CD25  
        dschrg_year dschrg_month sex_num race_num FFS_enrollment_elig MA_enrollment_elig;
    format DeathIn30Days ynf.;																							
    label dschrg_year="Discharge Year" dschrg_month="Discharge Month";
run; *67,477,764;



/**********************************************************************************************************************************************************
 Step 2: Create a long panel of SNF stays for Medicare Fee-for-Service beneficiaries using MedPAR data sets 
**********************************************************************************************************************************************************/

*Read in SNF stay data from 2010-2016 MedPAR data sets;
data SNF2010_16(rename=(DSCHRGDT_pseudo=DSCHRGDT));
    set Medpar.Mp100mod_2010(keep=BENE_ID DSCHRGDT ADMSNDT DSCHRGCD MEDPAR_ID PMT_AMT PRVDR_NUM UTIL_DAY Coin_day coin_amt)
        Medpar.Mp100mod_2011(keep=BENE_ID DSCHRGDT ADMSNDT DSCHRGCD MEDPAR_ID PMT_AMT PRVDR_NUM UTIL_DAY Coin_day coin_amt) 
        Medpar.Mp100mod_2012(keep=BENE_ID DSCHRGDT ADMSNDT DSCHRGCD MEDPAR_ID PMT_AMT PRVDR_NUM UTIL_DAY Coin_day coin_amt) 
        Medpar.Mp100mod_2013(keep=BENE_ID DSCHRGDT ADMSNDT DSCHRGCD MEDPAR_ID PMT_AMT PRVDR_NUM UTIL_DAY Coin_day coin_amt) 
        Medpar.Mp100mod_2014(keep=BENE_ID DSCHRGDT ADMSNDT DSCHRGCD MEDPAR_ID PMT_AMT PRVDR_NUM UTIL_DAY Coin_day coin_amt) 
        Medpar.Mp100mod_2015(keep=BENE_ID DSCHRGDT ADMSNDT DSCHRGCD MEDPAR_ID PMT_AMT PRVDR_NUM UTIL_DAY Coin_day coin_amt) 
        Medpar.Mp100mod_2016(keep=BENE_ID DSCHRGDT ADMSNDT DSCHRGCD MEDPAR_ID PMT_AMT PRVDR_NUM UTIL_DAY Coin_day coin_amt);
    where substr(PRVDR_NUM,3,1) in ('5','6');
    DSCHRGDT_pseudo=DSCHRGDT;
    if DSCHRGDT eq . then DSCHRGDT_pseudo=ADMSNDT+UTIL_DAY;
    label DSCHRGDT_pseudo="SNF Discharge Date";
    drop DSCHRGDT;
run; *18,368,283;

proc sql;
    create table SNF2010_16_2 as
    select * from SNF2010_16
    where ADMSNDT-30 ge 18263 & DSCHRGDT+90 le 20819;
quit; *17,303,341 records are admitted at least 30 days after 01/01/2010 and discharged 90 days before 12/31/2016 (Updated);	

proc sort data=SNF2010_16_2; by bene_id ADMSNDT;

data SNF2010_16_3;
    set SNF2010_16_2;
    by bene_id ADMSNDT;
    if first.ADMSNDT;
run; *17,301,027;

*Read data from Denominator data 2010-2016;
data Denominator2010_16_data;
    set Denom.Dn100mod_2010 Denom.Dn100mod_2011 Denom.Dn100mod_2012 Denom.Dn100mod_2013 Denom.Dn100mod_2014 Denom.Dn100mod_2015 Denom.Dn100mod_2016;
    rename  BUYIN01=BUYIN1 BUYIN02=BUYIN2 BUYIN03=BUYIN3 BUYIN04=BUYIN4 BUYIN05=BUYIN5 BUYIN06=BUYIN6 BUYIN07=BUYIN7 BUYIN08=BUYIN8 BUYIN09=BUYIN9
            HMOIND01=HMOIND1 HMOIND02=HMOIND2 HMOIND03=HMOIND3 HMOIND04=HMOIND4 HMOIND05=HMOIND5 HMOIND06=HMOIND6 HMOIND07=HMOIND7 HMOIND08=HMOIND8 HMOIND09=HMOIND9;	         
    keep BENE_ID BENE_DOB DEATH_DT RFRNC_YR SEX RACE HMOIND: BUYIN: ;
run; *385,661,111;

data Dn100mod_2010; set Denominator2010_16_data; where RFRNC_YR=2010; rename DEATH_DT=DEATH_DT_10; run;
data Dn100mod_2011; set Denominator2010_16_data; where RFRNC_YR=2011; rename BUYIN1-BUYIN12=BUYIN13-BUYIN24; rename HMOIND1-HMOIND12=HMOIND13-HMOIND24; rename DEATH_DT=DEATH_DT_11; run;
data Dn100mod_2012; set Denominator2010_16_data; where RFRNC_YR=2012; rename BUYIN1-BUYIN12=BUYIN25-BUYIN36; rename HMOIND1-HMOIND12=HMOIND25-HMOIND36; rename DEATH_DT=DEATH_DT_12; run;
data Dn100mod_2013; set Denominator2010_16_data; where RFRNC_YR=2013; rename BUYIN1-BUYIN12=BUYIN37-BUYIN48; rename HMOIND1-HMOIND12=HMOIND37-HMOIND48; rename DEATH_DT=DEATH_DT_13; run;
data Dn100mod_2014; set Denominator2010_16_data; where RFRNC_YR=2014; rename BUYIN1-BUYIN12=BUYIN49-BUYIN60; rename HMOIND1-HMOIND12=HMOIND49-HMOIND60; rename DEATH_DT=DEATH_DT_14; run;
data Dn100mod_2015; set Denominator2010_16_data; where RFRNC_YR=2015; rename BUYIN1-BUYIN12=BUYIN61-BUYIN72; rename HMOIND1-HMOIND12=HMOIND61-HMOIND72; rename DEATH_DT=DEATH_DT_15; run;
data Dn100mod_2016; set Denominator2010_16_data; where RFRNC_YR=2016; rename BUYIN1-BUYIN12=BUYIN73-BUYIN84; rename HMOIND1-HMOIND12=HMOIND73-HMOIND84; rename DEATH_DT=DEATH_DT_16; run;

proc sort data=Dn100mod_2010; by BENE_ID; run;
proc sort data=Dn100mod_2011; by BENE_ID; run;
proc sort data=Dn100mod_2012; by BENE_ID; run;
proc sort data=Dn100mod_2013; by BENE_ID; run;
proc sort data=Dn100mod_2014; by BENE_ID; run;
proc sort data=Dn100mod_2015; by BENE_ID; run;
proc sort data=Dn100mod_2016; by BENE_ID; run;

data Denominator2010_16_data;
    merge Dn100mod_2010 Dn100mod_2011 Dn100mod_2012 Dn100mod_2013 Dn100mod_2014 Dn100mod_2015 Dn100mod_2016;
    by BENE_ID;
run; *72,872,500;

*Generate death date variable by combining death date information from each dataset;
data Denominator2010_16_data_2;
    set Denominator2010_16_data;
    DEATH_DT=DEATH_DT_10;
    if DEATH_DT_10 eq . & DEATH_DT_11 ne . then DEATH_DT=DEATH_DT_11;
    else if DEATH_DT_10 eq . & DEATH_DT_11 eq . & DEATH_DT_12 ne . then DEATH_DT=DEATH_DT_12;
    else if DEATH_DT_10 eq . & DEATH_DT_11 eq . & DEATH_DT_12 eq . & DEATH_DT_13 ne . then DEATH_DT=DEATH_DT_13;
    else if DEATH_DT_10 eq . & DEATH_DT_11 eq . & DEATH_DT_12 eq . & DEATH_DT_13 eq . & DEATH_DT_14 ne . then DEATH_DT=DEATH_DT_14;
    else if DEATH_DT_10 eq . & DEATH_DT_11 eq . & DEATH_DT_12 eq . & DEATH_DT_13 eq . & DEATH_DT_14 eq . & DEATH_DT_15 ne . then DEATH_DT=DEATH_DT_15;
    else if DEATH_DT_10 eq . & DEATH_DT_11 eq . & DEATH_DT_12 eq . & DEATH_DT_13 eq . & DEATH_DT_14 eq . & DEATH_DT_15 eq . & DEATH_DT_16 ne . then DEATH_DT=DEATH_DT_16;
run; *72,872,500;

*Merge SNF and Denominator data sets together;
proc sql;
    create table SNF2010_16_4 as
    select snf.*, denom.* 
    from SNF2010_16_3 as snf
    left join Denominator2010_16_data_2 as denom
    on snf.BENE_ID=denom.BENE_ID;
quit; *17,301,027; 

*Exclude records of beneficiaries less than 66 years old at admission date;
data SNF2010_16_5;
    set SNF2010_16_4;
    age_adm=floor((intck('month',BENE_DOB,ADMSNDT)-(day(ADMSNDT)<day(BENE_DOB)))/12);
run; 

data SNF2010_16_6;
    set SNF2010_16_5;
    where age_adm ge 66;
run; *15,269,790;

*Only include those have part A and part B, not HMO from admission to post discharge;
data SNF2010_16_7;
    set SNF2010_16_6;
    array buyin{84} BUYIN1-BUYIN84;
    array hmoin{84} HMOIND1-HMOIND84;
    array enroll_indicator{84} enroll_1-enroll_84;
    array elig_period{84} elig_period_1-elig_period_84;
    array elig_indicator{84} elig_indicator_1-elig_indicator_84;
    array MA_indicator(84) MA_indicator_1-MA_indicator_84;
    array MA_elig_indicator(84) MA_elig_indicator_1-MA_elig_indicator_84;
    array FFS_indicator(84) FFS_indicator_1-FFS_indicator_84;
    array FFS_elig_indicator(84) FFS_elig_indicator_1-FFS_elig_indicator_84;
    if DEATH_DT ne . & DEATH_DT ge DSCHRGDT then post_dischdt=min(DSCHRGDT+90,DEATH_DT); else post_dischdt=DSCHRGDT+90;
    do i=1 to 84;
        *Eligible for Part A & B coverage;
        if buyin(i) in ('3','C') then enroll_indicator(i)=1; else enroll_indicator(i)=0;
        if (year(ADMSNDT)-2010)*12+month(ADMSNDT) le i le (year(post_dischdt)-2010)*12+month(post_dischdt) then elig_period(i)=1; 
        else elig_period(i)=0; 
        elig_indicator(i)=enroll_indicator(i)*elig_period(i);
        *Eligible for Part A & B - enrolled in MA;
        if buyin(i) in ('3','C') & hmoin(i) not in (' ','0','4') then MA_indicator(i)=1; else MA_indicator(i)=0;
        MA_elig_indicator(i)=MA_indicator(i)*elig_period(i);
        *Eligible for Part A & B - enrolled in FFS;
        if buyin(i) in ('3','C') & hmoin(i) in (' ','0','4') then FFS_indicator(i)=1; else FFS_indicator(i)=0;
        FFS_elig_indicator(i)=FFS_indicator(i)*elig_period(i);
    end; 
    drop i;
    elig_sum=sum(of elig_indicator_1-elig_indicator_84);
    MA_elig_sum=sum(of MA_elig_indicator_1-MA_elig_indicator_84);
    FFS_elig_sum=sum(of FFS_elig_indicator_1-FFS_elig_indicator_84);

    *Continuously eligible for Part A & B;
    if elig_sum eq (year(post_dischdt)-year(ADMSNDT))*12+month(post_dischdt)-month(ADMSNDT)+1 then enrollment_elig=1; else enrollment_elig=0;

    *Continuously eligible for Part A & B - continuously enrolled in MA;
    if MA_elig_sum eq (year(post_dischdt)-year(ADMSNDT))*12+month(post_dischdt)-month(ADMSNDT)+1 then MA_enrollment_elig=1; else MA_enrollment_elig=0;

    *Continuously eligible for Part A & B - continuously enrolled in FFS;
    if FFS_elig_sum eq (year(post_dischdt)-year(ADMSNDT))*12+month(post_dischdt)-month(ADMSNDT)+1 then FFS_enrollment_elig=1; else FFS_enrollment_elig=0;

    label MA_enrollment_elig="Continuous Enrollment in Medicare Advantage" 
        FFS_enrollment_elig="Continuous Enrollment in Fee-for-Service";
run; *15,269,790;

data SNF2010_16_8;
    set SNF2010_16_7;
    where enrollment_elig=1 & FFS_enrollment_elig=1;
    dschrg_year=year(dschrgdt);
run; *13,581,243;

proc freq data=SNF2010_16_8;
    table dschrg_year * MA_enrollment_elig;
run;

*Merge in ssa county code for SNF from POS file;
%macro pos(m,n);
    %do i=&m %to &n;
        data pos_&i; 
        set pos.pos&i._orig(keep=prvdr_num state_cd ssa_state_cd ssa_cnty_cd); 
        year=&i; 
        snf_county_ssa_code= ssa_state_cd || ssa_cnty_cd;
        label snf_county_ssa_code="SSA County Code of SNF";
        run;
    %end;
    %mend;
%pos(2010,2016);

data pos_2010_2016;
    set pos_2010 pos_2011 pos_2012 pos_2013 pos_2014 pos_2015 pos_2016;
run; *959,246;

proc sql;
    create table SNF2010_16_9 as 
    select a.*, b.snf_county_ssa_code, b.ssa_state_cd as snf_state_ssa_code, b.state_cd as snf_state_abbrv
    from SNF2010_16_8 as a 
    left join pos_2010_2016 as b
    on a.prvdr_num=b.prvdr_num and a.dschrg_year=b.year;
quit; *13,581,243;

proc sql; create table check_merge as select bene_id from SNF2010_16_9 where snf_county_ssa_code=""; quit; *3,129;
proc sql; create table check_merge as select bene_id from snf.snf_stay_2010_2016 where snf_state_ssa_code=""; quit; *3,244;

data snf.snf_stay_2010_2016(rename=(medpar_id=medpar_id_snf admsndt=admsndt_snf dschrgdt=dschrgdt_snf util_day=util_day_snf prvdr_num=prvdrnum_snf pmt_amt=pmt_amt_snf DSCHRGCD=DSCHRGCD_snf));
    set SNF2010_16_9(keep=bene_id medpar_id admsndt dschrgdt util_day prvdr_num pmt_amt DSCHRGCD Coin_day coin_amt snf_county_ssa_code snf_state_ssa_code);
    if pmt_amt<0 then pmt_amt=0;
    format dschrgdt date9.;
run; *13,581,243;



/**********************************************************************************************************************************************************
 Step 3: Create a long panel of SNF stays for Medicare Advantage beneficiaries using Minimum Data Sets 
**********************************************************************************************************************************************************/

*Check if there is any missing beneficiary ID, MDS entry date, and MDS discharge date;
proc sql; create table check_all as select * from tempn.mds_2010_16_admsn_dschrg; quit; *33,576,213;
proc sql; create table check_all as select * from tempn.mds_2010_16_admsn_dschrg where bene_id=""; quit; *0;
proc sql; create table check_all as select * from tempn.mds_2010_16_admsn_dschrg where MDS_ENTRY_DT=.; quit; *0;
proc sql; create table check_all as select * from tempn.mds_2010_16_admsn_dschrg where MDS_DSCHRG_DT=.; quit; *2,399,376 (7.1%);

proc sql;
    create table mds_2010_2016 as
    select * 
    from tempn.mds_2010_16_admsn_dschrg
    where MDS_ENTRY_DT-30 ge 18263 & MDS_DSCHRG_DT+90 le 20819 & MDS_DSCHRG_DT^=.;
quit; *28,558,541 records are admitted at least 30 days after 01/01/2010 and discharged 90 days before 12/31/2016 (Updated);	

proc sort data=mds_2010_2016; by bene_id MDS_ENTRY_DT;

data mds_2010_2016_2;
    set mds_2010_2016;
    by bene_id MDS_ENTRY_DT;
    if first.MDS_ENTRY_DT;
run; *28,096,814;

*Read in data from 2010-2016 Denominator data sets;
data Denominator2010_16_data;
    set Denom.Dn100mod_2010 Denom.Dn100mod_2011 Denom.Dn100mod_2012 Denom.Dn100mod_2013 Denom.Dn100mod_2014 Denom.Dn100mod_2015 Denom.Dn100mod_2016;
    rename  BUYIN01=BUYIN1 BUYIN02=BUYIN2 BUYIN03=BUYIN3 BUYIN04=BUYIN4 BUYIN05=BUYIN5 BUYIN06=BUYIN6 BUYIN07=BUYIN7 BUYIN08=BUYIN8 BUYIN09=BUYIN9
            HMOIND01=HMOIND1 HMOIND02=HMOIND2 HMOIND03=HMOIND3 HMOIND04=HMOIND4 HMOIND05=HMOIND5 HMOIND06=HMOIND6 HMOIND07=HMOIND7 HMOIND08=HMOIND8 HMOIND09=HMOIND9;	         
    keep BENE_ID BENE_DOB DEATH_DT RFRNC_YR SEX RACE HMOIND: BUYIN: ;
run; *385,661,111;

data Dn100mod_2010; set Denominator2010_16_data; where RFRNC_YR=2010; rename DEATH_DT=DEATH_DT_10; run;
data Dn100mod_2011; set Denominator2010_16_data; where RFRNC_YR=2011; rename BUYIN1-BUYIN12=BUYIN13-BUYIN24; rename HMOIND1-HMOIND12=HMOIND13-HMOIND24; rename DEATH_DT=DEATH_DT_11; run;
data Dn100mod_2012; set Denominator2010_16_data; where RFRNC_YR=2012; rename BUYIN1-BUYIN12=BUYIN25-BUYIN36; rename HMOIND1-HMOIND12=HMOIND25-HMOIND36; rename DEATH_DT=DEATH_DT_12; run;
data Dn100mod_2013; set Denominator2010_16_data; where RFRNC_YR=2013; rename BUYIN1-BUYIN12=BUYIN37-BUYIN48; rename HMOIND1-HMOIND12=HMOIND37-HMOIND48; rename DEATH_DT=DEATH_DT_13; run;
data Dn100mod_2014; set Denominator2010_16_data; where RFRNC_YR=2014; rename BUYIN1-BUYIN12=BUYIN49-BUYIN60; rename HMOIND1-HMOIND12=HMOIND49-HMOIND60; rename DEATH_DT=DEATH_DT_14; run;
data Dn100mod_2015; set Denominator2010_16_data; where RFRNC_YR=2015; rename BUYIN1-BUYIN12=BUYIN61-BUYIN72; rename HMOIND1-HMOIND12=HMOIND61-HMOIND72; rename DEATH_DT=DEATH_DT_15; run;
data Dn100mod_2016; set Denominator2010_16_data; where RFRNC_YR=2016; rename BUYIN1-BUYIN12=BUYIN73-BUYIN84; rename HMOIND1-HMOIND12=HMOIND73-HMOIND84; rename DEATH_DT=DEATH_DT_16; run;

proc sort data=Dn100mod_2010; by BENE_ID; run;
proc sort data=Dn100mod_2011; by BENE_ID; run;
proc sort data=Dn100mod_2012; by BENE_ID; run;
proc sort data=Dn100mod_2013; by BENE_ID; run;
proc sort data=Dn100mod_2014; by BENE_ID; run;
proc sort data=Dn100mod_2015; by BENE_ID; run;
proc sort data=Dn100mod_2016; by BENE_ID; run;

data Denominator2010_16_data;
    merge Dn100mod_2010 Dn100mod_2011 Dn100mod_2012 Dn100mod_2013 Dn100mod_2014 Dn100mod_2015 Dn100mod_2016;
    by BENE_ID;
run; *72,872,500;

*Generate death date variable by combining death date information from each dataset;
data Denominator2010_16_data_2;
    set Denominator2010_16_data;
    DEATH_DT=DEATH_DT_10;
    if DEATH_DT_10 eq . & DEATH_DT_11 ne . then DEATH_DT=DEATH_DT_11;
    else if DEATH_DT_10 eq . & DEATH_DT_11 eq . & DEATH_DT_12 ne . then DEATH_DT=DEATH_DT_12;
    else if DEATH_DT_10 eq . & DEATH_DT_11 eq . & DEATH_DT_12 eq . & DEATH_DT_13 ne . then DEATH_DT=DEATH_DT_13;
    else if DEATH_DT_10 eq . & DEATH_DT_11 eq . & DEATH_DT_12 eq . & DEATH_DT_13 eq . & DEATH_DT_14 ne . then DEATH_DT=DEATH_DT_14;
    else if DEATH_DT_10 eq . & DEATH_DT_11 eq . & DEATH_DT_12 eq . & DEATH_DT_13 eq . & DEATH_DT_14 eq . & DEATH_DT_15 ne . then DEATH_DT=DEATH_DT_15;
    else if DEATH_DT_10 eq . & DEATH_DT_11 eq . & DEATH_DT_12 eq . & DEATH_DT_13 eq . & DEATH_DT_14 eq . & DEATH_DT_15 eq . & DEATH_DT_16 ne . then DEATH_DT=DEATH_DT_16;
run; *72,872,500;

*Merge MDS and Denominator data sets together;
proc sql;
    create table mds_2010_2016_3 as
    select mds.*, denom.* 
    from mds_2010_2016_2 as mds
    left join Denominator2010_16_data_2 as denom
    on mds.BENE_ID=denom.BENE_ID;
quit; *28,096,814; 

*Exclude records of beneficiaries less than 66 years old at admission date;
data mds_2010_2016_4;
    set mds_2010_2016_3;
    age_adm=floor((intck('month',BENE_DOB,MDS_ENTRY_DT)-(day(MDS_ENTRY_DT)<day(BENE_DOB)))/12);
run; 

data mds_2010_2016_5;
    set mds_2010_2016_4;
    where age_adm ge 66;
run; *23,009,179;

*Only include those have part A and part B from admission to post discharge;
data mds_2010_2016_6;
    set mds_2010_2016_5;
    array buyin{84} BUYIN1-BUYIN84;
    array hmoin{84} HMOIND1-HMOIND84;
    array enroll_indicator{84} enroll_1-enroll_84;
    array elig_period{84} elig_period_1-elig_period_84;
    array elig_indicator{84} elig_indicator_1-elig_indicator_84;
    array MA_indicator(84) MA_indicator_1-MA_indicator_84;
    array MA_elig_indicator(84) MA_elig_indicator_1-MA_elig_indicator_84;
    array FFS_indicator(84) FFS_indicator_1-FFS_indicator_84;
    array FFS_elig_indicator(84) FFS_elig_indicator_1-FFS_elig_indicator_84;
    if DEATH_DT ne . & DEATH_DT ge MDS_DSCHRG_DT then post_dischdt=min(MDS_DSCHRG_DT+90,DEATH_DT); else post_dischdt=MDS_DSCHRG_DT+90;
    do i=1 to 84;
        *Eligible for Part A & B coverage;
        if buyin(i) in ('3','C') then enroll_indicator(i)=1; else enroll_indicator(i)=0;
        if (year(MDS_ENTRY_DT)-2010)*12+month(MDS_ENTRY_DT) le i le (year(post_dischdt)-2010)*12+month(post_dischdt) then elig_period(i)=1; 
        else elig_period(i)=0; 
        elig_indicator(i)=enroll_indicator(i)*elig_period(i);
        *Eligible for Part A & B - enrolled in MA;
        if buyin(i) in ('3','C') & hmoin(i) not in (' ','0','4') then MA_indicator(i)=1; else MA_indicator(i)=0;
        MA_elig_indicator(i)=MA_indicator(i)*elig_period(i);
        *Eligible for Part A & B - enrolled in FFS;
        if buyin(i) in ('3','C') & hmoin(i) in (' ','0','4') then FFS_indicator(i)=1; else FFS_indicator(i)=0;
        FFS_elig_indicator(i)=FFS_indicator(i)*elig_period(i);
    end; 
    drop i;
    elig_sum=sum(of elig_indicator_1-elig_indicator_84);
    MA_elig_sum=sum(of MA_elig_indicator_1-MA_elig_indicator_84);
    FFS_elig_sum=sum(of FFS_elig_indicator_1-FFS_elig_indicator_84);

    *Continuously eligible for Part A & B;
    if elig_sum eq (year(post_dischdt)-year(MDS_ENTRY_DT))*12+month(post_dischdt)-month(MDS_ENTRY_DT)+1 then enrollment_elig=1; else enrollment_elig=0;

    *Continuously eligible for Part A & B - continuously enrolled in MA;
    if MA_elig_sum eq (year(post_dischdt)-year(MDS_ENTRY_DT))*12+month(post_dischdt)-month(MDS_ENTRY_DT)+1 then MA_enrollment_elig=1; else MA_enrollment_elig=0;

    *Continuously eligible for Part A & B - continuously enrolled in FFS;
    if FFS_elig_sum eq (year(post_dischdt)-year(MDS_ENTRY_DT))*12+month(post_dischdt)-month(MDS_ENTRY_DT)+1 then FFS_enrollment_elig=1; else FFS_enrollment_elig=0;

    label MA_enrollment_elig="Continuous Enrollment in Medicare Advantage" 
        FFS_enrollment_elig="Continuous Enrollment in Fee-for-Service";
run; *23,009,179;

data mds_2010_2016_7;
    set mds_2010_2016_6;
    where enrollment_elig=1 & (FFS_enrollment_elig=1 | MA_enrollment_elig=1);
    dschrg_year=year(MDS_DSCHRG_DT);
run; *21,742,674;

proc freq data=mds_2010_2016_7;
    table dschrg_year * MA_enrollment_elig;
run;

*Merge in ssa county code for SNF from POS file;
%macro pos(m,n);
    %do i=&m %to &n;
        data pos_&i; 
        set pos.pos&i._orig(keep=prvdr_num state_cd ssa_state_cd ssa_cnty_cd); 
        year=&i; 
        snf_county_ssa_code= ssa_state_cd || ssa_cnty_cd;
        label snf_county_ssa_code="SSA County Code of SNF";
        run;
    %end;
%mend;
%pos(2010,2016);

data pos_2010_2016;
    set pos_2010 pos_2011 pos_2012 pos_2013 pos_2014 pos_2015 pos_2016;
run; *959,246;

proc sql;
    create table mds_2010_2016_8 as 
    select a.*, b.snf_county_ssa_code, b.ssa_state_cd as snf_state_ssa_code, b.state_cd as snf_state_abbrv
    from mds_2010_2016_7 as a 
    left join pos_2010_2016 as b
    on a.PRVDR_NUM_FAC=b.prvdr_num and a.dschrg_year=b.year;
quit; *21,742,674;

proc sql; create table check_merge as select bene_id from mds_2010_2016_8 where snf_county_ssa_code=""; quit; *22,956 (0.1%);
proc sql; create table check_merge as select bene_id from mds_2010_2016_8 where snf_state_ssa_code=""; quit; *22,956 (0.1%);

data snf.snf_stay_2010_2016_mds;
    set mds_2010_2016_8(keep=bene_id MDS_ENTRY_DT MDS_DSCHRG_DT dschrg_year PRVDR_NUM_FAC snf_county_ssa_code snf_state_ssa_code);
    util_day_mds=MDS_DSCHRG_DT-MDS_ENTRY_DT;
    label util_day_mds="SNF Length of Stay (MDS)";
run; *21,742,674;



/**********************************************************************************************************************************************************
 Step 4: Calculate county-month level MA enrollment using MBSF %MA=(HMO not equals "", "0", "4")/ (BUYIN not equals "0") 
**********************************************************************************************************************************************************/

%macro county_month_ma_pct(start_yr,end_yr); 
    %do i=&start_yr %to &end_yr;

        data Dn100mod_&i(keep=bene_id enroll_part_a_1-enroll_part_a_12 enroll_ma_1-enroll_ma_12 RFRNC_YR county_ssa_code);
            set Denom.Dn100mod_&i(keep=bene_id BUYIN01-BUYIN12 HMOIND01-HMOIND12 RFRNC_YR state_cd cnty_cd);
            array buyin{12} BUYIN01-BUYIN12;
            array hmoin{12} HMOIND01-HMOIND12;
            array enroll_part_a{12} enroll_part_a_1-enroll_part_a_12;
            array enroll_ma(12) enroll_ma_1-enroll_ma_12;

            where state_cd in ("01","03","04","05","06","07","08","09","10","11","13","14",
                            "15","16","17","18","19","20","21","22","23","24","25","26",
                            "27","28","29","30","31","32","33","34","35","36","37","38",
                            "39","41","42","43","44","45","46","47","49","50","51","52","53");

            do i=1 to 12;
                *Eligible for Medicare coverage;
                if buyin(i) not in ('0'," ") | hmoin(i) not in ('0'," ") then enroll_part_a(i)=1; else enroll_part_a(i)=0;
                *Eligible for Medicare coverage and enrolled in MA;
                if hmoin(i) not in (" ",'0','4') then enroll_ma(i)=1; else enroll_ma(i)=0;
            end; 

            county_ssa_code= state_cd || cnty_cd;

            label state_cd="State SSA Code of Beneficiary Residence" county_ssa_code="County SSA Code of Beneficiary Residence";
            rename state_cd=state_ssa_code;
        run;

        proc sql;
            create table Dn100mod_&i._2 as 
            select a.*, b.fipscounty label="County FIPS Code of Beneficiary Residence", b.state as state_abbv label="State Abbreviation of Beneficiary Residence"
            from Dn100mod_&i as a 
            inner join pac.county_fips_ssa_map_2010_2017 as b
            on a.county_ssa_code=b.ssacounty and a.RFRNC_YR=b.year;
        quit;

        proc sql;
            create table Dn100mod_&i._MA as 
            select distinct fipscounty, county_ssa_code, state_abbv, RFRNC_YR, 
                            sum(enroll_ma_1)/sum(enroll_part_a_1) as county_ma_pct_1 format=percent7.2,
                            sum(enroll_ma_2)/sum(enroll_part_a_2) as county_ma_pct_2 format=percent7.2,
                            sum(enroll_ma_3)/sum(enroll_part_a_3) as county_ma_pct_3 format=percent7.2,
                            sum(enroll_ma_4)/sum(enroll_part_a_4) as county_ma_pct_4 format=percent7.2,
                            sum(enroll_ma_5)/sum(enroll_part_a_5) as county_ma_pct_5 format=percent7.2,
                            sum(enroll_ma_6)/sum(enroll_part_a_6) as county_ma_pct_6 format=percent7.2,
                            sum(enroll_ma_7)/sum(enroll_part_a_7) as county_ma_pct_7 format=percent7.2,
                            sum(enroll_ma_8)/sum(enroll_part_a_8) as county_ma_pct_8 format=percent7.2,
                            sum(enroll_ma_9)/sum(enroll_part_a_9) as county_ma_pct_9 format=percent7.2,
                            sum(enroll_ma_10)/sum(enroll_part_a_10) as county_ma_pct_10 format=percent7.2,
                            sum(enroll_ma_11)/sum(enroll_part_a_11) as county_ma_pct_11 format=percent7.2,
                            sum(enroll_ma_12)/sum(enroll_part_a_12) as county_ma_pct_12 format=percent7.2
            from Dn100mod_&i._2
            group by fipscounty
            order by fipscounty, RFRNC_YR;
        quit; 

        data snf.County_Month_MA_&i(drop=county_ma_pct_1-county_ma_pct_12 i);
            set Dn100mod_&i._MA;
            array  county_ma_pct(12) county_ma_pct_1-county_ma_pct_12;
            do i=1 to 12;
            month=i;
            county_month_ma_pct=county_ma_pct(i);
            output;
            end;
            format county_month_ma_pct percent7.2;
            label county_month_ma_pct="County-Month Level MA Enrollment Percent" month="Month";
        run;

        proc sort data=snf.County_Month_MA_&i; by fipscounty RFRNC_YR month; run;

    %end;
%mend;

%county_month_ma_pct(2010,2016);	

data snf.County_Month_MA_2010_2016;
    set snf.County_Month_MA_2010 snf.County_Month_MA_2011 snf.County_Month_MA_2012 snf.County_Month_MA_2013 
        snf.County_Month_MA_2014 snf.County_Month_MA_2015 snf.County_Month_MA_2016;
run; 

proc sql; create table check_missing as select * from snf.County_Month_MA_2010_2016 where county_month_ma_pct=. or month=. or fipscounty=""; quit;

%let todaysDate = %sysfunc(today(), mmddyyn8.);
%put &todaysDate;

ods rtf file="/secure/project/PACUse_RWerner/Mingyu/SNF_LOS/Summary/Summary_of_County_Month_Level_MA_Enrollment_&todaysDate..rtf";
    title1 "Summary of County-Month Level Medicare Advantage Enrollment by Year";
    proc means data=snf.County_Month_MA_2010_2016 nonobs n mean median min max maxdec=3;
    var county_month_ma_pct;
    class RFRNC_YR;
    run;
    title1;

    title2 "Summary of County-Month Level Medicare Advantage Enrollment by State";
    proc means data=snf.County_Month_MA_2010_2016 nonobs n mean median min max maxdec=3;
    var county_month_ma_pct;
    class state_abbv;
    run;
    title2;
ods rtf close;



/**********************************************************************************************************************************************************
 Step 5: Calculate county-year level MA enrollment using MBSF %MA=(HMO not equals "", "0", "4")/ (BUYIN not equals "0")
**********************************************************************************************************************************************************/

%macro county_year_ma_pct(start_yr,end_yr); 
    %do i=&start_yr %to &end_yr;

        data Dn100mod_&i(keep=bene_id enroll_part_a enroll_ma RFRNC_YR county_ssa_code);
        set Denom.Dn100mod_&i(keep=bene_id BUYIN01 HMOIND01 RFRNC_YR state_cd cnty_cd);

        where state_cd in ("01","03","04","05","06","07","08","09","10","11","13","14",
                        "15","16","17","18","19","20","21","22","23","24","25","26",
                        "27","28","29","30","31","32","33","34","35","36","37","38",
                        "39","41","42","43","44","45","46","47","49","50","51","52","53");

            *Eligible for Medicare coverage;
            if BUYIN01 not in ('0'," ") | HMOIND01 not in ('0'," ") then enroll_part_a=1; else enroll_part_a=0;
            *Eligible for Medicare coverage and enrolled in MA;
            if HMOIND01 not in (" ",'0','4') then enroll_ma=1; else enroll_ma=0;

        county_ssa_code= state_cd || cnty_cd;

        label state_cd="State SSA Code of Beneficiary Residence" county_ssa_code="County SSA Code of Beneficiary Residence";
        rename state_cd=state_ssa_code;

        run;

        proc sql;
            create table Dn100mod_&i._2 as 
            select a.*, b.fipscounty label="County FIPS Code of Beneficiary Residence", b.state as state_abbv label="State Abbreviation of Beneficiary Residence"
            from Dn100mod_&i as a 
            inner join pac.county_fips_ssa_map_2010_2017 as b
            on a.county_ssa_code=b.ssacounty and a.RFRNC_YR=b.year;
        quit;

        proc sql;
            create table snf.County_Year_MA_&i as 
            select distinct fipscounty, county_ssa_code, state_abbv, RFRNC_YR, 
                            sum(enroll_ma)/sum(enroll_part_a) as county_year_ma_pct format=percent7.2 label="County-Year Level MA Enrollment Percent" 
            from Dn100mod_&i._2
            group by fipscounty
            order by fipscounty;
        quit; 

    %end;
%mend;
 
%county_year_ma_pct(2010,2016);

data snf.County_Year_MA_2010_2016;
    set snf.County_Year_MA_2010 snf.County_Year_MA_2011 snf.County_Year_MA_2012 snf.County_Year_MA_2013 
        snf.County_Year_MA_2014 snf.County_Year_MA_2015 snf.County_Year_MA_2016;
run; *22,102; 

proc sort data=snf.County_Year_MA_2010_2016; by county_ssa_code rfrnc_yr; run; 

%let todaysDate = %sysfunc(today(), mmddyyn8.);
%put &todaysDate;

ods rtf file="/secure/project/PACUse_RWerner/Mingyu/SNF_LOS/Summary/Summary_of_County_Year_Level_MA_Enrollment_&todaysDate..rtf";
    title1 "Summary of County-Year Level Medicare Advantage Enrollment by Year";
    proc means data=snf.County_Year_MA_2010_2016 nonobs n mean median min max maxdec=3;
    var county_year_ma_pct;
    class RFRNC_YR;
    run;
    title1;

    title2 "Summary of County-Year Level Medicare Advantage Enrollment by State";
    proc means data=snf.County_Year_MA_2010_2016 nonobs n mean median min max maxdec=3;
    var county_year_ma_pct;
    class state_abbv;
    run;
    title2;
ods rtf close;



/**********************************************************************************************************************************************************
 Step 6: Calculate state-year level MA enrollment using MBSF %MA=(HMO not equals "", "0", "4")/ (BUYIN not equals "0")
**********************************************************************************************************************************************************/

%macro state_year_ma_pct(start_yr,end_yr); 
    %do i=&start_yr %to &end_yr;

        data Dn100mod_&i(keep=bene_id enroll_part_a enroll_ma RFRNC_YR state_ssa_code);
            set Denom.Dn100mod_&i(keep=bene_id BUYIN01 HMOIND01 RFRNC_YR state_cd cnty_cd);

            where state_cd in ("01","03","04","05","06","07","08","09","10","11","13","14",
                            "15","16","17","18","19","20","21","22","23","24","25","26",
                            "27","28","29","30","31","32","33","34","35","36","37","38",
                            "39","41","42","43","44","45","46","47","49","50","51","52","53");

                *Eligible for Medicare coverage;
                if BUYIN01 not in ('0'," ") | HMOIND01 not in ('0'," ") then enroll_part_a=1; else enroll_part_a=0;
                *Eligible for Medicare coverage and enrolled in MA;
                if HMOIND01 not in (" ",'0','4') then enroll_ma=1; else enroll_ma=0;

            label state_cd="State SSA Code of Beneficiary Residence";
            rename state_cd=state_ssa_code;

        run;

        proc sql;
            create table Dn100mod_&i._2 as 
            select a.*, b.fipsstate label="State FIPS Code of Beneficiary Residence", b.state as state_abbv label="State Abbreviation of Beneficiary Residence"
            from Dn100mod_&i as a 
            inner join pac.county_fips_ssa_map_2010_2017 as b
            on a.state_ssa_code=b.ssastate and a.RFRNC_YR=b.year;
        quit;

        proc sql;
            create table snf.State_Year_MA_&i as 
            select distinct fipsstate, state_ssa_code, state_abbv, RFRNC_YR, 
                            sum(enroll_ma)/sum(enroll_part_a) as state_year_ma_pct format=percent7.2 label="State-Year Level MA Enrollment Percent" 
            from Dn100mod_&i._2
            group by fipsstate
            order by fipsstate;
        quit; 

    %end;
%mend;
 
%state_year_ma_pct(2010,2016);

data snf.State_Year_MA_2010_2016;
    set snf.State_Year_MA_2010 snf.State_Year_MA_2011 snf.State_Year_MA_2012 snf.State_Year_MA_2013 
        snf.State_Year_MA_2014 snf.State_Year_MA_2015 snf.State_Year_MA_2016;
run; 

proc sort data=snf.State_Year_MA_2010_2016; by fipsstate rfrnc_yr; run; 

%let todaysDate = %sysfunc(today(), mmddyyn8.);
%put &todaysDate;

ods rtf file="/secure/project/PACUse_RWerner/Mingyu/SNF_LOS/Summary/Summary_of_State_Year_Level_MA_Enrollment_&todaysDate..rtf";
    title1 "Summary of State-Year Level Medicare Advantage Enrollment by Year";
    proc means data=snf.State_Year_MA_2010_2016 nonobs n mean median min max maxdec=3;
    var state_year_ma_pct;
    class RFRNC_YR;
    run;
    title1;

    title2 "Summary of State-Year Level Medicare Advantage Enrollment by State";
    proc means data=snf.State_Year_MA_2010_2016 nonobs n mean median min max maxdec=3;
    var state_year_ma_pct;
    class state_abbv;
    run;
    title2;
ods rtf close;



/**********************************************************************************************************************************************************
 Step 7: Define cohort of SNF discharges:
         1) FFS; 
         2) Label overlapping episode within 90 days prior to index hospital admission;
         3) Had preceding hospital stay within 1 day prior to SNF admission;
         4) Not discharged to hospice and not admitted into SNF for hospice;
**********************************************************************************************************************************************************/

proc sort data=snf.prior_hosp_2010_2016; by bene_id admsndt; run;

*Calculate the interval between current hospital admission and prior hospital discharge;
data prior_hosp_2010_2016(drop=dschrgdt_lag);
    set snf.prior_hosp_2010_2016; 
    by bene_id admsndt;
    dschrgdt_lag=lag(dschrgdt);
    if first.bene_id then dschrgdt_lag=.;
    if 0<=admsndt-dschrgdt_lag<=90 then episode_overlap=1; else episode_overlap=0; 
    label episode_overlap="Inpatient Episode in 90 Days Prior to Current Hospital Admission";
    where FFS_enrollment_elig=1;
run; *50,237,285;

proc freq data=prior_hosp_2010_2016;
    table episode_overlap;
run;

*Merge SNF stay cohort with hospital stay cohort using 1-day window;
proc sql;
    create table snf_all_2010_16 as 
    select a.*, b.*
    from prior_hosp_2010_2016 as a 
    inner join snf.snf_stay_2010_2016 as b 
    on a.bene_id=b.bene_id and b.admsndt_snf=a.dschrgdt;
quit; *11,054,337;

proc sort data=snf_all_2010_16; by medpar_id_snf descending dschrgdt; run;

*Keep the nearest hospital stay for each SNF stay;
data snf_all_2010_16_2;
    set snf_all_2010_16;
    by medpar_id_snf descending dschrgdt;
    if first.medpar_id_snf;
run; *11,053,843;

proc sort data=snf_all_2010_16_2; by medpar_id admsndt_snf; run;

*Keep the first SNF admission after hospital discharge;
data snf_all_2010_16_3;
    set snf_all_2010_16_2;
    by medpar_id admsndt_snf;
    if first.medpar_id;
run; *11,053,843;

*Limit records to those who discharged alive from hospital and SNF;
data snf_all_2010_16_4(drop=DSCHRGCD_SNF Coin_day coin_amt);
    set snf_all_2010_16_3;
    days_bt_hosp_and_snf=admsndt_snf-dschrgdt;
    label days_bt_hosp_and_snf="Days betweent Hospital Discharge and SNF Admission";
    format death_dt date9.;
    where DSCHRGCD_snf="A" & DSTNTNCD not in (41,42) & DSTNTNCD ne . & (death_dt=. | death_dt>dschrgdt_snf); 
run; *8,657,974;

*Identify records of dual eligible patients;
proc sql;
    create table snf_all_2010_16_5 as 
    select a.*, b.*
    from snf_all_2010_16_4 as a left join tempn.dn100mod2010_2016_dual_status as b
    on a.bene_id=b.bene_id and a.DSCHRG_YEAR=b.RFRNC_YR;
quit; *8,657,974;

proc freq data=snf_all_2010_16_5;
    table episode_overlap;
run; 

data snf_all_2010_16_6(drop=RFRNC_YR dual_elig_month_cnt i dual_elgbl_mos_num dual_stus_cd:);
    set snf_all_2010_16_5;
    array dual_cd{12} dual_stus_cd_01-dual_stus_cd_12;
    do i=1 to 12;
        if month(dschrgdt)=i then dual_stus_cd=dual_cd{i};
    end;
    if dual_stus_cd in ("02","04","08") then dual_stus=1; else dual_stus=0;
    if dual_stus_cd="99" then dual_stus=.;
    label dual_stus="Dual Eligible Status";
run; *8,657,974;

*Exclude records of discharged to hospice from hospital or received hospice care in SNF;
proc sql;
    create table snf_all_2010_16_7 as
    select snf.*, hospice.O0100K2_HOSPC_POST_CD as snf_hospice label="Received Hospice Care at SNF"
    from snf_all_2010_16_6 as snf 
    left join pac_mds.mds_hospice_2010_2016 as hospice
    on snf.bene_id=hospice.bene_id and -1 le snf.ADMSNDT_SNF-hospice.MDS_ENTRY_DT le 1;
quit; *8,658,036;

proc sort data=snf_all_2010_16_7 nodupkey; by medpar_id_snf ; run; *8,657,974; 

data snf_all_2010_16_8(drop=snf_hospice);
    set snf_all_2010_16_7;
    where DSTNTNCD not in (50,51) & snf_hospice^="1";
run; *8,599,421; 



/**********************************************************************************************************************************************************
Step 8: Define mortality and SNF readmission within 30 days and 90 days after SNF discharge
**********************************************************************************************************************************************************/

data snf_all_2010_16_9;
    set snf_all_2010_16_8;
    * 30-day mortality after SNF discharge;
    if DSCHRGDT_SNF le DEATH_DT le DSCHRGDT_SNF+30 then DeathIn30Days_SNF=1; else DeathIn30Days_SNF=0;
run; *8,599,421;

proc freq data=snf_all_2010_16_9;
    table DeathIn30Days DeathIn30Days_SNF;
run;

data medpar0916_snf;
    set medpar.mp100mod_2009(keep=BENE_ID ADMSNDT DSCHRGDT PRVDR_NUM)
        medpar.mp100mod_2010(keep=BENE_ID ADMSNDT DSCHRGDT PRVDR_NUM)
        medpar.mp100mod_2011(keep=BENE_ID ADMSNDT DSCHRGDT PRVDR_NUM)
        medpar.mp100mod_2012(keep=BENE_ID ADMSNDT DSCHRGDT PRVDR_NUM)
        medpar.mp100mod_2013(keep=BENE_ID ADMSNDT DSCHRGDT PRVDR_NUM)
        medpar.mp100mod_2014(keep=BENE_ID ADMSNDT DSCHRGDT PRVDR_NUM)
        medpar.mp100mod_2015(keep=BENE_ID ADMSNDT DSCHRGDT PRVDR_NUM)
        medpar.mp100mod_2016(keep=BENE_ID ADMSNDT DSCHRGDT PRVDR_NUM);
    where  substr(PRVDR_NUM,3,1) in ('5','6');
run; *20,928,651; 

proc sql;
    create table snf_all_2010_16_10 as
    select a.*, b.admsndt as readmsndt_to_snf, b.PRVDR_NUM as readm_snf_prvdrnum
    from snf_all_2010_16_9 as a
    left join medpar0916_snf as b  
    on a.bene_id=b.bene_id and 0<=b.admsndt-a.DSCHRGDT_SNF<=90;
quit; *9,766,177;

proc sort data=snf_all_2010_16_10; by medpar_id_snf readmsndt_to_snf; run; 

data snf_all_2010_16_11;
    set snf_all_2010_16_10;
    by medpar_id_snf readmsndt_to_snf;
    if first.medpar_id_snf;
run; *8,599,421;

data snf_all_2010_16_12;
    set snf_all_2010_16_11;
    format DSCHRGDT_SNF date9.;
    if readmsndt_to_snf^=. then radm90snf_to_snf=1; else radm90snf_to_snf=0;
    if readmsndt_to_snf^=. and 0<=readmsndt_to_snf-DSCHRGDT_SNF<=30 then radm30snf_to_snf=1; else radm30snf_to_snf=0;
    label radm30snf_to_snf="Readmission to SNF within 30-Day after SNF Discharge" 
        radm90snf_to_snf="Readmission to SNF within 90-Day after SNF Discharge" readmsndt_to_snf="Date of Readmission to SNF";
run; *8,599,421;

proc freq data=snf_all_2010_16_12;
    tables (radm30snf_to_snf radm90snf_to_snf);
run;



/**********************************************************************************************************************************************************
Step 9: Merge in county-month, county-year, state-year %MA based for SNFs and beneficiaries
**********************************************************************************************************************************************************/

*Merge in COUNTY-MONTH level %MA variable;
proc sql;
    create table snf_all_2010_16_13 as 
    select a.*, b.county_month_ma_pct, b.fipscounty as snf_fipscounty
    from snf_all_2010_16_12 as a 
    left join snf.County_Month_MA_2010_2016 as b
    on a.snf_county_ssa_code=b.county_ssa_code & a.dschrg_year=b.RFRNC_YR & a.dschrg_month=b.month;
quit; *8,599,421;

proc sql; create table check_merge as select bene_id from snf_all_2010_16_13 where county_month_ma_pct=.; quit; *23,126 (0.27%) not matched;

*Merge in COUNTY-YEAR level %MA variable;
proc sql;
    create table snf_all_2010_16_14 as 
    select a.*, b.county_year_ma_pct
    from snf_all_2010_16_13 as a 
    left join snf.County_Year_MA_2010_2016 as b
    on a.snf_county_ssa_code=b.county_ssa_code & a.dschrg_year=b.RFRNC_YR;
quit; *8,599,421; 

proc sql; create table check_merge as select bene_id from snf_all_2010_16_14 where county_year_ma_pct=.; quit; *23,126 (0.27%) not matched;

*Merge in STATE-YEAR level %MA variable;
proc sql;
    create table snf_all_2010_16_15 as 
    select a.*, b.state_year_ma_pct
    from snf_all_2010_16_14 as a 
    left join snf.State_Year_MA_2010_2016 as b
    on a.snf_state_ssa_code=b.state_ssa_code & a.dschrg_year=b.RFRNC_YR;
quit; *8,599,421;

proc sql; create table check_merge as select bene_id from snf_all_2010_16_15 where state_year_ma_pct=.; quit; *19,677 (0.25%) not matched; 

data snf_all_2010_16_16;
    set snf_all_2010_16_15;
    where county_month_ma_pct^=. & county_year_ma_pct^=. & state_year_ma_pct^=.;
run; *8,576,295;

*Merge in beneficiaries' state and county SSA code and exclude people who don't live in contiguous US;
data medpar_state_cd_2010_2016;
    set medpar.mp100mod_2010(keep=medpar_id state_cd cnty_cd) medpar.mp100mod_2011(keep=medpar_id state_cd cnty_cd) 
        medpar.mp100mod_2012(keep=medpar_id state_cd cnty_cd) medpar.mp100mod_2013(keep=medpar_id state_cd cnty_cd) 
        medpar.mp100mod_2014(keep=medpar_id state_cd cnty_cd) medpar.mp100mod_2015(keep=medpar_id state_cd cnty_cd)
        medpar.mp100mod_2016(keep=medpar_id state_cd cnty_cd);
    county_ssa_code= state_cd || cnty_cd;
    label county_ssa_code="SSA County Code of Beneficiary Residence";
run;

proc sql;
    create table snf_all_2010_16_17 as 
    select a.*, b.county_ssa_code as bene_county_ssa_code, b.state_cd as bene_state_ssa_code
    from snf_all_2010_16_16 as a 
    inner join medpar_state_cd_2010_2016 as b
    on a.medpar_id=b.medpar_id
    where b.state_cd in ("01","03","04","05","06","07","08","09","10","11","13","14",
                    "15","16","17","18","19","20","21","22","23","24","25","26",
                    "27","28","29","30","31","32","33","34","35","36","37","38",
                    "39","41","42","43","44","45","46","47","49","50","51","52","53");
quit; *8,570,757;

*Merge in COUNTY-MONTH level %MA variable based on county of beneficiary's residence;
proc sql;
    create table snf_all_2010_16_18 as 
    select a.*, b.county_month_ma_pct as bene_county_month_ma_pct, b.fipscounty as bene_fipscounty
    from snf_all_2010_16_17 as a 
    left join snf.County_Month_MA_2010_2016 as b
    on a.bene_county_ssa_code=b.county_ssa_code & a.dschrg_year=b.RFRNC_YR & a.dschrg_month=b.month;
quit; *8,570,757;

proc sql; create table check_merge as select bene_id from snf_all_2010_16_18 where bene_county_month_ma_pct=.; quit; *3,583;

*Merge in COUNTY-YEAR level %MA variable;
proc sql;
    create table snf_all_2010_16_19 as 
    select a.*, b.county_year_ma_pct as bene_county_year_ma_pct
    from snf_all_2010_16_18 as a 
    left join snf.County_Year_MA_2010_2016 as b
    on a.bene_county_ssa_code=b.county_ssa_code & a.dschrg_year=b.RFRNC_YR;
quit; *8,570,757;

proc sql; create table check_merge as select bene_id from snf_all_2010_16_19 where bene_county_year_ma_pct=.; quit; *3,582; 

*Merge in STATE-YEAR level %MA variable;
proc sql;
    create table snf_all_2010_16_20 as 
    select a.*, b.state_year_ma_pct as bene_state_year_ma_pct
    from snf_all_2010_16_19 as a 
    left join snf.State_Year_MA_2010_2016 as b
    on a.bene_state_ssa_code=b.state_ssa_code & a.dschrg_year=b.RFRNC_YR;
quit; *8,570,757;

proc sql; create table check_merge as select bene_id from snf_all_2010_16_20 where bene_state_year_ma_pct=.; quit; *0;

data snf.snf_los_county_ma_1016_new;
    set snf_all_2010_16_20;
    where bene_county_month_ma_pct^=. & bene_county_year_ma_pct^=. & bene_state_year_ma_pct^=.;
run; *8,567,174;



/**********************************************************************************************************************************************************
Step 10: Create 30-day readmission after SNF discharge indicator;
**********************************************************************************************************************************************************/

/*SET MEASURE VARIABLE  MI HF PN CD SK HW HKC HKR*/
%LET DX = HW;

/*ASSIGN VALUES FOR MAX NUMBER OF DIAGNOSIS AND PROCEDURE CODES*/
* Keep only first 10 diagnosis codes, even for 2011-2015 MedPAR;
%LET DXN = 10;
%LET PRN = 6;

/*ASSIGN FIRST YEAR OF REPORTING PERIOD 12 FOR HW*/
%LET YY = 09;

/*ASSIGN LAST YEAR OF REPORTING PERIOD*/
%LET YYE = 16;

/* NUMBER OF YEARS IN THE REPORTING PERIOD */
%LET NYEAR = 8;

/*END MONTH FOR COVERAGE DATA*/
%LET MM=12;

/* START AND END YEAR */
%LET YEAR=0916;
%LET CONDITION=HW; 
%LET PATH1= /secure/project/RWerner_CMS_Readmissions/working_files/Output Datasets; /*RAW DATA FILES PATH, MUST BE CHANGED */
%LET PATH2= /secure/project/RWerner_CMS_Readmissions/working_files/Output Datasets; /*DERIVED DATA FILES PATH, MUST BE CHANGED */
%LET PATH3= /secure/project/RWerner_CMS_Readmissions; /*SAS MACROS FILE PATH, MUST BE CHANGED  */
%let path4= /secure/project/RWerner_CMS_Readmissions/Project Code/Format/CCS_ICD10_PCS; /*AHRQ CCS for ICD10-PCS FOLDER*/
%let path5= /project/RWerner_CMS_Readmissions/Project Code/Format/CCMAP_ICD10_2015;
%let path6= /project/RWerner_CMS_Readmissions/Project Code/Format/CCMAP_ICD9_2015;
%let path7= /project/RWerner_CMS_Readmissions/Project Code/Format/CCS_ICD10_New;
%let path8= /project/RWerner_CMS_Readmissions/Project Code/Format/CCS_ICD9_New;


/**********************************************************************
* INPUT DATASET NAMES
**********************************************************************/
%LET stay_dataset 		  =stay_dataset;
%LET bene_dataset 		  =bene_dataset;
%LET coverage_dataset 	  =coverage&YYE._&MM.;
%LET pta_in_base_dataset  =pta_in_base_dataset;
%LET pta_in_line_dataset  =pta_in_line_dataset;  /*ONLY USED IN STAY CREATION*/
%LET pta_out_base_dataset =pta_out_base_dataset;
%LET pta_out_line_dataset =pta_out_line_dataset;
%LET ptb_line_dataset 	  =ptb_line_dataset;


/***************************************************************
* MACROS FOR HOSPITAL WIDE READMISSION - 2013             	  *
***************************************************************/
/* 1) Revised GLIMMIX by removing Random = _Residual_ line  
   2) Updated Labels for Risk Variables */

%MACRO RETRIEVE_HX(INDEXFILE,  OUT_DIAG);
    /* IDENTIFYING ADMISSIONS THAT BELONG TO A TRANSFER BUNDLE AND KEEPING
        ONLY ADMISSIONS BEFORE THE LAST ONE OF A TRANSFER BUNDLE */
    PROC SQL;
        CREATE TABLE BUNDLE AS
        SELECT HICNO, CASEID, HISTORY_CASE, COUNT(HICNO) AS MAXCASE
        FROM &INDEXFILE (RENAME=(CASE=CASEID))
        GROUP BY HICNO, HISTORY_CASE
        HAVING MAXCASE > 1;
    QUIT;

    DATA BUNDLE;
        SET BUNDLE;
        HICNO_HXCASE=HICNO||'_'||HISTORY_CASE;
    RUN;

    PROC SORT DATA=BUNDLE;
        BY HICNO_HXCASE CASEID;
    RUN;

    DATA BUNDLE;
        SET BUNDLE;
        BY HICNO_HXCASE;
        IF LAST.HICNO_HXCASE THEN DELETE;
    RUN;

    PROC SORT DATA=BUNDLE;
        BY HICNO CASEID;
    RUN;

    PROC SORT DATA=&INDEXFILE out=index;
        BY HICNO CASE;
    RUN;

    /* add e codes from index - jng 2012 */
    DATA &OUT_DIAG;
        MERGE BUNDLE (IN=A RENAME=(HISTORY_CASE=CASE) DROP=MAXCASE HICNO_HXCASE) 
            index (KEEP=HICNO CASE ADMIT DISCH DIAG1-DIAG10 EDGSCD01-EDGSCD12 EVRSCD01-EVRSCD12 YEAR DVRSND01-DVRSND10  /* changed 06/27/2018 MQ*/
            RENAME=(CASE=CASEID ADMIT=FDATE DISCH=TDATE));
        BY HICNO CASEID;
        IF A;
        diag11 = EDGSCD01; diag12 = EDGSCD02; diag13 = EDGSCD03; diag14 = EDGSCD04;
        diag15 = EDGSCD05; diag16 = EDGSCD06; diag17 = EDGSCD07; diag18 = EDGSCD08;
        diag19 = EDGSCD09; diag20 = EDGSCD10; diag21 = EDGSCD11; diag22 = EDGSCD12;

        attrib diag length=$7.;   /* CHANGE to 7 JNG - 5010 update */
        ARRAY ICD(1:22) $ DIAG1-DIAG22; /* for 2011 mm with VA data 1/24/2011 zq - more added 12/11 jng */
        ARRAY DVRSND_(1:22) DVRSND01-DVRSND10 EVRSCD01-EVRSCD12;
        DO I=1 TO 22;
            IF I=1 THEN DO;
            SOURCE='0.0.1.0';
                DIAG=ICD(I);
                DVRSND = DVRSND_(I);
            OUTPUT;
            END;
            ELSE DO;
            SOURCE='0.0.2.0';
                DIAG=ICD(I);
                DVRSND = DVRSND_(I);
            OUTPUT;
            END;
        END;
        KEEP HICNO CASE DIAG FDATE TDATE SOURCE YEAR DVRSND;
    RUN;

    DATA &OUT_DIAG;
        SET &OUT_DIAG;
            *IF &CDIAG THEN DIAG='';
            IF DIAG IN ('', ' ') THEN DELETE;
    RUN;

%MEND RETRIEVE_HX;

OPTIONS SYMBOLGEN MPRINT;  
*****************************************************************************;
* SPECIFY VARIOUS FILE PATHES, DISEASE CONDITION, AND YEAR                  *;
*****************************************************************************;
*****************************************************************************;
LIBNAME RAW "&PATH1";    *Where raw data is stored;
LIBNAME R "&PATH2";      *Where results are stored;
LIBNAME C "&PATH4";	 *Where AHRQ CCS formats for ICD10 procedure codes are stored;
LIBNAME D "&PATH5";	 *Where CC formats for ICD10 (2015 version) are stored;
LIBNAME E "&PATH6";	 *Where CC formats for ICD9 (2015 version) are stored;
LIBNAME F "&PATH7";	 *Where CCS formats for ICD10 (2015 version) are stored;
LIBNAME G "&PATH8";	 *Where CCS formats for ICD9 (2015 version) are stored;
OPTIONS FMTSEARCH=(C D E F G) SYMBOLGEN MPRINT;

%LET ADMISSION=RAW.index_&CONDITION._&YEAR; 
%LET POST=RAW.POSTINDEX_&CONDITION._&YEAR; 
%LET HXDIAG=RAW.DIAGHISTORY_&CONDITION._&YEAR;
%LET ALL=R.&CONDITION._READM_ALL;
%LET ANALYSIS=R.&CONDITION._READM_ANALYSIS;
%LET HWR_RSRR=R.&CONDITION._READM_RSRR;
%LET RESULTS=R.&CONDITION._RSRR_BS; /* pls note keep this name short; */
%LET EST=R.&CONDITION._READM_EST;

/* Hospital Wide READMISSION MODEL VARIABLES */
%LET MODEL_VAR=AGE_65 MetaCancer SevereCancer OtherCancer Hematological Coagulopathy 
	IronDeficiency LiverDisease PancreaticDisease OnDialysis RenalFailure Transplants
	HxInfection OtherInfectious Septicemia CHF CADCVD Arrhythmias CardioRespiratory 
	COPD LungDisorder Malnutrition MetabolicDisorder Arthritis Diabetes Ulcers
	MotorDisfunction Seizure RespiratorDependence  Alcohol Psychological HipFracture;   

%let TRANS_DIAG=R.DIAGHISTORY_&CONDITION._&YEAR._TRANS;

%RETRIEVE_HX(&ADMISSION,&TRANS_DIAG);

data INDEX;
    set &ADMISSION (WHERE=(PARA=1)); 
    *Drop variables that we are not going to use to speed up processing;
    drop ADMSOUR CCUIND COUNTY DISST   EDBVDETH  GROUP ICUIND LOS MSCD NPI_AT NPI_OP  
        POANCD1-POANCD25 POAEND01-POAEND12 POSTMO POSTMOD POSTMO_A PREMO PROCDT1-PROCDT6 
        TYPEADM UNRELDMG UNRELDTH UPIN_AT UPIN_OP;  
RUN; *105,492,870;

proc sql;
    create table INDEX_2 as
    select all.dschrgdt_snf, readm.*
    from snf.snf_los_county_ma_1016_new_3 as all
    inner join INDEX as readm
    on all.BENE_ID=readm.HICNO and all.ADMSNDT>=readm.ADMIT and all.DSCHRGDT<=readm.DISCH;
quit; *6,486,810;

/* ELIMINATE ADMISSIONS THAT APPEAR TWICE (ACROSS YEARS) */
PROC SORT DATA=INDEX_2 NODUPKEY DUPOUT=QA_DupOut EQUALS;
	BY HICNO ADMIT DISCH PROVID;
RUN; *6,486,807;

/* IDENTIFY AND COMBINE TWO ADJACENT AMI ADMISSIONS (disch1=admit2), USE DISCHARGE DATE OF 2ND ADMISSION 
   TO REPLACE DISCHARGE DATE OF 1ST ADMISSION (disch1=disch2), SAME FOR DISCHARGE STATUS, TRANS_FIRST, 
   TRANS_MID, POSTMOD. ALSO, CREATE CASE_P TO BE USED FOR FINDING READMISSION. THIS WORKS WHEN THERE ARE 
   MORE THAN TWO ADJACENT AMI ADMISSIONS. */
DATA TEMP; 
	SET INDEX_2;
	BY HICNO;  
    if (admit <= lag(disch) <= disch) and lag(provid)=provid
        and lag(hicno)=hicno and lag(diag1) = diag1
        then combine0=1;
    else combine0=0;
RUN; 

proc sort data=TEMP;
	by hicno DESCENDING admit DESCENDING disch;
run;

data TEMP2 QA_CombOut_mid;
    set TEMP;
    by hicno;
    if (admit <= lag(admit) <= disch) and 
        lag(provid)=provid
        and lag(hicno)=hicno and lag(diag1) = diag1
        then combine=1;
    else combine=0;
    if combine0 and combine then output QA_CombOut_mid; *0;
    else output TEMP2; 
run; 

data TEMP3 QA_CombOut_last;
    set TEMP2;
    disch_2=lag(disch);
    case_2=lag(case);
    ddest_2=lag(ddest);
    trans_first_2=lag(trans_first);
    trans_mid_2=lag(trans_mid);
    postmod_a2=lag(postmod_a);  
    
    if lag(provid)=provid and lag(hicno)=hicno and lag(combine0)=1 then do;  
        disch=disch_2;
        case_p=case_2;
        ddest=ddest_2;
        trans_first=trans_first_2;
        trans_mid=trans_mid_2;
        postmod_a=postmod_a2;
    end;
    else case_p=case;

    drop disch_2 case_2 ddest_2 trans_first_2 trans_mid_2 postmod_a2;

    if combine0 ^=1 then output TEMP3; *9,008,210;
    else output QA_CombOut_last;
run; *6,486,508;

PROC SORT DATA=TEMP3;
	BY HICNO DESCENDING ADMIT  DESCENDING DISCH PROVID;
RUN; *6,486,508;

/* APPLY THE FOLLOWING INCLUSION AND EXCLUSION CRITERIA:
   AGE >=65,   DEAD=0, PREMO=12, POSTMOD=1, 2, 3, TRANS_COMBINE=0, AMA=0 */
DATA ALL; 
    SET TEMP3 (DROP=COMBINE0);
    BY HICNO;
    ATTRIB TRANSFER_OUT LABEL='TRANSFER OUT' LENGTH=3.;
    ATTRIB TRANS_COMBINE LABEL='Equals to 1 if it is a combined discharge' LENGTH=3.;
    ATTRIB DD30 LABEL='30-DAY MORTALITY FROM DISCHARGE' LENGTH=3.;
    ATTRIB AGE_65 LABEL='YEARS OVER 65' LENGTH=3.;
    ATTRIB AGE65 LABEL='AGE GE 65' LENGTH=3.;
    ATTRIB DEAD LABEL='IN HOSPITAL DEATH' LENGTH=3.;
    ATTRIB sample LABEL='MEET INC & EXL CRITERIA' LENGTH=3.;
    LENGTH ADDXG $7. DCGDIAG $7. proccc1-proccc6 $7. proc1 - proc6 $7. rehabexcl 3.;

    array ahrqcc{6} $ proccc1 - proccc6;
    array surg{10} ophtho vascular ortho gen ct uro neuro obgyn plastic ent;

    DCGDIAG = diag1;

    if DVRSND01='0' then do;
        ADDXG = PUT(DCGDIAG,$CCS10CD.);
    if addxg = "" then delete;
        proccc1 = put(proc1,$ICD10_PRCCS.);
        proccc2 = put(proc2,$ICD10_PRCCS.); 
        proccc3 = put(proc3,$ICD10_PRCCS.);  
        proccc4 = put(proc4,$ICD10_PRCCS.); 
        proccc5 = put(proc5,$ICD10_PRCCS.); 
        proccc6 = put(proc6,$ICD10_PRCCS.); 

    rehabexcl=0;
    if addxg in ('254') then rehabexcl=1; /* excluding rehab ccs*/

    ******PSYCH CODES as Exclusion****************;
    psychexcl = 0;   
    if addxg in ('650', '651', '652','654', '655', '656', '657', '658', '659', '662', '670') then psychexcl = 1;

    ***********Subset Surgeries into Catergories - not used for reporting
        *******  Remove CCS 61 from Surgical Cohort   *****;
    do i =1 to 6;
        if ahrqcc(i) in ('20', '15', '16', '14', '13', '17') then ophtho=1;
        if ahrqcc(i) in ('51', '55', '52', '60', '59', '56', '53') then vascular=1;
        if ahrqcc(i) in ('153', '146', '152', '158', '3', '161', '142', '147', 
            '162', '148', '154', '145', '150' /*'151', '143'*/) then ortho=1;  ****REMOVE 143, 151 FOR ICD-10***;
        if ahrqcc(i) in ('78', '157', '84', '90', '96', '75', '86', '105', '72', 
            '80', '73', '85', '164', '74', '167', '176', '89', '166', '99', '94',
            '67', '66', '79') then gen=1;
        if ahrqcc(i) in ('44', '43', '49', '36', '42') then ct=1;
        if ahrqcc(i) in ('101', '112', '103', '104', '114', '118', '113', '106','109') then uro=1;**ADD 109 FOR ICD-10; 
        if ahrqcc(i) in ('1', '9', '2') then neuro=1;
        if ahrqcc(i) in ('172', '175', '28', '144', '160') then plastic=1;
        if ahrqcc(i) in ('33', '10', '12', '26', '21', '23','30','24', '22') then ent=1; 
            if ahrqcc(i) in ('124', '119', '132', '129', '134','139', '137', '125','131', '120', 
                            '123', /*'140',*/ '136', '127', '135', '121', '141', '126', '133','122') then obgyn=1;  * REMOVE 140 FOR ICD-10;
    end;

    do j=1 to 10;
        if surg(j)=. then surg(j)=0;
    end;
    surg_sum=sum(ophtho, vascular, ortho, gen, ct, uro, neuro, obgyn, plastic, ent);

    attrib category length=$10.;
    if ophtho or vascular or ortho or gen or ct or uro or neuro or plastic or ent or obgyn then
    category='Surgical';
    else category='Medical';

    attrib subcategory length=$18.;

        if addxg in ('11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', 
                    '23', '24', '29', '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '40', 
                    '41', '42', '43', '44', '45','25','26','27','28') then subcategory='Cancer';
        else if addxg in ('56','103', '108', '122', '125', '127', '128', '131') then subcategory='Cardiorespiratory';
        else if addxg in ('96', '97', '100', '101', '102', '104', '105', '106', '107', '114', '115', '116', '117', '213') then subcategory='CV';
        else if addxg in ('1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '47', '48', '49', 
                        '50', '51', '52', '53',	'54', '55', '57', '58', '59', '60', '61', '62', '63', 
                        '64', '76', '77', '84', '86', '87', '88', '89',	'90', '91', '92', '93', '94', '98', 
                        '99', '118', '119', '120', '121', '123', '124', '126', '129',
                        '130', '132', '133', '134', '135', '136', '137', '138', '139', '140', '141', '142', 
                        '143', '144', '145', '146', '147', '148', '149', '151', '152', '153', '154', '155', 
                        '156', '157', '158', '159', '160', '161', '162', '163', '164', '165', '166', '167', 
                        '173', '175', '197', '198', '199', '200', '201', '202',	'203', '204', '205', '206',
                        '207', '208', '209', '210', '211', '212', '214', '215', '217', '225', '226',
                        '228', '229','230', '231', '232', '234', '235', '236', '237', '238', '239', '240', 
                        '242', '243', '244', '245', '246', '247', '248', '249', '250', '251', '252', '253', 
                        '255', '256', '257', '258', '259',  '241', '168','170','172','46','171','169','174',
                        '653','661','660','663','2617' ) then subcategory='Medicine';    ****ADD 2617 TO MEDICAL COHORT IN ICD-10;   
        else if addxg in ('78', '79', '80', '81', '82', '83', '85', '95', '109', '110', '111', 
                        '112', '113', '216', '227', '233') then subcategory='Neurology';
    end;

    if DVRSND01='9' then do;

    ADDXG = PUT(DCGDIAG,$CCS.);
    if addxg = "" then delete;
    proccc1 = put(proc1,$ccsproc.);
    proccc2 = put(proc2,$ccsproc.); 
    proccc3 = put(proc3,$ccsproc.);  
    proccc4 = put(proc4,$ccsproc.); 
    proccc5 = put(proc5,$ccsproc.); 
    proccc6 = put(proc6,$ccsproc.); 
    ************************************************************************************************;

    rehabexcl=0;
    if addxg in ('254') then rehabexcl=1; /* excluding rehab ccs*/

    ******PSYCH CODES as Exclusion****************;
    psychexcl = 0;   
    if addxg in ('650', '651', '652','654', '655', '656', '657', '658', '659', 
        '662',  '664', '665', '666','667','668','669','670') then psychexcl = 1;

    ***********Subset Surgeries into Catergories - not used for reporting
        *******  Remove CCS 61 from Surgical Cohort   *****;
    do i =1 to 6;
        if ahrqcc(i) in ('20', '15', '16', '14', '13', '17') then ophtho=1;
        if ahrqcc(i) in ('51', '55', '52', '60', '59', '56', '53') then vascular=1;
        if ahrqcc(i) in ('153', '146', '152', '158', '3', '161', '142', '147', 
            '162', '148', '154', '145', '150', '151', '143') then ortho=1;
        if ahrqcc(i) in ('78', '157', '84', '90', '96', '75', '86', '105', '72', 
            '80', '73', '85', '164', '74', '167', '176', '89', '166', '99', '94',
            '67', '66', '79') then gen=1;
        if ahrqcc(i) in ('44', '43', '49', '36', '42') then ct=1;
        if ahrqcc(i) in ('101', '112', '103', '104', '114', '118', '113', '106') then uro=1;
        if ahrqcc(i) in ('1', '9', '2') then neuro=1;
        if ahrqcc(i) in ('172', '175', '28', '144', '160') then plastic=1;
        if ahrqcc(i) in ('33', '10', '12', '26', '21', '23','30','24', '22') then ent=1; 
            if ahrqcc(i) in ('124', '119', '132', '129', '134','139', '137', '125',
            '131', '120', '123', '140', '136', '127', '135', '121', '141', '126', '133',
            '122') then obgyn=1;
    end;

    do j=1 to 10;
        if surg(j)=. then surg(j)=0;
    end;
    surg_sum=sum(ophtho, vascular, ortho, gen, ct, uro, neuro, obgyn, plastic, ent);
    attrib category length=$10.;


    if ophtho or vascular or ortho or gen or ct or uro or neuro or plastic or ent or obgyn then
        category='Surgical';
    else category='Medical';
    *********************************;
    attrib subcategory length=$18.;

    ************************* Put CF (ccs 56) in CR cohort instead of Med   11/6/12  ****************************;
        if addxg in ('11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', 
                    '23', '24', '29', '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '40', 
                    '41', '42', '43', '44', '45','25','26','27','28') then subcategory='Cancer';
        else if addxg in ('56','103', '108', '122', '125', '127', '128', '131') then subcategory='Cardiorespiratory';
        else if addxg in ('96', '97', '100', '101', '102', '104', '105','106', '107', '114', '115', '116', '117', '213') then subcategory='CV';                
        else if addxg in ('1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '47', '48', '49', 
                        '50', '51', '52', '53',	'54', '55', '57', '58', '59', '60', '61', '62', '63', 
                        '64', '76', '77', '84', '86', '87', '88', '89',	'90', '91', '92', '93', '94', '98', 
                        '99', '118', '119', '120', '121', '123', '124', '126', '129',
                        '130', '132', '133', '134', '135', '136', '137', '138', '139', '140', '141', '142', 
                        '143', '144', '145', '146', '147', '148', '149', '151', '152', '153', '154', '155', 
                        '156', '157', '158', '159', '160', '161', '162', '163', '164', '165', '166', '167', 
                        '173', '175', '197', '198', '199', '200', '201', '202',	'203', '204', '205', '206',
                        '207', '208', '209', '210', '211', '212', '214', '215', '217', '225', '226',
                        '228', '229','230', '231', '232', '234', '235', '236', '237', '238', '239', '240', 
                        '242', '243', '244', '245', '246', '247', '248', '249', '250', '251', '252', '253', 
                        '255', '256', '257', '258', '259',  '241', '168','170','172','46','171','169','174',
                        '653','661','660','663') then subcategory='Medicine';    
        else if addxg in ('78', '79', '80', '81', '82', '83', '85', '95', '109', '110', '111', '112', '113', '216', '227', '233') then subcategory='Neurology';
    end;

    if category='Surgical' then subcategory='Surgical';

    ******************************************************************************************************************;
    **** exclusion of PPS-Exempt cancer hopitals  *******************;
    if provid in ('050146','050660','100079','100271','220162','330354','360242','390196','450076','330154','500138') 
    then cancer_hosp=1;
    else cancer_hosp = 0;
    ******************************************************************************************************************;
    all = 1;
    
    if rehabexcl=1 then subcategory =('Rehab excl');
    if psychexcl=1 then subcategory =('Psych excl');

    /* TRANSFER OUT INDICATOR, SAME PTS, DIFFERENT HOSP, 0 OR 1 DAY IN BETWEEN, NOT V CODE VISIT */
    TRANSFER_OUT=(ADMIT <= LAG(ADMIT) <= DISCH +1) AND (HICNO=LAG(HICNO)) AND (PROVID ^=LAG(PROVID));

    /* add post_flag to account for possible transfer that is outside of study period. 
        1/11/2010. ZQ */

    TRANS_COMBINE=(TRANSFER_OUT OR TRANS_FIRST OR TRANS_MID or post_flag); 

    MALE=(SEX='1');
    AGE=INT((ADMIT - BIRTH)/365.25);
    AGE65=(AGE >=65);
    AGE_65=AGE - 65;

    DEAD=(ddest=20);
    AMA=(ddest=7);

    IF DEATH ^=. THEN DO;
        IF 0 < (DEATH - DISCH) <=30 THEN DD30=1;
        ELSE IF (DEATH - DISCH) > 30 THEN DD30=0;
        ELSE IF (DEATH - DISCH) <= 0 THEN DD30=0;
        END;
    ELSE DD30=0;
    obs30_mort=dd30;

    /*IF (DISCH - ADMIT) = 0 THEN SameDayDischarge=1;	  ***NOT USED IN HWR Exclusions;
    ELSE SameDayDischarge=0;*/

    PRIOR12=(PREMO_A=12);    **PREMO_A is PART A enrollment only;

    IF DD30=1 THEN POSTMOD_A=1;   *If pt dies in 30day period they are eligible;
    POST1=(POSTMOD_A=1);


    /* INCLUSION CRITERIA: FFS,AGE GE 65,IN HOSPITAL DEATH,WITHOUT >= 1 MOTNH POST,
    EXCLUSION  CRITERIA: TRANSFER OUT, WITH 12-MONTH HISTORY,PPS Cancer Hosp, Rehab,
                            CANCER Medical,AMA, psych removed pre-dryrun-PUT IN AGAIN */
    if dead=0 and age65 and post1=1 and trans_combine=0 and PRIOR12=1 and ama = 0 and 
    rehabexcl=0 and cancer_hosp = 0  and subcategory not in ('Cancer') and psychexcl=0
    /* SAMPLE is used in PAC Get after discharge info.sas */
    then sample = 1; else sample=0 ;
    RUN; *6,280,613;

    PROC SORT DATA=ALL; BY HICNO CASE_P; RUN; 
    
    data postindex;
    set &post;
    length i j k 3.;

    ***** determine the Proc CCS group each procedure falls into ******;
    ATTRIB procccp_1-procccp_6  LENGTH=$3.;
    ARRAY procccp_ (1:6) procccp_1-procccp_6;
    ARRAY procccsp_(1:6) $  PROC1 - PROC6;
    ARRAY PVSNCD_(1:10) $ PVSNCD01-PVSNCD10;
    ARRAY DVRSND_(1:10) $ DVRSND01-DVRSND10;

    ***** ASSIGN PROC CCS TO PROCEDURES  **********;
    DO k=1 TO 6;
        if PVSNCD_(K)= "0" then do;
            procccp_(k) = put(procccsp_(k),$ICD10_PRCCS.); 
        end;
        else if PVSNCD_(K)= "9" then do;
            procccp_(k) = put(procccsp_(k),$ccsproc.);
        end; 
    end;

    ****** Categorize the CCS Diagnosis Claims for the potential readmissions *******;
    DCGDIAG = diag1;

    if DVRSND01='0' then do;
        ADDXG_p = PUT(DCGDIAG,$CCS10CD.);

        *****THIS SECTION UPDATED WITH FINAL PLANNED ALGORITHM *****************;

        ***** Create a variable for the AHRQ CCS acute diagnosis based exclusions for planned ****;
        ***** Some diagnosis groups are split by ICD-9 diagnosis codes                        ****;
        ** added on 11/2 Version 2.1: 
        CCS 129 to acute list, CCS 224 and 170 to planned list , remove diagnosis codes 410.x2
        from acute list CCS 100

        REVISED VERSION 3.0: ADD a split for Biliary tract disease  9/2013  add Acute Pancreatitis and HTN w/ Comp
        ******************************************************************************************;

        if ADDXG_p in ('1','2','3','4','5','7','8','9','54','55','60','61','63','76','77','78','82'
        ,'83','84','85','87','89','90','91','92','93', '102','104','107','109','112',
        '116','118','120','122','123','99',
        '124','125','126','127','128','129','130','131','135',
        '137','139','140','142','145','146','148',
        '153','154','157','159','165','168','172','197','198','225','226','227','228','229','230',
        '232','233','234','235','237','238','239','240','241','242','243','244','245','246','247',
        '249','250','251','252','253','259','650','651','652','653','656','658','660','661','662','663','670')
        OR 
        (addxg_p in ('97') and  diag1 in 
        ('A3681','A3950','A3953','A3951','A3952','B3320','B3323','B3321','B3322','B376',
        'I32','I39','B5881','I010','I011','I012','I018','I019','I020','I090',
        'I099','I0989','I309','I301','I300','I308','I330','I339','I41','I409',
        'I400','I401','I408','I312','I310','I311','I314','I514')) 
        OR
        (addxg_p in ('105') and  diag1 in
        ('I442','I4430','I440','I441','I4469','I444','I445','I4460','I447','I4510',
        'I450','I4519','I4439','I454','I452','I453','I455','I456','I4581','I459'))
        OR
        (addxg_p in ('106') and  diag1 in
        ('I479','R000','I498','R001','I499','I4949','I493'))
        OR
        (addxg_p in ('108') and  diag1 in 
        ('I0981','I509','I501','I5020','I5021','I5023','I5030','I5031','I5033','I5040','I5041','I5043','I509')) 
        OR
        ( addxg_p in ('100') and  (DIAG1 in ('I2109','I2101','I2102','I2119','I2111','I214','I2129','I213','I2121' )))
        OR
        ( addxg_p in ('149') and diag1 in ('K8000','K8012','K8001','K8013','K8042','K8046','K8043','K8047','K8062','K8063',
        'K8066','K8067','K810','K812','K830','K8030','K8031','K8032','K8033','K8036','K8037')) 
        OR
        ( addxg_p in ('152') and diag1 in ('K859','K850','K851','K852','K853','K858')) 
        then excldx = 1; else excldx = 0;
    end;

    if DVRSND01='9' then do;
        ADDXG_p = PUT(DCGDIAG,$CCS.);
        if ADDXG_p in ('1','2','3','4','5','7','8','9','54','55','60','61','63','76','77','78','82'
        ,'83','84','85','87','89','90','91','92','93', '102','104','107','109','112',
        '116','118','120','122','123','99',
        '124','125','126','127','128','129','130','131','135',
        '137','139','140','142','145','146','148',
        '153','154','157','159','165','168','172','197','198','225','226','227','228','229','230',
        '232','233','234','235','237','238','239','240','241','242','243','244','245','246','247',
        '249','250','251','252','253','259','650','651','652','653','656','658','660','661','662','663','670')
        OR
        ( addxg_p in ('105','106') and  diag1
        in ('4260','42610','42611','42612','42613','4262',
        '4263','4264','42650','42651','42652','42653','42654','4266','4267','42681','42682',
        '4269','4272','7850','42789','4279','42769') )
        OR
        (addxg_p in ('97') and  diag1 in 
        ('03282','03640','03641','03642','03643','07420','07421','07422','07423',
        '11281','11503','11504','11513','11514','11593','11594',
        '1303','3910','3911','3912','3918','3919','3920','3980',
        '39890','39899','4200','42090','42091','42099','4210','4211',
        '4219','4220','42290','42291','42292','42293','42299','4230',
        '4231','4232','4233','4290'))
        OR
        (addxg_p in ('108') and  diag1 in 
        ('39891','4280','4281','42820','42821','42823','42830','42831',
        '42833','42840','42841','42843','4289')) 
        OR
        ( addxg_p in ('100') and  (DIAG1=:'410' AND SUBSTR(DIAG1, 5, 1)^='2'))
        OR
        ( addxg_p in ('149') and diag1 in ('5740','57400','57401','5743','57430','57431',
        '5746','57460','57461','5748','57480','57481','5750','57512','5761')) 
        OR
        ( addxg_p in ('152') and diag1 in ('5770')) 
        then excldx = 1; else excldx = 0;
    end; 

    ARRAY PROCCS(6) $  PROCCCP_1 - PROCCCP_6;
    planned_1 = 0; planned_2=0;

    ****CREATE ALWAYS PLANNED PROCEDURE VARIABLE*******;
    DO I=1 TO 6;
        IF proccs(I) IN 
        ('64','105','176','134','135')THEN do; 
        proc_2  = proccs(I);
        planned_2 = 1; 
        end;
    end;

    ***Determine if Planned Procedure Occurred:  Version 3.0 REVISED SEP 2013
    REMOVE 211 and 224 per valdiation results  ****; 
    DO I=1 TO 6;  
        IF proccs(I) IN 
        ('1','3','5','9','10','12','33','36','38','40','43','44','45','47','48','49',
        '51','52','53','55','56','59','62','66','67','74','78','79','84','85','86','99',
        '104','106','107','109','112','113','114','119','120','124','129',
        '132','142','152','153','154','157','158','159',
        '166','167','169','172','175','170')
        then do;
        procnum  = proccs(I);
        planned_1 = 1; 
        end;
    end;

    **********ADD ICD_10_CM Proc code level Planned Procedures *****;
    ARRAY pproc(6) $   PROC1 -  PROC6;

    DO J=1 TO 6;
        if PVSNCD_(I)='0' then do;
            if  pproc(J) in ('GZB4ZZZ','GZB0ZZZ','GZB1ZZZ','GZB2ZZZ','GZB3ZZZ') then do;
                procnum  = '990';
                planned_1 = 1; 
            end;
            if  pproc(J) in ('0CBS4ZZ','0CBS7ZZ','0CBS8ZZ', '0BW10FZ', '0BW13FZ', '0BW14FZ',
                            '0B5N0ZZ','0B5N3ZZ','0B5N4ZZ','0B5P0ZZ','0B5P3ZZ','0B5P4ZZ') then do;
                procnum  = '991';
                planned_1 = 1; 
            end;
            if  pproc(J) in ('0TC03ZZ','0TC04ZZ','0TC13ZZ','0TC14ZZ','0TC33ZZ','0TC34ZZ','0TC43ZZ','0TC44ZZ','0T9030Z','0T9130Z') then do;
                procnum  = '992';
                planned_1 = 1; 
            end;
        end;
    end;

    DO J=1 TO 6;
        IF PVSNCD_(J)= "9" THEN DO;
            if  pproc(J) in ('9426','9427') then do;
                procnum  = '990';
                planned_1 = 1; 
            end;
            if  pproc(J) in ('304','3174','346','301','3029','303') then do;
                procnum  = '991';
                planned_1 = 1; 
            end;
            if  pproc(J) in ('5503','5504') then do;
                procnum  = '992';
                planned_1 = 1; 
            end;
            if  pproc(J) in ('3818') then do;
                procnum  = '993';
                planned_1 = 1; 
            end;
        end;
    end;

    /*
    if  pproc(J) in ('04CK0ZZ','04CK3ZZ','04CK4ZZ','04CL0ZZ','04CL3ZZ','04CL4ZZ','04CM0ZZ','04CM3ZZ','04CM4ZZ','04CN0ZZ','04CN3ZZ','04CN4ZZ','04CP0ZZ','04CP3ZZ','04CP4ZZ',
                    '04CQ0ZZ','04CQ3ZZ','04CQ4ZZ','04CR0ZZ', '04CR3ZZ','04CR4ZZ','04CS0ZZ','04CS3ZZ','04CS4ZZ','04CT0ZZ','04CT3ZZ','04CT4ZZ','04CU0ZZ','04CU3ZZ','04CU4ZZ',
                    '04CV0ZZ','04CV3ZZ','04CV4ZZ','04CW0ZZ','04CW3ZZ','04CW4ZZ','04CY0ZZ','04CY3ZZ','04CY4ZZ') then do;
    *procnum  = '993';
    planned_1 = 1; 
    */

    planned = 0;

    /*step1: Always Planned Procedures*/
    if planned_2 = 1 then  planned = 1; *procnum = proc_2;

    /*step2: Always Planned Diagnoses*/ ****** Maintenance Chemo Therapy  ******;  /****** Rehabilitation Therapy  ******;*/
    else if ADDXG_p = '45' then planned = 1;  * procnum = '999' ;                        

    else if ADDXG_p = '254' then planned = 1;    *procnum = '998' ;                      

    else if ADDXG_p = '194' then do;
    planned = 1;   procnum = '997' ;                        
    end;
    else if ADDXG_p = '196' then do;
    planned = 1;   procnum = '996' ;                      
    end;

    /*step3: All Other Planned */
    else if planned_1 =1 and excldx = 1 then planned = 0;
    else if planned_1 =1  and excldx = 0 then planned = 1;

run; *51,225,084;

proc sort data=postindex; by hicno case admit; run;

data readm1 QA_DupIndex; 
    merge ALL (IN=A)
        postindex (IN=B KEEP=HICNO ADMIT DISCH PROVID DIAG1 PROCCCP_1 - PROCCCP_6 CASE planned proc1-proc6 DVRSND01
                        RENAME=(DIAG1=_DIAG1 ADMIT=_ADMIT DISCH=_DISCH PROVID=_PROVID proc1=_proc1	proc2=_proc2
                                proc3=_proc3 proc4=_proc4 proc5=_proc5 proc6=_proc6	CASE=CASE_P DVRSND01=_DVRSND01));        
    by HICNO CASE_P;
    IF A;


    IF NOT B THEN RADM30SNFALL=0;
    ELSE IF 0 <= _ADMIT - dschrgdt_snf <=30 THEN RADM30SNFALL=1;
    ELSE IF _ADMIT - dschrgdt_snf > 30 THEN RADM30SNFALL=0;

    INTERVAL=_ADMIT - dschrgdt_snf;
    SAME=(PROVID=_PROVID); /* SAME HOSPITAL READMISSION */
    RADM30SNF=RADM30SNFALL;

    RADM30SNFp=0;
    if planned =1 and RADM30SNF=1 then do;
    RADM30SNF = 0;
    RADM30SNFp = 1;
    end;

    if _DVRSND01='0' then do;
        /* any readmission with principal diagnosis eq V57  is not counted as readmission, added 1/11/2010. ZQ */
        if upcase(_diag1) in ('Z5189')  then Radm_rehab=1;
        else Radm_rehab=0;

        /* any readmission with psych principal diagnosis eq in range of 290-319 that was within 1 day of the discharge date of index admission with discharge dispostion
            eq 65 is not counted as readmission, added 1/11/2010. ZQ */ 

        /*(1) the admission being evaluated as a potential readmission has a psychiatric principal discharge diagnosis code (ICD-9-CM codes beginning with �29�, �30� or �31�, 
                        for discharges prior to October 1, 2015, or ICD-10-CM codes beginning with �F�, for discharges on or after October 1, 2015),  added 05/31/2018. MQ*/
        if _diag1=:'F' and (interval in (0,1))  and
            ddest=65 then Radm_psy=1;
        else Radm_psy=0; 
    end;

    if _DVRSND01='9' then do;
        if upcase(_diag1)=:'V57'  then Radm_rehab=1;
        else Radm_rehab=0;
        if (_diag1=:'29' or _diag1=:'30' or _diag1=:'31') and (interval in (0,1))  and
            ddest=65 then Radm_psy=1;
        else Radm_psy=0;
    end;

    ****** WILL NOT INCLUDE ANY REHAB OR POSSIBLE PSYCH TRANSFERS IN OUR PLANNED READMISSION LOGIC 12/17/12 ****;
    if radm_rehab=1 and (RADM30SNF=1 or RADM30SNFp = 1) then do; RADM30SNF=0; RADM30SNFp = 0; interval = 999;  end;
    if radm_psy=1 and (RADM30SNF=1 or RADM30SNFp = 1) then do; RADM30SNF=0; RADM30SNFp = 0; interval = 999;	end;

    hicno_case=strip(hicno)||strip(case_p);

    * PART OF TRANS BUNDLE, SHOULD HAVE BEEN EXCLUDED - *Updated on 06/19/18;
    If RADM30SNF=1 and interval=0 and same=1 and diag1=_diag1 then do;
    Bundle=1;
    Sample=0;
    end;

    DROP I;

    IF ADMIT=_ADMIT AND DISCH=_DISCH AND PROVID=_PROVID AND DIAG1=_DIAG1 THEN OUTPUT QA_DupIndex; 
    ELSE OUTPUT readm1;

run; *7,354,138;

proc sort data=readm1; by  hicno_case interval _admit; run; 

data readm_in_30_days_after_snf(drop=hicno_case);
    set readm1;
    by  hicno_case interval _admit;
    if first.hicno_case;
    RADM30SNF_Orig=RADM30SNF;
    if INTERVAL=0 & RADM30SNF_Orig=1 then RADM30SNF=.; 
    if INTERVAL=0 & RADM30SNF_Orig=1 then RADM_from_SNF=1; else RADM_from_SNF=0;
    if 1<=INTERVAL<=7 & RADM30SNF_Orig=1 then RADM7SNF=1; else RADM7SNF=0;
    if 1<=INTERVAL<=14 & RADM30SNF_Orig=1 then RADM14SNF=1; else RADM14SNF=0;
    label RADM30SNF = 'Eligible Readmission in 30 Days after SNF Discharge'
        RADM_from_SNF = 'Eligible Readmission Directly from SNF'
        RADM7SNF = 'Eligible Readmission in 7 Days after SNF Discharge'
        RADM14SNF = 'Eligible Readmission in 14 Days after SNF Discharge';
run; *6,280,613;

data temp.merge_all_2010_16_inpatient;
    set  mp.MedPAR2010_16_SNF_unique(keep=bene_id ADMSNDT_SNF rename=(ADMSNDT_SNF=ADMSNDT))
        mp.MedPAR2010_16_IRF_unique(keep=bene_id ADMSNDT_IRF rename=(ADMSNDT_IRF=ADMSNDT))
        mp.other2010_16_unique(keep=bene_id ADMSNDT_other rename=(ADMSNDT_other=ADMSNDT))
        mp.Merged2010_16(keep=bene_id ADMSNDT);
run; *94,679,116;

proc sql;
    create table readm_in_30_days_after_snf_2 as 
    select a.*, b.admsndt as int_admsndt
    from readm_in_30_days_after_snf as a 
    left join temp.merge_all_2010_16_inpatient as b
    on a.hicno=b.bene_id and a.dschrgdt_snf<=admsndt<_admit;
quit; 

data readm_in_30_days_after_snf_3;
    set readm_in_30_days_after_snf_2;
    hicno_case=strip(hicno)||strip(case_p);
run; 

proc sort data=readm_in_30_days_after_snf_3; by  hicno_case interval _admit; run;

data snf.readm_in_30_days_after_snf;
    set readm_in_30_days_after_snf_3;
    by  hicno_case interval _admit;
    if first.hicno_case;

    if int_admsndt^=. then do;
        RADM30SNF=.;
        RADM7SNF=.;
        RADM14SNF=.;
    end;
run; *6,280,613;

*Merge in 90-day payment variables;
proc sql;
    create table snf_los_county_ma_1016_new_pmt as
        select distinct main.*, payment.BENE_ID as merge_flag, payment.Pmt_After_Hosp_90_sum,
                                payment.Pmt_After_Hosp_90_sum_SNF, payment.Pmt_After_Hosp_90_sum_IRF, payment.Pmt_After_Hosp_90_sum_HHA, 
                                payment.Pmt_After_Hosp_90_sum_Other, payment.Pmt_After_Hosp_90_sum_Acute
        from snf.snf_los_county_ma_1016_new as main
        left join temp.merge_all_2010_16_90_pmt_3 as payment
        on main.BENE_ID=payment.BENE_ID and main.ADMSNDT=payment.ADMSNDT and main.DSCHRGDT=payment.DSCHRGDT;
quit; *8,567,174;

proc sql; create table check_merge as select * from snf_los_county_ma_1016_new_pmt where merge_flag=""; quit; *205;

data snf.snf_los_county_ma_1016_new_2(drop=merge_flag PMT_AMT);
    set snf_los_county_ma_1016_new_pmt;

    PMT_AMT_PSEUDO=PMT_AMT;
    if PMT_AMT<0 then PMT_AMT_PSEUDO=0;
    Hosp_Pmt_90=PMT_AMT_PSEUDO;
                                                                                        
    if Pmt_After_Hosp_90_sum<0 then Pmt_After_Hosp_90_sum=0;
    if Pmt_After_Hosp_90_sum_SNF<0 then Pmt_After_Hosp_90_sum_SNF=0;
    if Pmt_After_Hosp_90_sum_IRF<0 then Pmt_After_Hosp_90_sum_IRF=0;
    if Pmt_After_Hosp_90_sum_HHA<0 then Pmt_After_Hosp_90_sum_HHA=0;
    if Pmt_After_Hosp_90_sum_OTHER<0 then Pmt_After_Hosp_90_sum_OTHER=0;
    if Pmt_After_Hosp_90_sum_Acute<0 then Pmt_After_Hosp_90_sum_Acute=0;

    Total_Pmt_90=Hosp_Pmt_90+Pmt_After_Hosp_90_sum;

    label Total_Pmt_90 = 'Payment amount to hospital stay and all providers within 90 days of hospital discharge' 
        Hosp_Pmt_90 = 'Payment amount to hospital'
        Pmt_After_Hosp_90_sum_SNF = 'Payment amount to SNF within 90 days of hospital discharge' 
        Pmt_After_Hosp_90_sum_IRF = 'Payment amount to IRF within 90 days of hospital discharge'  
        Pmt_After_Hosp_90_sum_HHA = 'Payment amount to HHA within 90 days of hospital discharge' 
        Pmt_After_Hosp_90_sum_OTHER = 'Payment amount to other providers within 90 days of hospital discharge'
        Pmt_After_Hosp_90_sum_Acute = 'Payment amount to acute care hospital within 90 days of hospital discharge';
run; *8,567,174;

*Merge in 30-day readmission indicator and comorbidity variables;
proc sql;
    create table snf_los_county_ma_1016_new_readm as
    select all.*, readm.*
    from snf.snf_los_county_ma_1016_new_2 as all
    left join Pac.readm2010_2016(keep=radm30 HICNO ADMIT DISCH hxinfection--hipfracture) as readm
    on all.BENE_ID=readm.HICNO and all.ADMSNDT>=readm.ADMIT and all.DSCHRGDT<=readm.DISCH;
quit; *8,567,301;

proc sort data=snf_los_county_ma_1016_new_readm nodupkey; by medpar_id_snf; run; 
*8,567,174;

proc sql;
    create table check_readm_matched as 
    select HICNO from snf_los_county_ma_1016_new_readm
    where not missing(HICNO);
quit; *8,310,691 (97.0%) matched;

data snf.snf_los_county_ma_1016_new_3;
    set snf_los_county_ma_1016_new_readm (drop=HICNO ADMIT DISCH);
    SOI=sum(of hxinfection--HipFracture);
    label SOI="Severity of Illness";
run; *8,567,174;

*Merge in 90-day readmission indicator;
proc sql;
    create table readmission_in_90days as
    select all.*, readm.*
    from snf.snf_los_county_ma_1016_new_3 as all
    left join snf.readmission_in_90_days(keep=radm90 HICNO ADMIT DISCH _admit) as readm
    on all.BENE_ID=readm.HICNO and all.ADMSNDT>=readm.ADMIT and all.DSCHRGDT<=readm.DISCH;
quit; *8,567,292;

proc sort data=readmission_in_90days nodupkey; by medpar_id_snf; run; *8,567,174;

proc sql;
    create table check_readm_matched as 
    select HICNO from readmission_in_90days
    where not missing(HICNO);
quit; *8,310,692 (97.0%) matched;

data snf.snf_los_county_ma_1016_new_4(drop=hicno HICNO ADMIT DISCH);
    set readmission_in_90days;
    if radm30=. then radm90=.;
    rename _admit=readmission_date_in_90_days;
run; *8,567,174;

*Merge in readmission after SNF indicators: 1)readmission directly from SNF, 2)readmission in 7 days after SNF discharge, 
 3)readmission in 30 days after SNF discharge, and 4)readmission in 90 days after SNF discharge;
proc sql;
    create table readm_after_snf as
    select all.*, readm.*
    from snf.snf_los_county_ma_1016_new_4 as all
    left join snf.readm_in_90_days_after_snf(keep=RADM90SNF RADM30SNF RADM14SNF RADM7SNF RADM_from_SNF HICNO ADMIT DISCH _admit) as readm
    on all.BENE_ID=readm.HICNO and all.ADMSNDT>=readm.ADMIT and all.DSCHRGDT<=readm.DISCH;
quit; *8,567,292;

proc sort data=readm_after_snf nodupkey; by medpar_id_snf; run; *8,567,174;

proc sql;
    create table check_readm_matched as 
    select HICNO from readm_after_snf
    where not missing(HICNO);
quit; *8,310,692 (97.0%) matched;

data snf.snf_los_county_ma_1016_new_5(drop=hicno HICNO ADMIT DISCH);
    set readm_after_snf(rename=(_admit=readmission_date_after_SNF));
    if radm30=. then do;
        RADM90SNF=.;
        RADM30SNF=.;
        RADM14SNF=.;
        RADM7SNF=.;
        RADM_from_SNF=.;
    end;
    /*if _admit^=. & _admit=dschrgdt_snf then delete; *drop records of patients who discharged from SNF to hospital;*/
    label readmission_date_after_SNF="Date of Readmission to Hospital after SNF Discharge";
run; *8,567,174;



/**********************************************************************************************************************************************************
Step 11: Create 30-day after SNF discharge payment for readmission and PAC
**********************************************************************************************************************************************************/

data merge_all_2010_16_all_trans;
	set temp.merge_all_2010_16_all_trans(keep = BENE_ID ADMSNDT_SNF DSCHRGDT_SNF_pseudo SNF_UTIL_DAY PMT_AMT_SNF SNF_PRVDRNUM ADMSNDT_IRF
	DSCHRGDT_IRF PMT_AMT_IRF IRF_PRVDRNUM ADMSNDT_HHA DSCHRGDT_HHA PMT_AMT_HHA HHA_PRVDRNUM ADMSNDT_other DSCHRGDT_other
	other_PRVDRNUM PMT_AMT_other ADMSNDT_ACUTE DSCHRGDT_ACUTE PMT_AMT_ACUTE PMT_AMT_ACUTE);
run; *109,292,388;

proc sql;
    create table merge_all_2010_16_trans as
        select distinct main.BENE_ID, main.medpar_id_snf, main.dschrgdt_snf, post.*
        from snf.snf_los_county_ma_1016_new_5 as main
        left join merge_all_2010_16_all_trans as post 
        on main.BENE_ID=post.BENE_ID;
quit; *88,969,938;

data pmt_30_after_snf;
    set merge_all_2010_16_trans;
    if 0 le ADMSNDT_SNF-dschrgdt_snf le 29 then gap_1=ADMSNDT_SNF-dschrgdt_snf; else gap_1=.;
    if 0 le ADMSNDT_IRF-dschrgdt_snf le 29 then gap_2=ADMSNDT_IRF-dschrgdt_snf; else gap_2=.;
    if 0 le ADMSNDT_HHA-dschrgdt_snf le 29 then gap_3=ADMSNDT_HHA-dschrgdt_snf; else gap_3=.;
    if 0 le ADMSNDT_OTHER-dschrgdt_snf le 29 then gap_4=ADMSNDT_OTHER-dschrgdt_snf; else gap_4=.;
    if 0 le ADMSNDT_ACUTE-dschrgdt_snf le 29 then gap_5=ADMSNDT_ACUTE-dschrgdt_snf; else gap_5=.;
    if gap_1=. & gap_2=. & gap_3=. & gap_4=. & gap_5=. then delete;
    PMT_AMT_30_AFTER=min(PMT_AMT_SNF, PMT_AMT_IRF, PMT_AMT_HHA, PMT_AMT_other, PMT_AMT_ACUTE);
    DSCHRGDT_30_AFTER=min(DSCHRGDT_SNF_pseudo, DSCHRGDT_IRF, DSCHRGDT_HHA, DSCHRGDT_other, DSCHRGDT_ACUTE);
    ADMSNDT_30_AFTER=min(ADMSNDT_SNF, ADMSNDT_IRF, ADMSNDT_HHA, ADMSNDT_other, ADMSNDT_ACUTE);
run; *5,763,903;

proc sort data=pmt_30_after_snf; by BENE_ID dschrgdt_snf; run; 

*Calculate each of pac and hospital payments within 30 days after SNF discharge;
data pmt_30_after_snf_2;
    set pmt_30_after_snf;
    if DSCHRGDT_30_AFTER >= dschrgdt_snf+29 then do;
        if gap_1^=. then do;
            if SNF_UTIL_DAY^=0 then Pmt_After_SNF_30=PMT_AMT_30_AFTER/SNF_UTIL_DAY*(dschrgdt_snf+29-ADMSNDT_30_AFTER+1);
            else Pmt_After_SNF_30=PMT_AMT_30_AFTER/(DSCHRGDT_30_AFTER-ADMSNDT_30_AFTER+1)*(dschrgdt_snf+29-ADMSNDT_30_AFTER+1);
        end;
        else Pmt_After_SNF_30=PMT_AMT_30_AFTER/(DSCHRGDT_30_AFTER-ADMSNDT_30_AFTER+1)*(dschrgdt_snf+29-ADMSNDT_30_AFTER+1);
    end;
    if DSCHRGDT_30_AFTER < dschrgdt_snf+29 then Pmt_After_SNF_30=PMT_AMT_30_AFTER;
    if Pmt_After_SNF_30 < 0 then Pmt_After_SNF_30 = 0;

    if gap_1^=. then Pmt_After_SNF_30_SNF=Pmt_After_SNF_30;
    else if gap_2^=. then Pmt_After_SNF_30_IRF=Pmt_After_SNF_30;
    else if gap_3^=. then Pmt_After_SNF_30_HHA=Pmt_After_SNF_30;
    else if gap_4^=. then Pmt_After_SNF_30_Other=Pmt_After_SNF_30;
    else if gap_5^=. then Pmt_After_SNF_30_ACUTE=Pmt_After_SNF_30;
run; *5,763,903;

*Calculate the sum of pac and hospital payments for each record;
proc sql;
    create table pmt_30_after_snf_3 as
        select BENE_ID, medpar_id_snf, SUM(Pmt_After_SNF_30) as Pmt_After_SNF_30_sum, 
            SUM(Pmt_After_SNF_30_SNF) as Pmt_After_SNF_30_Sum_SNF, SUM(Pmt_After_SNF_30_IRF) as Pmt_After_SNF_30_Sum_IRF, SUM(Pmt_After_SNF_30_HHA) as Pmt_After_SNF_30_Sum_HHA,
            SUM(Pmt_After_SNF_30_Other) as Pmt_After_SNF_30_Sum_Other, SUM(Pmt_After_SNF_30_ACUTE) as Pmt_After_SNF_30_Sum_ACUTE
        from pmt_30_after_snf_2
        group by medpar_id_snf;
quit; *5,763,903;

proc sort data=pmt_30_after_snf_3 NODUP; by medpar_id_snf; run; *3,750,603;

*Merge into the original dataset;
proc sql;
    create table pmt_30_after_snf_4 as
        select distinct main.*, payment.Pmt_After_SNF_30_sum,
                                payment.Pmt_After_SNF_30_sum_SNF, payment.Pmt_After_SNF_30_sum_IRF, payment.Pmt_After_SNF_30_sum_HHA, 
                                payment.Pmt_After_SNF_30_sum_Other, payment.Pmt_After_SNF_30_sum_Acute
        from snf.snf_los_county_ma_1016_new_5 as main
        left join pmt_30_after_snf_3 as payment
        on main.medpar_id_snf=payment.medpar_id_snf;
quit; *8,567,174;

data snf.snf_los_county_ma_1016_new_6;
    set pmt_30_after_snf_4;
    if Pmt_After_SNF_30_sum=. then Pmt_After_SNF_30_sum=0;
    if Pmt_After_SNF_30_sum_SNF=. then Pmt_After_SNF_30_sum_SNF=0;
    if Pmt_After_SNF_30_sum_IRF=. then Pmt_After_SNF_30_sum_IRF=0;
    if Pmt_After_SNF_30_sum_HHA=. then Pmt_After_SNF_30_sum_HHA=0;
    if Pmt_After_SNF_30_sum_Other=. then Pmt_After_SNF_30_sum_Other=0;
    if Pmt_After_SNF_30_sum_Acute=. then Pmt_After_SNF_30_sum_Acute=0;
    Pmt_After_SNF_30_PAC=sum(Pmt_After_SNF_30_sum_SNF, Pmt_After_SNF_30_sum_IRF, Pmt_After_SNF_30_sum_HHA, Pmt_After_SNF_30_sum_Other);
    label Pmt_After_SNF_30_sum_SNF = 'Payment amount to SNF within 30 days of SNF discharge' 
        Pmt_After_SNF_30_sum_IRF = 'Payment amount to IRF within 30 days of SNF discharge'  
        Pmt_After_SNF_30_sum_HHA = 'Payment amount to HHA within 30 days of SNF discharge' 
        Pmt_After_SNF_30_sum_OTHER = 'Payment amount to other providers within 30 days of SNF discharge'
        Pmt_After_SNF_30_sum_Acute = 'Payment amount to acute care hospital within 30 days of SNF discharge'
        Pmt_After_SNF_30_PAC = 'Payment amount to all post-acute care providers within 30 days of SNF discharge';
run; *8,567,174;

proc means data=snf.snf_los_county_ma_1016_new_6 nolabels n mean median min max maxdec=2;
    var Pmt_After_SNF_30_sum Pmt_After_SNF_30_PAC Pmt_After_SNF_30_sum_Acute;
run;



/**********************************************************************************************************************************************************
Step 12: Merge in RUG codes from MDS data set
**********************************************************************************************************************************************************/

data mds2010(drop=target_date);
    set pac_mds.mds2_2010_beneid(keep=bene_id mcr_gp target_date);
    MDS_TRGT_DT=input(target_date,yymmdd8.);
    format MDS_TRGT_DT date9.;
    rename mcr_gp=c_mdcr_rug4_hirchcl_grp_txt;
    where mcr_gp^="" & bene_id^="";
run; *4,589,267;

data tempn.mds_2010_2016_RUG4;
    set pac_mds.mds3_beneid_2010_16(keep=bene_id c_mdcr_rug4_hirchcl_grp_txt MDS_TRGT_DT)
        mds2010;
    where c_mdcr_rug4_hirchcl_grp_txt^="" & bene_id^="" & MDS_TRGT_DT^=.;
    MDS_TRGT_Yr=year(MDS_TRGT_DT);
run; *77,771,862;

proc sql;
    create table Rug  as 
    select a.*, b.c_mdcr_rug4_hirchcl_grp_txt as rug4, b.MDS_TRGT_DT   
    from snf.snf_los_county_ma_1016_new_6 as a 
    left join tempn.mds_2010_2016_RUG4 as b
    on a.bene_id=b.bene_id and a.admsndt_snf<=b.MDS_TRGT_DT<=a.dschrgdt_snf;
quit; *18,594,648;

proc sort data=Rug; by medpar_id_snf MDS_TRGT_DT; run;

data Rug_2 (drop=MDS_TRGT_DT);
    set Rug;
    by medpar_id_snf MDS_TRGT_DT;
    if first.medpar_id_snf;
run; *8,567,174;

proc sql; create table check_merge as select bene_id, dschrg_year, dschrg_month from Rug_2 where rug4=""; quit; *182,467 missing;

proc freq data=check_merge;
    table dschrg_year;
run;

*Replace missing RUG4 value with the most common RUG4 code by DRG;
proc sql;
    create table im_rug as
    select drg_cd, rug4, count(rug4) as rug4_count  
    from Rug_2
    group by drg_cd, rug4;
quit; *35,896;

proc sort data=im_rug; by drg_cd descending rug4_count; run;

data im_rug_2;
    set im_rug;
    by drg_cd descending rug4_count;
    if first.drg_cd;
    where rug4^="";
run; *738;

proc sql;
    create table Rug_3 as 
    select a.*, b.rug4 as rug4_im 
    from Rug_2 as a 
    left join im_rug_2 as b
    on a.drg_cd=b.drg_cd and a.rug4="";
quit; *8,567,174;

*Create major RUG group based on RUG code;
data snf.snf_los_county_ma_1016_new_7;
set Rug_3;

    if rug4^="" then rug4_im=rug4;

    if rug4 in ("RUX", "RUL", "RVX", "RVL", "RHX", "RHL", "RMX", "RML", "RLX") then mjr_rug_grp="Rehab Plus Extensive";
    else if rug4 in ("RUC", "RUB", "RUA", "RVC", "RVB", "RVA", "RHC", "RHB", "RHA", "RMC", "RMB", "RMA", "RLB", "RLA") then mjr_rug_grp="Rehab";  
    else if rug4 in ("ES3", "ES2", "ES1") then mjr_rug_grp="Extensive Services";
    else if rug4 in ("HE2", "HD2", "HC2", "HB2", "HE1", "HD1", "HC1", "HB1") then mjr_rug_grp="Special Care High";
    else if rug4 in ("LE2", "LD2", "LC2", "LB2", "LE1", "LD1", "LC1", "LB1") then mjr_rug_grp="Special Care Low";
    else if rug4 in ("CE2", "CD2", "CC2", "CB2", "CA2", "CE1", "CD1", "CC1", "CB1", "CA1") then mjr_rug_grp="Clinically Complex";
    else if rug4 in ("BB2", "BA2", "BB1", "BA1") then mjr_rug_grp="Behavioral Symptoms and Cognitive Performance";
    else if rug4 in ("PE2", "PD2", "PC2", "PB2", "PA2", "PE1", "PD1", "PC1", "PB1", "PA1") then mjr_rug_grp="Reduced Physical Functioning";

    if rug4_im in ("RUX", "RUL", "RVX", "RVL", "RHX", "RHL", "RMX", "RML", "RLX") then mjr_rug_grp_im="Rehab Plus Extensive";
    else if rug4_im in ("RUC", "RUB", "RUA", "RVC", "RVB", "RVA", "RHC", "RHB", "RHA", "RMC", "RMB", "RMA", "RLB", "RLA") then mjr_rug_grp_im="Rehab";  
    else if rug4_im in ("ES3", "ES2", "ES1") then mjr_rug_grp_im="Extensive Services";
    else if rug4_im in ("HE2", "HD2", "HC2", "HB2", "HE1", "HD1", "HC1", "HB1") then mjr_rug_grp_im="Special Care High";
    else if rug4_im in ("LE2", "LD2", "LC2", "LB2", "LE1", "LD1", "LC1", "LB1") then mjr_rug_grp_im="Special Care Low";
    else if rug4_im in ("CE2", "CD2", "CC2", "CB2", "CA2", "CE1", "CD1", "CC1", "CB1", "CA1") then mjr_rug_grp_im="Clinically Complex";
    else if rug4_im in ("BB2", "BA2", "BB1", "BA1") then mjr_rug_grp_im="Behavioral Symptoms and Cognitive Performance";
    else if rug4_im in ("PE2", "PD2", "PC2", "PB2", "PA2", "PE1", "PD1", "PC1", "PB1", "PA1") then mjr_rug_grp_im="Reduced Physical Functioning";

    label rug4_im="Imputed RUG" mjr_rug_grp="Major RUG Group" mjr_rug_grp_im="Imputed Major RUG Group"; 
run; *8,567,174;

proc sql; create table check_merge_1 as select bene_id from snf.snf_los_county_ma_1016_new_7 where rug4=""; quit; *182,467;
proc sql; create table check_merge_2 as select bene_id from snf.snf_los_county_ma_1016_new_7 where mjr_rug_grp=""; quit; *227,648;
proc sql; create table check_merge_3 as select bene_id from snf.snf_los_county_ma_1016_new_7 where rug4_im=""; quit; *0;
proc sql; create table check_merge_4 as select bene_id from snf.snf_los_county_ma_1016_new_7 where mjr_rug_grp_im=""; quit; *45,181;



/**********************************************************************************************************************************************************
Step 13: Merge in variables from ACS data based on zip code: use 2010-2014 through 2014 and the switch to 2012-2016
**********************************************************************************************************************************************************/

proc sql;
    create table snf_los_county_ma_1016_new_zcta as 
    select a.*, b.zcta as bene_zcta
    from snf.snf_los_county_ma_1016_new_7 as a 
    left join snf_bpt.zip_zcta_cw as b 
    on a.bene_zip=b.ZIP_CODE;
quit; *8,567,174;

proc sql; create table check_merge as select bene_id from snf_los_county_ma_1016_new_zcta where bene_zcta=""; quit;	*1,620;

proc sql;
    create table temp_1 as 
    select a.*, b.med_hoshd_inc, b.unemplmt_rate, b.povty_rate
    from snf_los_county_ma_1016_new_zcta as a 
    left join snf_bpt.acs_1014 as b 
    on a.bene_zcta=b.ZCTA5
    where 2010<=dschrg_year<=2014;
quit; *6,346,931;

proc sql; create table check_merge as select bene_id from temp_1 where med_hoshd_inc=. | unemplmt_rate=. | povty_rate=.; quit; *8,939 (0.14%) missing;

proc sql;
    create table temp_2 as 
    select a.*, b.med_hoshd_inc, b.unemplmt_rate, b.povty_rate
    from snf_los_county_ma_1016_new_zcta as a 
    left join snf_bpt.acs_1216 as b 
    on a.bene_zcta=b.ZCTA5
    where 2015<=dschrg_year<=2016;
quit; *2,220,243;

proc sql; create table check_merge as select bene_id from temp_2 where med_hoshd_inc=. | unemplmt_rate=. | povty_rate=.; quit; *5,057 (0.22%) missing;

data snf.snf_los_county_ma_1016_new_8;
    set temp_1 temp_2;
run; *8,567,174;



/**********************************************************************************************************************************************************
Step 13: Create a new variable for total Medicare spending in the prior year
**********************************************************************************************************************************************************/

data MedPAR2009_16_Pmt;
    set Medpar.Mp100mod_2009(keep=BENE_ID DSCHRGDT ADMSNDT PMT_AMT UTIL_DAY)
        Medpar.Mp100mod_2010(keep=BENE_ID DSCHRGDT ADMSNDT PMT_AMT UTIL_DAY)
        Medpar.Mp100mod_2011(keep=BENE_ID DSCHRGDT ADMSNDT PMT_AMT UTIL_DAY) 
        Medpar.Mp100mod_2012(keep=BENE_ID DSCHRGDT ADMSNDT PMT_AMT UTIL_DAY) 
        Medpar.Mp100mod_2013(keep=BENE_ID DSCHRGDT ADMSNDT PMT_AMT UTIL_DAY) 
        Medpar.Mp100mod_2014(keep=BENE_ID DSCHRGDT ADMSNDT PMT_AMT UTIL_DAY) 
        Medpar.Mp100mod_2015(keep=BENE_ID DSCHRGDT ADMSNDT PMT_AMT UTIL_DAY) 
        Medpar.Mp100mod_2016(keep=BENE_ID DSCHRGDT ADMSNDT PMT_AMT UTIL_DAY);
    if DSCHRGDT=. then DSCHRGDT_pseudo=ADMSNDT+UTIL_DAY;
    else DSCHRGDT_pseudo=dschrgdt;
    label DSCHRGDT_pseudo="Pseudo Discharge Date";
run; *138,902,871;

data tempn.MedPAR2009_16_Pmt;
    set MedPAR2009_16_Pmt(keep=BENE_ID ADMSNDT DSCHRGDT_pseudo PMT_AMT);
    if PMT_AMT<0 then PMT_AMT_pseudo=0;
    else PMT_AMT_pseudo=PMT_AMT;
    where PMT_AMT^=.;
    label PMT_AMT_pseudo="Pseudo Medicare Payment Amount";
run; *138,902,871;

proc sql;
    create table snf_los_county_ma_1016_new_Pmt as 
    select a.medpar_id_snf, b.PMT_AMT_pseudo
    from snf.snf_los_county_ma_1016_new_8 as a 
    left join tempn.MedPAR2009_16_Pmt as b
    on a.bene_id=b.bene_id and b.DSCHRGDT_pseudo<=a.admsndt<b.admsndt+365;
quit; *20,052,176;

proc sql;
    create table snf_los_county_ma_1016_new_Pmt2 as 
    select distinct medpar_id_snf, sum(PMT_AMT_pseudo) as Prior_Pmt_Sum label="Total Medicare Spending in the Prior Year"
    from snf_los_county_ma_1016_new_Pmt
    group by medpar_id_snf;
quit; *8,567,174;

proc sql;
    create table snf_los_county_ma_1016_new_Pmt3 as 
    select a.*, b.Prior_Pmt_Sum
    from snf.snf_los_county_ma_1016_new_8 as a  
    left join snf_los_county_ma_1016_new_Pmt2 as b
    on a.medpar_id_snf=b.medpar_id_snf;
quit; *8,567,174;

data snf.snf_los_county_ma_1016_new_9(drop=Prior_Pmt_Sum);
    set snf_los_county_ma_1016_new_Pmt3;
    if Prior_Pmt_Sum=. then Prior_Pmt_Amt_Sum=0;
    else Prior_Pmt_Amt_Sum=Prior_Pmt_Sum;
    if Prior_Pmt_Sum=. or Prior_Pmt_Sum=0 then Any_Prior_Pmt=0; else Any_Prior_Pmt=1;
    label Any_Prior_Pmt="Any Medicare Spending in the Prior Year" Prior_Pmt_Amt_Sum="Total Medicare Spending in the Prior Year";
run; *8,567,174;

proc means data=snf.snf_los_county_ma_1016_new_9 nolabels nonobs n nmiss mean median min max maxdec=2;
    var Prior_Pmt_Amt_Sum;
run;



/**********************************************************************************************************************************************************
Step 14: Drop record without matched MDS entry record
**********************************************************************************************************************************************************/

*Drop records without matched MDS record;
proc sql;
    create table snf_los_county_ma_1016_new_mds as 
    select a.*, b.MDS_ENTRY_DT 
    from snf.snf_los_county_ma_1016_new_9 as a 
    left join tempn.mds_2010_16_admsn_dschrg as b
    on a.bene_id=b.bene_id and 0 le b.MDS_ENTRY_DT-a.admsndt_snf le 3;
quit; *8,721,589;

proc sort data=snf_los_county_ma_1016_new_mds nodupkey; by medpar_id_snf; run; 
*8,567,174;

data snf_los_county_ma_1016_new_mds_2;
    set snf_los_county_ma_1016_new_mds;
    if MDS_ENTRY_DT^=. then MDS_record=1;
    else MDS_record=0;
run; *8,567,174;

proc freq data=snf_los_county_ma_1016_new_mds_2;
    table MDS_record;
run;

data snf.snf_los_county_ma_1016_new_10(drop=MDS_ENTRY_DT MDS_record);
    set snf_los_county_ma_1016_new_mds_2;
    where MDS_record=1;
run; *8,338,123 (97.25%);



/**********************************************************************************************************************************************************
Step 15: Merge in marital status code from MDS data set
**********************************************************************************************************************************************************/

data mds2_2010_beneid(rename=(A5_MARTIAL_STATUS=A1200_MRTL_STUS_CD));
    set pac_mds.mds2_2010_beneid (keep=bene_id TARGET_Date A5_MARTIAL_STATUS);
    MDS_TRGT_DT=input(TARGET_DATE,yymmdd8.);
    format MDS_TRGT_DT date9.;
    where A5_MARTIAL_STATUS^="" & bene_id^="";
    drop TARGET_DATE;
run; *6,507,379;

proc freq data=mds2_2010_beneid;
    table A1200_MRTL_STUS_CD;
run;

data mds3_1016_beneid;
    set pac_mds.mds3_beneid_2010_16(keep=bene_id MDS_TRGT_DT A1200_MRTL_STUS_CD);
    where bene_id^="" and A1200_MRTL_STUS_CD^="";
run; *123,075,813;

data mds_marital_1016;
    set mds2_2010_beneid mds3_1016_beneid;
run; *129,583,192;

***Merge in marital status code from MDS data;
proc sql;
    create table snf_los_county_ma_1016_marital as 
    select a.*, b.A1200_MRTL_STUS_CD   
    from snf.snf_los_county_ma_1016_new_10 as a 
    left join mds_marital_1016 as b
    on a.bene_id=b.bene_id and a.admsndt_snf<=b.MDS_TRGT_DT<=a.dschrgdt_snf;
quit; *32,041,165;

proc sort data=snf_los_county_ma_1016_marital; by medpar_id_snf descending A1200_MRTL_STUS_CD; run; 

data snf_los_county_ma_1016_marital_2; 
    set snf_los_county_ma_1016_marital; 
    by medpar_id_snf descending A1200_MRTL_STUS_CD; 
    if first.medpar_id_snf; 
run; *8,338,123;

proc sql; create table check_merge as select bene_id from snf_los_county_ma_1016_marital_2 where A1200_MRTL_STUS_CD in("" , "-"); quit; 
*149,102 (1.8%) missing because failing to merge;

*Impute missing marital status code by same race and sex group;
proc sql;
    create table im_marital as 
    select race_num, sex_num, A1200_MRTL_STUS_CD, count(A1200_MRTL_STUS_CD) as A1200_MRTL_STUS_CD_CT 
    from snf_los_county_ma_1016_marital_2
    where A1200_MRTL_STUS_CD not in ("", "-")
    group by race_num, sex_num, A1200_MRTL_STUS_CD;
quit; *70;

proc sort data=im_marital; by race_num sex_num descending A1200_MRTL_STUS_CD_CT; run;

data im_marital_2;
    set im_marital;
    by race_num sex_num descending A1200_MRTL_STUS_CD_CT;;
    if first.sex_num;
run; *14;

proc sql;
    create table snf_los_county_ma_1016_marital_3 as 
    select a.*, b.A1200_MRTL_STUS_CD as A1200_MRTL_STUS_CD_im label="Imputed Marital Status Code"
    from snf_los_county_ma_1016_marital_2 as a 
    left join im_marital_2 as b
    on a.race_num=b.race_num and a.sex_num=b.sex_num and a.A1200_MRTL_STUS_CD in ("", "-");
quit; *8,338,123;

data snf.snf_los_county_ma_1016_new_11;
    set snf_los_county_ma_1016_marital_3;

    if A1200_MRTL_STUS_CD not in ("", "-") then A1200_MRTL_STUS_CD_IM=A1200_MRTL_STUS_CD;

    *Combine multiple marital status into married or not;
    if A1200_MRTL_STUS_CD="2" then married=1; 
    else if A1200_MRTL_STUS_CD in ("1", "3", "4", "5") then married=0;

    if A1200_MRTL_STUS_CD_IM="2" then married_im=1; 
    else if A1200_MRTL_STUS_CD_IM in ("1", "3", "4", "5") then married_im=0;

    label married="Married" married="Married (Imputed)";
run; *8,338,123;



/**********************************************************************************************************************************************************
Step 16: Create successful discharge to community indicator
**********************************************************************************************************************************************************/

data snf.snf_los_county_ma_1016_new_12;
set snf.snf_los_county_ma_1016_new_11;
if 1<=util_day_snf<=100 & DeathIn30Days_SNF=0 & radm30snf=0 & radm30snf_to_snf=0 then successful_discharge=1;
else successful_discharge=0;
label successful_discharge="Successful Discharge to Community";
run; *8,338,123;

proc freq data=snf.snf_los_county_ma_1016_new_12;
table successful_discharge;
run;



/**********************************************************************************************************************************************************
Step 17: Create 90-day after SNF discharge payment for readmission and PAC
**********************************************************************************************************************************************************/

data merge_all_2010_16_all_trans;
	set temp.merge_all_2010_16_all_trans(keep = BENE_ID ADMSNDT_SNF DSCHRGDT_SNF_pseudo SNF_UTIL_DAY PMT_AMT_SNF SNF_PRVDRNUM ADMSNDT_IRF
	DSCHRGDT_IRF PMT_AMT_IRF IRF_PRVDRNUM ADMSNDT_HHA DSCHRGDT_HHA PMT_AMT_HHA HHA_PRVDRNUM ADMSNDT_other DSCHRGDT_other
	other_PRVDRNUM PMT_AMT_other ADMSNDT_ACUTE DSCHRGDT_ACUTE PMT_AMT_ACUTE PMT_AMT_ACUTE);
run; *109,292,388;

proc sql;
    create table merge_all_2010_16_trans as
	select distinct main.BENE_ID, main.medpar_id_snf, main.dschrgdt_snf, post.*
	from snf.snf_los_county_ma_1016_new_12 as main
	left join merge_all_2010_16_all_trans as post 
    on main.BENE_ID=post.BENE_ID;
quit; *86,940,625;

data pmt_90_after_snf;
    set merge_all_2010_16_trans;
    if 0 le ADMSNDT_SNF-dschrgdt_snf le 89 then gap_1=ADMSNDT_SNF-dschrgdt_snf; else gap_1=.;
    if 0 le ADMSNDT_IRF-dschrgdt_snf le 89 then gap_2=ADMSNDT_IRF-dschrgdt_snf; else gap_2=.;
    if 0 le ADMSNDT_HHA-dschrgdt_snf le 89 then gap_3=ADMSNDT_HHA-dschrgdt_snf; else gap_3=.;
    if 0 le ADMSNDT_OTHER-dschrgdt_snf le 89 then gap_4=ADMSNDT_OTHER-dschrgdt_snf; else gap_4=.;
    if 0 le ADMSNDT_ACUTE-dschrgdt_snf le 89 then gap_5=ADMSNDT_ACUTE-dschrgdt_snf; else gap_5=.;
    if gap_1=. & gap_2=. & gap_3=. & gap_4=. & gap_5=. then delete;
    PMT_AMT_90_AFTER=min(PMT_AMT_SNF, PMT_AMT_IRF, PMT_AMT_HHA, PMT_AMT_other, PMT_AMT_ACUTE);
    DSCHRGDT_90_AFTER=min(DSCHRGDT_SNF_pseudo, DSCHRGDT_IRF, DSCHRGDT_HHA, DSCHRGDT_other, DSCHRGDT_ACUTE);
    ADMSNDT_90_AFTER=min(ADMSNDT_SNF, ADMSNDT_IRF, ADMSNDT_HHA, ADMSNDT_other, ADMSNDT_ACUTE);
run; *9,427,153;

proc sort data=pmt_90_after_snf; by BENE_ID dschrgdt_snf; run; 

*Calculate each of pac and hospital payments within 90 days after SNF discharge;
data pmt_90_after_snf_2;
    set pmt_90_after_snf;
    if DSCHRGDT_90_AFTER >= dschrgdt_snf+89 then do;
        if gap_1^=. then do;
            if SNF_UTIL_DAY^=0 then Pmt_After_SNF_90=PMT_AMT_90_AFTER/SNF_UTIL_DAY*(dschrgdt_snf+89-ADMSNDT_90_AFTER+1);
            else Pmt_After_SNF_90=PMT_AMT_90_AFTER/(DSCHRGDT_90_AFTER-ADMSNDT_90_AFTER+1)*(dschrgdt_snf+89-ADMSNDT_90_AFTER+1);
        end;
        else Pmt_After_SNF_90=PMT_AMT_90_AFTER/(DSCHRGDT_90_AFTER-ADMSNDT_90_AFTER+1)*(dschrgdt_snf+89-ADMSNDT_90_AFTER+1);
    end;
    if DSCHRGDT_90_AFTER < dschrgdt_snf+89 then Pmt_After_SNF_90=PMT_AMT_90_AFTER;
    if Pmt_After_SNF_90 < 0 then Pmt_After_SNF_90 = 0;

    if gap_1^=. then Pmt_After_SNF_90_SNF=Pmt_After_SNF_90;
    else if gap_2^=. then Pmt_After_SNF_90_IRF=Pmt_After_SNF_90;
    else if gap_3^=. then Pmt_After_SNF_90_HHA=Pmt_After_SNF_90;
    else if gap_4^=. then Pmt_After_SNF_90_Other=Pmt_After_SNF_90;
    else if gap_5^=. then Pmt_After_SNF_90_ACUTE=Pmt_After_SNF_90;
run; *9,427,153;

*Calculate the sum of pac and hospital payments for each record;
proc sql;
    create table pmt_90_after_snf_3 as
        select BENE_ID, medpar_id_snf, SUM(Pmt_After_SNF_90) as Pmt_After_SNF_90_sum, 
            SUM(Pmt_After_SNF_90_SNF) as Pmt_After_SNF_90_Sum_SNF, SUM(Pmt_After_SNF_90_IRF) as Pmt_After_SNF_90_Sum_IRF, SUM(Pmt_After_SNF_90_HHA) as Pmt_After_SNF_90_Sum_HHA,
            SUM(Pmt_After_SNF_90_Other) as Pmt_After_SNF_90_Sum_Other, SUM(Pmt_After_SNF_90_ACUTE) as Pmt_After_SNF_90_Sum_ACUTE
        from pmt_90_after_snf_2
        group by medpar_id_snf;
quit; *9,427,153;

proc sort data=pmt_90_after_snf_3 NODUP; by medpar_id_snf; run; *4,257,618;

*Merge into the original dataset;
proc sql;
    create table pmt_90_after_snf_4 as
        select distinct main.*, payment.Pmt_After_SNF_90_sum,
                                payment.Pmt_After_SNF_90_sum_SNF, payment.Pmt_After_SNF_90_sum_IRF, payment.Pmt_After_SNF_90_sum_HHA, 
                                payment.Pmt_After_SNF_90_sum_Other, payment.Pmt_After_SNF_90_sum_Acute
        from snf.snf_los_county_ma_1016_new_12 as main
        left join pmt_90_after_snf_3 as payment
        on main.medpar_id_snf=payment.medpar_id_snf;
quit; *8,338,123;

data snf.snf_los_county_ma_1016_new_13;
    set pmt_90_after_snf_4;
    if Pmt_After_SNF_90_sum=. then Pmt_After_SNF_90_sum=0;
    if Pmt_After_SNF_90_sum_SNF=. then Pmt_After_SNF_90_sum_SNF=0;
    if Pmt_After_SNF_90_sum_IRF=. then Pmt_After_SNF_90_sum_IRF=0;
    if Pmt_After_SNF_90_sum_HHA=. then Pmt_After_SNF_90_sum_HHA=0;
    if Pmt_After_SNF_90_sum_Other=. then Pmt_After_SNF_90_sum_Other=0;
    if Pmt_After_SNF_90_sum_Acute=. then Pmt_After_SNF_90_sum_Acute=0;
    Pmt_After_SNF_90_PAC=sum(Pmt_After_SNF_90_sum_SNF, Pmt_After_SNF_90_sum_IRF, Pmt_After_SNF_90_sum_HHA, Pmt_After_SNF_90_sum_Other);
    label Pmt_After_SNF_90_sum_SNF = 'Payment amount to SNF within 90 days of SNF discharge' 
        Pmt_After_SNF_90_sum_IRF = 'Payment amount to IRF within 90 days of SNF discharge'  
        Pmt_After_SNF_90_sum_HHA = 'Payment amount to HHA within 90 days of SNF discharge' 
        Pmt_After_SNF_90_sum_OTHER = 'Payment amount to other providers within 90 days of SNF discharge'
        Pmt_After_SNF_90_sum_Acute = 'Payment amount to acute care hospital within 90 days of SNF discharge'
        Pmt_After_SNF_90_PAC = 'Payment amount to all post-acute care providers within 90 days of SNF discharge';
run; *8,338,123;

proc means data=snf.snf_los_county_ma_1016_new_13 nolabels n mean median min max maxdec=2;
    var Pmt_After_SNF_90_sum Pmt_After_SNF_90_PAC Pmt_After_SNF_90_sum_Acute;
run;



/**********************************************************************************************************************************************************
Step 18: Create 30-day and 90-day payment to all providers after SNF discharge
**********************************************************************************************************************************************************/

data snf.snf_los_county_ma_1016_new_14;
    set snf.snf_los_county_ma_1016_new_13;
    Pmt_After_SNF_30_All=sum(pmt_amt_snf,Pmt_After_SNF_30_PAC,Pmt_After_SNF_30_sum_Acute);
    Pmt_After_SNF_90_All=sum(pmt_amt_snf,Pmt_After_SNF_90_PAC,Pmt_After_SNF_90_sum_Acute);
    label Pmt_After_SNF_30_All="Payment Amount to All Providers in 30 Days after SNF Discharge"
        Pmt_After_SNF_90_All="Payment Amount to All Providers in 30 Days after SNF Discharge";
run; *8,338,123;

proc means data=snf.snf_los_county_ma_1016_new_14 nolabels n mean median min max maxdec=2;
    var Pmt_After_SNF_30_All Pmt_After_SNF_90_All;
run;



/**********************************************************************************************************************************************************
Step 19: Create an indicator for discharged against medical advice for SNF
**********************************************************************************************************************************************************/

data SNF_ama_2010_16;
    set Medpar.Mp100mod_2010(keep=MEDPAR_ID PRVDR_NUM DSTNTNCD) Medpar.Mp100mod_2011(keep=MEDPAR_ID PRVDR_NUM DSTNTNCD) 
        Medpar.Mp100mod_2012(keep=MEDPAR_ID PRVDR_NUM DSTNTNCD) Medpar.Mp100mod_2013(keep=MEDPAR_ID PRVDR_NUM DSTNTNCD) 
        Medpar.Mp100mod_2014(keep=MEDPAR_ID PRVDR_NUM DSTNTNCD) Medpar.Mp100mod_2015(keep=MEDPAR_ID PRVDR_NUM DSTNTNCD) 
        Medpar.Mp100mod_2016(keep=MEDPAR_ID PRVDR_NUM DSTNTNCD);
    where substr(PRVDR_NUM,3,1) in ('5','6');
    if DSTNTNCD=7 then ama=1; else ama=0;
    label ama="Discharged Against Medical Advice";
run; *18,368,283;

proc freq data=SNF_ama_2010_16;
    table DSTNTNCD;
run;

proc sql;
    create table snf.snf_los_county_ma_1016_new_15 as 
    select a.*, b.ama as ama_snf, b.DSTNTNCD as DSTNTNCD_snf
    from snf.snf_los_county_ma_1016_new_14 as a
    left join SNF_ama_2010_16 as b
    on a.medpar_id_snf=b.medpar_id;
quit; *8,338,123;

proc sql; create table check_merge as select * from snf.snf_los_county_ma_1016_new_15 where ama_snf=.; quit; *0;

proc freq data=snf.snf_los_county_ma_1016_new_15;
    table ama_snf;
run;



/**********************************************************************************************************************************************************
Step 20: Check where patients were discharged to using MedPAR and HHA claims
**********************************************************************************************************************************************************/

proc sql;
    create table snf_los_county_ma_1016_dstn as 
    select a.*, b.ADMSNDT_IRF, c.CLM_FROM_DT as admsndt_hha, d.ADMSNDT_other
    from snf.snf_los_county_ma_1016_new_15 as a
    left join mp.MedPAR2010_16_IRF_unique as b on a.bene_id=b.bene_id and a.dschrgdt_snf<=b.ADMSNDT_IRF<=a.dschrgdt_snf+3
    left join mp.hha2010_16_unique as c on a.bene_id=c.bene_id and a.dschrgdt_snf<=c.CLM_FROM_DT<=a.dschrgdt_snf+3
    left join mp.other2010_16_unique as d on a.bene_id=d.bene_id and a.dschrgdt_snf<=d.ADMSNDT_other<=a.dschrgdt_snf+3;
quit; *8,338,348;

proc sort data=snf_los_county_ma_1016_dstn; by medpar_id descending ADMSNDT_IRF descending admsndt_hha descending ADMSNDT_other; run;

data snf_los_county_ma_1016_dstn_2;
    set snf_los_county_ma_1016_dstn;
    by medpar_id descending ADMSNDT_IRF descending admsndt_hha descending ADMSNDT_other;
    if first.medpar_id;
run; *8,338,123;

data snf.snf_los_county_ma_1016_new_16;
    length dstntn_in_3_days dstntn_same_day $5.;
    set snf_los_county_ma_1016_dstn_2;
    *Discharge destination in 3 days;
    if ADMSNDT_IRF^=. then dstntn_in_3_days="IRF";
    if admsndt_hha^=. then dstntn_in_3_days="HHA";
    if ADMSNDT_other^=. then dstntn_in_3_days="Other";
    label dstntn_in_3_days="Discharge Destination within 3 Days of SNF Discharge";
    *Discharge destination on the same day;
    if ADMSNDT_IRF=dschrgdt_snf then dstntn_same_day="IRF";
    if admsndt_hha=dschrgdt_snf then dstntn_same_day="HHA";
    if ADMSNDT_other=dschrgdt_snf then dstntn_same_day="Other";
    label dstntn_same_day="Discharge Destination on the Same Day of SNF Discharge";
run; *8,338,123;

proc freq data=snf.snf_los_county_ma_1016_new_16;
    tables (dstntn_in_3_days dstntn_same_day);
run;



/**********************************************************************************************************************************************************
Step 21: Merge in Discharge Status Code from MDS assessment
**********************************************************************************************************************************************************/

*We will only use MDS 3.0 since the discharge status code is different in MDS 2.0. The variable in 2.0 is R3A_DISCHARGE_CD, which has 
 different values and more than 70% of values are missing;
proc sql;
    create table MDS_dschrg_status as 
    select a.*, b.A2100_DSCHRG_STUS_CD, b.MDS_DSCHRG_DT as MDS_DSCHRG_DT_temp 
    from snf.snf_los_county_ma_1016_new_16 as a 
    left join pac_mds.mds3_beneid_2010_16 as b
    on a.bene_id=b.bene_id and -3 le b.MDS_DSCHRG_DT-a.dschrgdt_snf le 3;
quit; *8,378,142;

data MDS_dschrg_status_2;
    set MDS_dschrg_status;
    int=abs(MDS_DSCHRG_DT_temp-dschrgdt_snf);
run;

proc sort data=MDS_dschrg_status_2; by medpar_id int; run;

data snf.snf_los_county_ma_1016_new_17(drop=MDS_DSCHRG_DT_temp int);
    set MDS_dschrg_status_2;
    by medpar_id int;
    if first.medpar_id;
run; *8,338,123;

proc freq data=snf.snf_los_county_ma_1016_new_17;
    table A2100_DSCHRG_STUS_CD;
    where admsndt_snf>=18536;
run;



/**********************************************************************************************************************************************************
Step 22: Exclude records of resident was comatose (B0100 =[01]) or missing data on comatose on the first MDS assessment 
**********************************************************************************************************************************************************/

data comatose_mds_30(keep=bene_id MDS_ENTRY_DT);
    set pac_mds.mds3_beneid_2010_16(keep=bene_id MDS_ENTRY_DT B0100_CMTS_CD A0310B_PPS_CD);
    where B0100_CMTS_CD in ('1','-') & A0310B_PPS_CD eq '01';
run; *51,443;

data comatose_mds_20(keep=bene_id MDS_ENTRY_DT);
    set pac_mds.mds2_2010_beneid(keep=bene_id AB1_ENTRY_DT b1_comatose aa8b_spc_rfa);
    MDS_ENTRY_DT=input(AB1_ENTRY_DT,yymmdd8.);
    where b1_comatose in ('1','-') & aa8b_spc_rfa eq "1";
run; *3,214;

data comatose_1016;
    set comatose_mds_20 comatose_mds_30;
run; *54,657;

proc sql;
    create table snf_los_county_ma_1016_comatose as 
    select a.*, b.MDS_ENTRY_DT as comatose
    from snf.snf_los_county_ma_1016_new_17 as a 
    left join comatose_1016 as b
    on a.bene_id=b.bene_id and 0 le b.MDS_ENTRY_DT-a.admsndt_snf le 3;
quit; *8,338,202; 

proc sort data=snf_los_county_ma_1016_comatose nodupkey; by medpar_id_snf; run; *8,338,123;;

data snf.snf_los_county_ma_1016_new_18(drop=comatose);
    set snf_los_county_ma_1016_comatose;
    where comatose=.;
run; *8,323,686;



/**********************************************************************************************************************************************************
Step 23: Create Indicator for records of patients who were resident of the nursing home in the previous 30 days and drop record without matched MDS records 
**********************************************************************************************************************************************************/

*MDS 2.0 - 2009;
data MDS2009;
    set mds2.j43356_2009_f (keep=RES_INT_ID state_id target_date AB1_ENTRY_DT R4_DISCHARGE_DT AA8A_PRI_RFA) 
        mds2.j43356_2009_f1(keep=RES_INT_ID state_id target_date AB1_ENTRY_DT R4_DISCHARGE_DT AA8A_PRI_RFA)  
        mds2.j43356_2009_f2(keep=RES_INT_ID state_id target_date AB1_ENTRY_DT R4_DISCHARGE_DT AA8A_PRI_RFA)  
        mds2.j43356_2009_f3(keep=RES_INT_ID state_id target_date AB1_ENTRY_DT R4_DISCHARGE_DT AA8A_PRI_RFA);
run; *16,849,671;

*Merge MDS assessments with XWalk to get bene_id for MDS;
proc sql;
    create table MDS2009_bene_id as
    select mds.*,xwalk.bene_id
    from MDS2009 as mds
    left join xwalk.rw_resid_bene_xwalk_q398_q310 as xwalk
    on mds.RES_INT_ID=xwalk.RES_INT_ID and mds.state_id=xwalk.state_cd;
quit; *16,866,086;

data MDS2009_bene_id_2; 
    set MDS2009_bene_id(drop=RES_INT_ID state_id); 
    where bene_id^=""; 
run; *16,489,682 (97.77% are found);

data MDS2009_bene_id_3(drop=TARGET_DATE AB1_ENTRY_DT R4_DISCHARGE_DT); 
    set MDS2009_bene_id_2;
    if R4_DISCHARGE_DT^="********" then MDS_DSCHRG_DT=input(R4_DISCHARGE_DT,yymmdd8.);
    format MDS_DSCHRG_DT date9.;
    if AB1_ENTRY_DT^="********" then MDS_ENTRY_DT=input(AB1_ENTRY_DT,yymmdd8.);
    format MDS_ENTRY_DT date9.;
    MDS_TRGT_DT=input(TARGET_DATE,yymmdd8.);
    format MDS_TRGT_DT date9.;
run; *16,489,682;

proc sort data=MDS2009_bene_id_3; by bene_id MDS_TRGT_DT ; run;

*MDS 2.0 - first 9 months of 2010;
data mds2_2010;
    set pac_mds.mds2_2010_beneid(keep=bene_id target_date AB1_ENTRY_DT R4_DISCHARGE_DT AA8A_PRI_RFA);
    where bene_id^="";
run;

data mds2_2010_2(drop=TARGET_DATE AB1_ENTRY_DT R4_DISCHARGE_DT); 
    set	mds2_2010;
    if R4_DISCHARGE_DT^="********" then MDS_DSCHRG_DT=input(R4_DISCHARGE_DT,yymmdd8.);
    format MDS_DSCHRG_DT date9.;
    if AB1_ENTRY_DT^="********" then MDS_ENTRY_DT=input(AB1_ENTRY_DT,yymmdd8.);
    format MDS_ENTRY_DT date9.;
    MDS_TRGT_DT=input(TARGET_DATE,yymmdd8.);
    format MDS_TRGT_DT date9.;
run; *12,470,201;

proc sort data=mds2_2010_2; by bene_id MDS_TRGT_DT ; run;

data mds2_2009_2010;
    set MDS2009_bene_id_3 mds2_2010;
run; *28,959,883;

proc sort data=mds2_2009_2010; by bene_id MDS_TRGT_DT ; run;

proc freq data=mds2_2009_2010;
    table AA8A_PRI_RFA;
run;

*MDS 3.0 - Oct 2010 to 2016;
data mds3_2010_2016;
    set pac_mds.mds3_beneid_2010_16(keep=bene_id A0310A_FED_OBRA_CD MDS_ENTRY_DT MDS_DSCHRG_DT MDS_TRGT_DT);
    where bene_id^="";
run; *123,075,813;

proc sort data=mds3_2010_2016; by bene_id MDS_TRGT_DT; run; 

proc freq data=mds3_2010_2016;
    table A0310A_FED_OBRA_CD;
run;

*Combine 2009-2016 MDS discharge assessments;
data mds_2009_2016;
    set mds2_2009_2010 (keep=bene_id MDS_ENTRY_DT MDS_DSCHRG_DT MDS_TRGT_DT)
        mds3_2010_2016 (keep=bene_id MDS_ENTRY_DT MDS_DSCHRG_DT MDS_TRGT_DT);
run; 

proc sort data=mds_2009_2016; by bene_id MDS_TRGT_DT; run;

*1) Merge analytical data set with MDS data set to check if patient had any MDS assessment in the previous 30 days before hospital admission;
proc sql;
    create table mds_trgt as
    select a.*, b.MDS_TRGT_DT
    from snf.snf_los_county_ma_1016_new_18 as a
    left join mds_2009_2016 as b  
    on a.bene_id=b.bene_id and 0 lt a.ADMSNDT-b.MDS_TRGT_DT le 30;
quit; *10,853,316;

proc sort data=mds_trgt; by medpar_id_snf descending MDS_TRGT_DT; run; 

data mds_trgt_2(drop=MDS_TRGT_DT);
    set mds_trgt;
    by medpar_id_snf descending MDS_TRGT_DT;
    if first.medpar_id_snf;
    if MDS_TRGT_DT^=. then rsdnt_nh_prev_30=1; else rsdnt_nh_prev_30=0;
    label rsdnt_nh_prev_30="Resident of the Nursing Home in the Previous 30 Days";
run; *8,323,686;

proc freq data=mds_trgt_2; table rsdnt_nh_prev_30; run; *1,636,207 (19.66%);

*2) Merge analytical data set with MDS data set to check if patient had any MDS assessment in the previous 100 days and the last assessment received is not discharge assessment;
proc sql;
    create table mds_trgt_3 as
    select a.*, b.MDS_TRGT_DT, b.MDS_DSCHRG_DT
    from mds_trgt_2 as a
    left join mds_2009_2016 as b  
    on a.bene_id=b.bene_id and 0 lt a.ADMSNDT-b.MDS_TRGT_DT le 100;
quit;

proc sort data=mds_trgt_3; by medpar_id_snf descending MDS_TRGT_DT; run; 

data snf.snf_los_county_ma_1016_new_19 (drop=MDS_TRGT_DT MDS_DSCHRG_DT);
    set mds_trgt_3;
    by medpar_id_snf descending MDS_TRGT_DT;
    if first.medpar_id_snf;
    if MDS_TRGT_DT^=. & MDS_DSCHRG_DT=. then rsdnt_nh_prev_30=1; 
run; *8,323,686;

proc freq data=snf.snf_los_county_ma_1016_new_19; table rsdnt_nh_prev_30; run; *1,846,465 (22.18%);



/**********************************************************************************************************************************************************
Step 24: Merge in SNF profit status from POS files and SNF occupancy rate from LTC Focus
**********************************************************************************************************************************************************/

*Combine 2010-2016 POS files;
data pos_2010; set pos.pos2010_orig (keep=prvdr_num GNRL_CNTL_TYPE_CD crtfd_bed_cnt /*CBSA_URBN_RRL_IND*/ mlt_ownd_fac_org_sw); year=2010; run; *No CBSA_URBN_RRL_IND in 2010 POS file;
data pos_2011; set pos.pos2011_orig (keep=prvdr_num GNRL_CNTL_TYPE_CD crtfd_bed_cnt CBSA_URBN_RRL_IND mlt_ownd_fac_org_sw); year=2011; run;
data pos_2012; set pos.pos2012_orig (keep=prvdr_num GNRL_CNTL_TYPE_CD crtfd_bed_cnt CBSA_URBN_RRL_IND mlt_ownd_fac_org_sw); year=2012; run;
data pos_2013; set pos.pos2013_orig (keep=prvdr_num GNRL_CNTL_TYPE_CD crtfd_bed_cnt CBSA_URBN_RRL_IND mlt_ownd_fac_org_sw); year=2013; run;
data pos_2014; set pos.pos2014_orig (keep=prvdr_num GNRL_CNTL_TYPE_CD crtfd_bed_cnt CBSA_URBN_RRL_IND mlt_ownd_fac_org_sw); year=2014; run;
data pos_2015; set pos.pos2015_orig (keep=prvdr_num GNRL_CNTL_TYPE_CD crtfd_bed_cnt CBSA_URBN_RRL_IND mlt_ownd_fac_org_sw); year=2015; run;
data pos_2016; set pos.pos2016_orig (keep=prvdr_num GNRL_CNTL_TYPE_CD crtfd_bed_cnt CBSA_URBN_RRL_IND mlt_ownd_fac_org_sw); year=2016; run;

data pos_1016;
    set pos_2010 pos_2011 pos_2012 pos_2013 pos_2014 pos_2015 pos_2016;
run;

proc sql;
    create table snf_los_county_ma_1016_pos as 
    select a.*, b.GNRL_CNTL_TYPE_CD, b.crtfd_bed_cnt, b.CBSA_URBN_RRL_IND, b.mlt_ownd_fac_org_sw
    from snf.snf_los_county_ma_1016_new_19 as a 
    left join pos_1016 as b
    on a.prvdrnum_snf=b.prvdr_num and a.dschrg_year=b.year;
quit; *8,323,686;

*Check number of unsuccessful matched records;
proc sql; create table check_missing_1 as select dschrg_year from snf_los_county_ma_1016_pos where missing(crtfd_bed_cnt); quit; *500;
proc sql; create table check_missing_2 as select dschrg_year from snf_los_county_ma_1016_pos where missing(gnrl_cntl_type_cd); quit; *500;
proc sql; create table check_missing_3 as select dschrg_year from snf_los_county_ma_1016_pos where missing(CBSA_URBN_RRL_IND); quit; *1,129,232;
proc sql; create table check_missing_4 as select dschrg_year from snf_los_county_ma_1016_pos where missing(mlt_ownd_fac_org_sw); quit; *497,398 (5.9%) - 44% of 2010 have missing;

data snf.snf_los_county_ma_1016_new_20(drop=GNRL_CNTL_TYPE_CD);
    set snf_los_county_ma_1016_pos;
    *Create for-profit SNF indicator;
    if GNRL_CNTL_TYPE_CD in ("01","02","03","13") then for_profit_snf=1;
    else for_profit_snf=0;
    if GNRL_CNTL_TYPE_CD="" then for_profit_snf=.;
    label for_profit_snf="For-profit SNF";
    *Create urban-rural indicator;
    if CBSA_URBN_RRL_IND="U" then urban=1;
    else if CBSA_URBN_RRL_IND="R" then urban=0;
    label urban="Urban Area";
    *Create SNF part of the chain indicator;
    if mlt_ownd_fac_org_sw="Y" then part_of_chain=1; 
    else if mlt_ownd_fac_org_sw="N" then part_of_chain=0; 
    label part_of_chain="Facility is Part of a Chain that Owns Multiple Facilities";
run; *8,323,686;

proc means data=snf.snf_los_county_ma_1016_new_20; var crtfd_bed_cnt; run;
proc freq data=snf.snf_los_county_ma_1016_new_20; tables (for_profit_snf urban part_of_chain); run;

libname ltc "/project/PACUse_RWerner/Mingyu/Zach_SNF/Temp_Data";

proc sql;
    create table snf.snf_los_county_ma_1016_new_21 as 
    select a.*, b.SNF_Occpct
    from snf.snf_los_county_ma_1016_new_20 as a 
    left join ltc.ltc_focus_2009_2016 as b
    on a.prvdrnum_snf=b.SNF_Prvdr_Num and a.dschrg_year=b.year;
quit; *8,323,686;

proc sql; 
    create table check_missing as 
    select prvdrnum_snf,dschrg_year 
    from snf.snf_los_county_ma_1016_new_21 
    where SNF_Occpct=.
    order by dschrg_year; 
quit; *148,834 (1.8%);



/**********************************************************************************************************************************************************
Step 25: Output data set as .dta file
**********************************************************************************************************************************************************/

proc export data=snf.snf_los_county_ma_1016_new_21
            outfile="/secure/project/PACUse_RWerner/Mingyu/SNF_LOS/Data/snf_los_county_ma_1016_final.dta" 
            dbms=dta replace;
run;



/**********************************************************************************************************************************************************
Repeat steps 7 - 25 using the panel of SNF stays created with MDS to generate study sample of Medicare Advantage beneficiaries
**********************************************************************************************************************************************************/


