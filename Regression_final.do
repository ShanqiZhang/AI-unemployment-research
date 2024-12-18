*Date: 2023.12.03
*Editor: Shanqi Zhang, The Chinese University of Hong Kong

*regression conducted upon cleaned dataset

use "/Users/shanqizhang/Desktop/ECON4901/s1155157237/ECON4901/merged_patent_controlvar.dta"

*1. Simple linear OLS
*the most significant: lagged unemployment and fixed time & country effect, BUT dosen't seem right
rename DandR DandR_portion
gen DandR=DandR_portion*GDP
foreach var in FDI Population GDP GDP_ppp {
    gen log_`var' = log(`var'+1)
}
drop value* iso3c _merge lag_U_total

*generate var to indicate how much data is mssing for each obs
egen completeness = rownonmiss(U_total UD WCB AIinv DandR FDI Gov_size Inflation GDP Population AI_portion AIinv log_Population FDI_percent)


*LINEAR INTREPOLATION: USE BEFORE REGRESSION TO FILL MISSING VAUES 
foreach var in U_total U_agriculture U_service U_ADVedu U_INTedu U_BASedu UD AIinv DandR FDI Gov_size Inflation log_GDP Population AI_portion log_Population FDI_percent Coord AIpatent{
    by Country_n: ipolate `var' Year, gen(i`var')
}

*TEST FOR HETEROSKEDATSITY
reg F.U_total AI_portion Inflation Population FDI_percent Coord UD developing
hettest

*TEST FOR AUTOCORRELATION
reg F.U_total AI_portion Inflation Population FDI_percent Coord UD developing
predict residuals, residuals
xtserial residuals



xtreg  F.U_total Population Inflation AI_portion FDI_percent Coord UD, fe


*sig at 10%, cannot encorpate developing dummy, after filling in missing values
xtreg  F.U_total Population Inflation AI_portion FDI_percent Coord UD, fe
xtreg  F.U_total Population Inflation AIpatent FDI_percent Coord UD, fe
xtreg  F.U_total Population Inflation AI_portion FDI_percent Coord UD if developing==1, fe
*sig at 10%
xtreg  F.U_total Population Inflation AIinv FDI_percent Coord UD, fe

*sig at 5%
reg F.U_total AIinv Inflation Population FDI_percent Coord UD developing, robust
*not sig 
reg F.U_total AIpatent Inflation Population FDI_percent Coord UD developing, robust

