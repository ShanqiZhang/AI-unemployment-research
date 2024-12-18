*4901 Data cleaning
*Editor: Shanqi ZHang, The Chinese University of Hong Kong
*Date: 2023.10.26


*1. reshape AI patent data
clear
import excel "/Users/shanqizhang/Desktop/ECON4901/s1155157237/ECON4901/AIpatent2000to2017.xls", sheet("OECD.Stat export") cellrange(A3:R105) firstrow
reshape long patent, i(Country) j(year)
replace Country="Turkiye" if Country=="Türkiye"
replace Country="Egypt, Arab Rep." if Country=="Egypt"
replace Country="Venezuela, RB" if Country=="Venezuela"
replace Country="China" if Country=="China (People's Republic of)"
rename patent AIpatent
save "/Users/shanqizhang/Desktop/ECON4901/s1155157237/ECON4901/AIpatent2001to2017.dta", replace

clear
import excel "/Users/shanqizhang/Desktop/ECON4901/s1155157237/ECON4901/total_patent.xls", sheet("OECD.Stat export") cellrange(A3:U104) firstrow
drop patent2020
reshape long patent, i(Country) j(year)
replace Country="Turkiye" if Country=="Türkiye"
replace Country="Egypt, Arab Rep." if Country=="Egypt"
replace Country="Venezuela, RB" if Country=="Venezuela"
replace Country="China" if Country=="China (People's Republic of)"
rename patent Totalpatent
save "/Users/shanqizhang/Desktop/ECON4901/s1155157237/ECON4901/Totalpatent2001-2019.dta", replace

clear
import excel "/Users/shanqizhang/Desktop/ECON4901/s1155157237/ECON4901/OECD_laborstat.xlsx", sheet("Sheet1") firstrow
destring WCB UD Coord year, replace
drop if year<2000
drop in 1159/l
foreach var in WCB UD Coord{
	replace `var' =. if `var'==-88
}
label var Coord "Coordination of wage-setting"
save "/Users/shanqizhang/Desktop/ECON4901/s1155157237/ECON4901/laborstat2000-2020.dta", replace

clear
use "/Users/shanqizhang/Desktop/ECON4901/s1155157237/ECON4901/AIpatent2001to2017.dta"
merge 1:1 Country year using  "/Users/shanqizhang/Desktop/ECON4901/s1155157237/ECON4901/Totalpatent2001-2019.dta"
drop if _merge!=3
gen AI_portion=.
replace AI_portion=AIpatent/Totalpatent if Totalpatent!=0
drop _merge
merge 1:1 Country year using "/Users/shanqizhang/Desktop/ECON4901/s1155157237/ECON4901/laborstat2000-2020.dta"
drop if _merge!=3
drop _merge
save "/Users/shanqizhang/Desktop/ECON4901/s1155157237/ECON4901/Patent2001to2017.dta", replace



*2 reshape other control var & unemployment
clear
import delimited "/Users/shanqizhang/Desktop/ECON4901/s1155157237/ECON4901/5961b1b5-0e6f-47b5-884b-b3f9cecc9e6f_Series - Metadata.csv", varnames(1)
drop in 10109/l
reshape long yr, i(countryname countrycode seriesname seriescode) j(Year)
rename yr value
gen Country = substr( countrycode , 1, 3)
drop seriesname
gen Seriescode = subinstr( seriescode , ".", "_", .)
drop seriescode 
reshape wide value, i( Year Country) j(Seriescode) string
save "/Users/shanqizhang/Desktop/ECON4901/s1155157237/ECON4901/ControlVars.dta",replace
clear

import delimited "/Users/shanqizhang/Desktop/ECON4901/s1155157237/ECON4901/R&D_Data.csv", varnames(1)
drop in 218/l
reshape long yr, i(countryname countrycode seriesname seriescode) j(Year)
rename yr value
gen Country = substr( countrycode , 1, 3)
drop seriesname
gen Seriescode = subinstr( seriescode , ".", "_", .)
reshape wide value, i( Year Country) j(Seriescode) string
rename valueGB_XPD_RSDV_GD_ZS DandR
save "/Users/shanqizhang/Desktop/ECON4901/s1155157237/ECON4901/DandRVars.dta",replace
clear

import excel "/Users/shanqizhang/Desktop/ECON4901/s1155157237/ECON4901/P_Data_Extract_From_Global_Jobs_Indicators_Database_(JOIN) (2).xlsx", sheet("Data") cellrange(A1:V3866) firstrow case (lower)
reshape long yr, i(countryname countrycode seriesname seriescode) j(Year)
rename yr value
gen Country = substr( countrycode , 1, 3)
drop seriesname
gen Seriescode = subinstr( seriescode , ".", "_", .)
drop if Seriescode==""
drop seriescode 
reshape wide value, i( Year Country) j(Seriescode) string
save "/Users/shanqizhang/Desktop/ECON4901/s1155157237/ECON4901/Industry_employment.dta", replace
clear

use "/Users/shanqizhang/Desktop/ECON4901/s1155157237/ECON4901/ControlVars.dta"
merge 1:1 Year Country using "/Users/shanqizhang/Desktop/ECON4901/s1155157237/ECON4901/DandRVars.dta"
drop if _merge!=3
drop _merge
merge 1:1 Year Country using"/Users/shanqizhang/Desktop/ECON4901/s1155157237/ECON4901/Industry_employment.dta"
drop _merge
save "/Users/shanqizhang/Desktop/ECON4901/s1155157237/ECON4901/ControlVars.dta",replace



