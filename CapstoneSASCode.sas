*Defining library;
libname MIS581 "/home/u58891260/sasuser.v94/MIS581";

*Importing Excel file as SAS dataset;
%web_drop_table(MIS581.ATHLETE_NONATHLETEMHSURVEY);
FILENAME REFFILE '/home/u58891260/sasuser.v94/MIS581/Capstone Dataset - Coded.xlsx';
PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=MIS581.ATHLETE_NONATHLETEMHSURVEY;
	GETNAMES=YES;
RUN;
PROC CONTENTS DATA=MIS581.ATHLETE_NONATHLETEMHSURVEY; RUN;
%web_open_table(MIS581.ATHLETE_NONATHLETEMHSURVEY);

*Research Question #1
*T-Test comparing Resilience scores between Athletes and Non-Athletes;
/* Define Formats for Group Labels */
proc format;
    value groupfmt
        1 = 'Athletes'
        2 = 'Non-Athletes';
run;

/* Add Date and Timestamp to Header */
title1 "Analysis Run on %sysfunc(date(), worddate.) at %sysfunc(time(), timeampm.)";

/* Add Date and Timestamp to Footer */
footnote1 "Generated on %sysfunc(date(), worddate.) at %sysfunc(time(), timeampm.)";

/* Test for Normality */
proc univariate data=MIS581.ATHLETE_NONATHLETEMHSURVEY normal mu0=0;
    ods select TestsForNormality;
    where res_total ne 999;
    class 'Athlete/Non-Athlete'n;
    var RES_TOTAL;
    label RES_TOTAL = 'Resilience Score'
          'Athlete/Non-Athlete'n = 'Group';
    format 'Athlete/Non-Athlete'n groupfmt.;
run;

/* Two-Sample t-Test */
proc ttest data=MIS581.ATHLETE_NONATHLETEMHSURVEY sides=U h0=0 plots(showh0);
    where res_total ne 999;
    class 'Athlete/Non-Athlete'n;
    var RES_TOTAL;
    label RES_TOTAL = 'Resilience Score'
          'Athlete/Non-Athlete'n = 'Group';
    format 'Athlete/Non-Athlete'n groupfmt.;
run;

*Question 2;
/* Add Date and Timestamp to Header */
title1 "Analysis Run on %sysfunc(date(), worddate.) at %sysfunc(time(), timeampm.)";

/* Add Date and Timestamp to Footer */
footnote1 "Generated on %sysfunc(date(), worddate.) at %sysfunc(time(), timeampm.)";

/* Assign Labels to Variables */
data survey_labeled;
    set MIS581.ATHLETE_NONATHLETEMHSURVEY;
    label 
        'MHC-SF OVERALL'n = "Mental Health Score"
        RES_TOTAL = "Resilience Score";
run;
*Correlation Analysis between Resilience and Mental Health;
proc corr data=survey_labeled pearson spearman plots=scatter(nvar=2);
    where 'MHC-SF OVERALL'n ne 999 and RES_TOTAL ne 999;
    var 'MHC-SF OVERALL'n RES_TOTAL;
run;
*Linear Regression Analysis;
proc reg data=survey_labeled alpha=0.05 
    plots(only)=(diagnostics residuals fitplot observedbypredicted);
    where RES_TOTAL ne 999 and 'MHC-SF OVERALL'n ne 999;
    model 'MHC-SF OVERALL'n = RES_TOTAL;
run;
quit;

*Question 3;
*Loneliness by weeks social distancing;
*One-way ANOVA;

/* Step 1: Define Custom Format */
proc format;
    value $weekorder
        "0" = "0"
        "1-3" = "1-3"
        "4-6" = "4-6"
        "7-9" = "7-9"
        "10-12" = "10-12"
        "13-15" = "3-15"
        "16-18" = "16-18"
        "19-21" = "19-21";
run;

/* Step 2: Assign Labels and Recode Variables */
data survey_labeled;
    set MIS581.ATHLETE_NONATHLETEMHSURVEY;
    label 
        'LONE_ TOTAL'n = "Loneliness Score";

    length Weeks_Distancing $25;
    if 'Weeks Social Distancing'n = 0 then Weeks_Distancing = "0";
    else if 'Weeks Social Distancing'n = 1 then Weeks_Distancing = "1-3";
    else if 'Weeks Social Distancing'n = 2 then Weeks_Distancing = "4-6";
    else if 'Weeks Social Distancing'n = 3 then Weeks_Distancing = "7-9";
    else if 'Weeks Social Distancing'n = 4 then Weeks_Distancing = "10-12";
    else if 'Weeks Social Distancing'n = 5 then Weeks_Distancing = "13-15";
    else if 'Weeks Social Distancing'n = 6 then Weeks_Distancing = "16-18";
    else if 'Weeks Social Distancing'n = 7 then Weeks_Distancing = "19-21";

    label Weeks_Distancing = "Weeks Social Distancing";
    format Weeks_Distancing $weekorder.;  /* Apply Custom Format */
run;

/* Step 3: GLM Procedure with Correct Order in Output */
proc glm data=survey_labeled order=formatted;  /* Use ORDER=FORMATTED */
    where 'LONE_ TOTAL'n ne 999 and 'Weeks Social Distancing'n ne 999;
    class Weeks_Distancing;
    model 'LONE_ TOTAL'n = Weeks_Distancing;
    means Weeks_Distancing / hovtest=levene welch plots=none;
    lsmeans Weeks_Distancing / adjust=tukey pdiff alpha=.05;
run;
quit;



/* Questions4 */
/* Mental Health by Individual or Team Athlete */
/* Update variable labels */
/* Add Date and Timestamp to Header */
title1 "Analysis Run on %sysfunc(date(), worddate.) at %sysfunc(time(), timeampm.)";

/* Add Date and Timestamp to Footer */
footnote1 "Generated on %sysfunc(date(), worddate.) at %sysfunc(time(), timeampm.)";
proc datasets lib=MIS581 nolist;
    modify ATHLETE_NONATHLETEMHSURVEY;
    label 'MHC-SF OVERALL'n = 'Mental Health Scores'
          'Individual/Team athlete?'n = 'Individual or Team Athlete';
quit;

/* Label values for Individual or Team Athlete */
proc format;
    value AthleteFmt
        1 = 'Individual'
        2 = 'Team';
run;

/* Test for normality */
proc univariate data=MIS581.ATHLETE_NONATHLETEMHSURVEY normal mu0=0;
    ods select TestsForNormality;
    where 'MHC-SF OVERALL'n ne 999 and 'Individual/Team athlete?'n ne 999;
    class 'Individual/Team athlete?'n;
    format 'Individual/Team athlete?'n AthleteFmt.;
    var 'MHC-SF OVERALL'n;
run;

/* t test */
proc ttest data=MIS581.ATHLETE_NONATHLETEMHSURVEY sides=2 h0=0 plots(showh0);
    where 'MHC-SF OVERALL'n ne 999 and 'Individual/Team athlete?'n ne 999;
    class 'Individual/Team athlete?'n;
    format 'Individual/Team athlete?'n AthleteFmt.;
    var 'MHC-SF OVERALL'n;
run;

/* Nonparametric test */
proc npar1way data=MIS581.ATHLETE_NONATHLETEMHSURVEY wilcoxon 
        plots=wilcoxonplot;
    where 'MHC-SF OVERALL'n ne 999 and 'Individual/Team athlete?'n ne 999;
    class 'Individual/Team athlete?'n;
    format 'Individual/Team athlete?'n AthleteFmt.;
    var 'MHC-SF OVERALL'n;
run;