*impact of AIdevelopment on employment of diff industry, half could be 10% sig
foreach var in employ_otherservice employ_professional employ_publicadmin employ_publicsector employ_senior employ_service employ_serviceandsales employ_skilledagriculture employ_technician employ_transport employ_mining employ_manufactor employ_machine employ_industrial employ_finance employ_elementary employ_electricity employ_craft employ_construction employ_commerce employ_clerk employ_armedforce employ_agriculture{
	reg `var' AI_portion Inflation Population FDI_percent Coord UD, robust
}

*to adress too many missing data, construct mixed effect regression
*xtmixed F.U_total AIinv Inflation Population FDI_percent Coord UD || Year:, reml var
*sig @ 5%
*xtmixed F.U_total AI_portion Inflation Population FDI_percent Coord UD || Year:, reml var
*xtmixed F.U_total AI_portion Inflation Population FDI_percent Coord UD || Year: if developing==1, reml var




*2.GMM model regressions
*tesing for which var to include as IV
ivreg U_total (L.lag_U_total =  Population AI_portion FDI GDP Inflation ), first

*2-step system GMM :sig at 10% NO filling
xtabond2 U_total L.U_total AI_portion log_Population FDI_percent Inflation Coord UD y*, gmm(L.U_total AI_portion, collapse)iv(log_Population GDP Inflation FDI_percent UD y*) noleveleq nodiffsargan robust twostep

*********one-step system GMM: sig at 1% NO intrepolation**************
xtabond2 U_total L.U_total AI_portion log_Population FDI_percent Inflation Coord UD y*, gmm(L.U_total AI_portion, collapse)iv(log_Population GDP Inflation FDI_percent UD y*, equation(level)) nodiffsargan robust orthogonal

*********10% with intrepolation**********
*model1
xtabond2 iU_total L.iU_total iAI_portion ilog_Population iFDI_percent iInflation ilog_GDP iCoord iUD developing y*, gmm(L.iU_total iAI_portion, collapse)iv(ilog_Population ilog_GDP iInflation iFDI_percent iUD y*, equation(level)) nodiffsargan robust orthogonal
*model2
xtabond2 iU_total L.iU_total iAIinv ilog_Population iFDI_percent iInflation ilog_GDP iCoord iUD developing y*, gmm(L.iU_total iAIinv, collapse)iv(ilog_Population ilog_GDP iInflation iFDI_percent iUD y*, equation(level)) nodiffsargan robust orthogonal
*model3
xtabond2 iU_total L.iU_total iAIpatent ilog_Population iFDI_percent iInflation ilog_GDP iCoord iUD developing y*, gmm(L.iU_total iAIpatent, collapse)iv(ilog_Population ilog_GDP iInflation iFDI_percent iUD y*, equation(level)) nodiffsargan robust orthogonal

********Unemplolyment BTW Industries & EDU level******

****For developed Countries
drop if developing==1

*Different Industry sector
foreach var in iU_total iU_agriculture iU_service {
	xtabond2 `var' L.`var' iAI_portion ilog_Population iFDI_percent iInflation ilog_GDP iCoord iUD developing y*, gmm(L.`var' iAI_portion, collapse)iv(ilog_Population ilog_GDP iInflation iFDI_percent iUD y*, equation(level)) nodiffsargan robust orthogonal
}

*Different edu level
foreach var in iU_ADVedu iU_INTedu iU_BASedu {
	xtabond2 `var' L.`var' iAI_portion ilog_Population iFDI_percent iInflation ilog_GDP iCoord iUD developing y*, gmm(L.`var' iAI_portion, collapse)iv(ilog_Population ilog_GDP iInflation iFDI_percent iUD y*, equation(level)) nodiffsargan robust orthogonal
}


****For developing Countries
clear
use "/Users/shanqizhang/Desktop/ECON4901/s1155157237/ECON4901/merged_patent_controlvar.dta"
*LINEAR INTREPOLATION: USE BEFORE REGRESSION TO FILL MISSING VAUES 
foreach var in U_total U_agriculture U_service U_ADVedu U_INTedu U_BASedu UD AIinv DandR FDI Gov_size Inflation log_GDP Population AI_portion log_Population FDI_percent Coord AIpatent{
    by Country_n: ipolate `var' Year, gen(i`var')
}

drop if developing==0
*Total Unemplolyment
xtabond2 iU_total L.iU_total iAI_portion ilog_Population iFDI_percent iInflation ilog_GDP iCoord iUD developing y*, gmm(L.iU_total iAI_portion, collapse)iv(ilog_Population ilog_GDP iInflation iFDI_percent iUD y*, equation(level)) nodiffsargan robust orthogonal
*Agriculture Unemplolyment
xtabond2 iU_agriculture L.iU_agriculture iAI_portion ilog_Population iFDI_percent iInflation ilog_GDP iCoord iUD developing y*, gmm(L.iU_agriculture iAI_portion, collapse)iv(ilog_Population ilog_GDP iInflation iFDI_percent iUD y*, equation(level)) nodiffsargan robust orthogonal
*Service Unemployment
xtabond2 iU_service L.iU_service iAI_portion ilog_Population iFDI_percent iInflation ilog_GDP iCoord iUD developing y*, gmm(L.iU_service iAI_portion, collapse)iv(ilog_Population ilog_GDP iInflation iFDI_percent iUD y*, equation(level)) nodiffsargan robust orthogonal

*Different edu level
foreach var in iU_ADVedu iU_INTedu iU_BASedu {
	xtabond2 `var' L.`var' iAI_portion ilog_Population iFDI_percent iInflation ilog_GDP iCoord iUD developing y*, gmm(L.`var' iAI_portion, collapse)iv(ilog_Population ilog_GDP iInflation iFDI_percent iUD y*, equation(level)) nodiffsargan robust orthogonal
}


foreach var in employ_otherservice employ_professional employ_publicadmin employ_publicsector employ_senior employ_service employ_serviceandsales employ_skilledagriculture employ_technician employ_transport employ_mining employ_manufactor employ_machine employ_industrial employ_finance employ_elementary employ_electricity employ_craft employ_construction employ_commerce employ_clerk employ_armedforce employ_agriculture{
	xtabond2 `var' L.`var' AI_portion log_Population FDI_percent Inflation Coord UD y*, gmm(L.U_total AI_portion, collapse)iv(log_Population GDP Inflation FDI_percent UD y*, equation(level)) nodiffsargan robust orthogonal

}

foreach var in U_agriculture U_industry U_service U_ADVedu U_BASedu U_INTedu{
	xtabond2 `var' L.`var' AI_portion log_Population FDI_percent Inflation Coord UD y*, gmm(L.U_total AI_portion, collapse)iv(log_Population GDP Inflation FDI_percent UD y*, equation(level)) nodiffsargan robust orthogonal

}