*3,merge AI patent with countries' other attributess
clear
use "/Users/shanqizhang/Desktop/ECON4901/s1155157237/ECON4901/ControlVars.dta"
recast str37 countryname , force
drop Country
rename countryname Country
rename Year year
merge 1:1 Country year using "/Users/shanqizhang/Desktop/ECON4901/s1155157237/ECON4901/Patent2001to2017.dta"

drop if _merge!=3
*drop the counties that are jointly defined as "developed" at the beginning of our study period: 2001
*based on : https://en.wikipedia.org/wiki/Developed_country#cite_note-:2-26
*drop if Country=="Singapore"|Country=="Finland"|Country=="United Kingdom"|Country=="Ireland"|Country=="Iceland"|Country=="Sweden"|Country=="France"|Country=="Australia"|Country=="Belgium"|Country=="Canada"|Country=="Italy"|Country=="Austria"|Country=="Germany"|Country=="Japan"|Country=="Netherlands"|Country=="Denmark"|Country=="Luxembourg"|Country=="United States"|Country=="Norway"|Country=="Switzerland"

*4,clean the merged data
replace valueSL_UEM_TOTL_ZS="." if valueSL_UEM_TOTL_ZS==".."
destring valueSL_UEM_TOTL_ZS, replace

rename valueSL_UEM_TOTL_ZS U_total
rename valueNY_GDP_DEFL_KD_ZG Inflation
rename valueSP_POP_TOTL Population
rename valueBN_KLT_DINV_CD FDI
rename valueBX_KLT_DINV_WD_GD_ZS FDI_percent
rename valueNY_GDP_MKTP_CD GDP
rename valueSL_AGR_EMPL_ZS U_agriculture
rename valueSL_IND_EMPL_ZS U_industry
rename valueSL_SRV_EMPL_ZS U_service
rename valueSL_UEM_ADVN_ZS U_ADVedu
rename valueSL_UEM_BASC_ZS U_BASedu
rename valueSL_UEM_INTM_ZS U_INTedu
rename valueNY_GDP_MKTP_PP_CD GDP_ppp
rename valueNE_CON_GOVT_ZS Gov_size

rename valueJI_EMP_AGRI_ZS employ_craft
rename valueJI_EMP_ELEM_ZS employ_elementary
rename valueJI_EMP_ELEC_ZS employ_electricity
rename valueJI_EMP_FABU_ZS employ_finance
rename valueJI_EMP_INDU_ZS employ_industrial
rename valueJI_EMP_MACH_ZS employ_machine
rename valueJI_EMP_MANF_ZS employ_manufactor
rename valueJI_EMP_MINQ_ZS employ_mining
rename valueJI_EMP_OSRV_ZS employ_otherservice
rename valueJI_EMP_PROF_ZS employ_professional
rename valueJI_EMP_PADM_ZS employ_publicadmin
rename valueJI_EMP_PUBS_ZS employ_publicsector
rename valueJI_EMP_SEOF_ZS employ_senior
rename valueJI_EMP_SERV_ZS employ_serviceandsales
rename employ_serviceandsales employ_service
rename valueJI_EMP_SVMK_ZS employ_serviceandsales
rename valueJI_EMP_SKAG_ZS employ_skilledagriculture
rename valueJI_EMP_TECH_ZS employ_technician
rename valueJI_EMP_TRCM_ZS employ_transport
rename valueJI_EMP_CNST_ZS employ_construction
rename valueJI_EMP_COME_ZS employ_commerce
rename valueJI_EMP_CLRK_ZS employ_clerk
rename valueJI_EMP_ARFC_ZS employ_armedforce
rename employ_craft employ_agriculture
rename valueJI_EMP_CRFT_ZS employ_craft



foreach var in Inflation Population FDI FDI_percent GDP U_agriculture U_industry U_service U_ADVedu U_BASedu U_INTedu GDP_ppp Gov_size DandR{
    replace `var' = "." if `var' == ".."
    destring `var', replace
}

foreach var of varlist _all {
    local vartype : type `var'
    if "`vartype'" == "str17"  {
        replace `var' = subinstr(`var', "..", ".", .)
		destring `var', replace
    }
}

foreach var of varlist _all {
    local vartype : type `var'
    if "`vartype'" == "strL"  {
        replace `var' = subinstr(`var', "..", ".", .)
		destring `var', replace
    }
}

save "/Users/shanqizhang/Desktop/ECON4901/s1155157237/ECON4901/merged_patent_controlvar.dta",replace


egen year_variable = group(year)
en Country, gen (Country_n)
xtset Country_n year
xtset Country_n year_variable
*egen cumulative_patent = total(patent), by(Country)


*create yearly dummy
levelsof year, local(years)

forval i = 1/9 {
    gen y_`i' = 0
    replace y_`i' = 1 if year == 200`i'
}

forval i= 10/17 {
    gen y_`i' = 0
    replace y_`i'= 1 if year ==20`i'
}
rename year Year
rename year_variable Year_variable

*create investment in Ai patent
gen AIinv=AI_portion*DandR
replace AIinv=AIinv*GDP/1000000000


*create dummy for developing countries
gen developing=1
replace developing=0 if Country=="Singapore"|Country=="Finland"|Country=="United Kingdom"|Country=="Ireland"|Country=="Iceland"|Country=="Sweden"|Country=="France"|Country=="Australia"|Country=="Belgium"|Country=="Canada"|Country=="Italy"|Country=="Austria"|Country=="Germany"|Country=="Japan"|Country=="Netherlands"|Country=="Denmark"|Country=="Luxembourg"|Country=="United States"|Country=="Norway"|Country=="Switzerland"

save "/Users/shanqizhang/Desktop/ECON4901/s1155157237/ECON4901/merged_patent_controlvar.dta",replace
