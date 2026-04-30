/* 查找qc201（期望的受教育程度）在所有年份的分布 */
clear all
set more off
set maxvar 10000

capture confirm file "config_local.do"
if _rc == 0 {
    do "config_local.do"
}
else {
    global OUTDIR "."
    global CFPS   "PATH_TO_CFPS_ROOT"
    di as error "config_local.do not found. Copy config_template.do and set CFPS before running."
}

capture log close
log using "$OUTDIR\check_qc201.log", text replace

* === 2014 adult ===
di _n "========== 2014 ADULT - qc201 =========="
use "$CFPS\2014\Stata14\cfps2014adult_201906.dta", clear
describe qc201
tab qc201, missing

* === 2016 adult ===
di _n _n "========== 2016 ADULT - qc201 =========="
use "$CFPS\2016\Stata14\cfps2016adult_201906.dta", clear
capture describe qc201
if _rc == 0 {
    describe qc201
    tab qc201, missing
}
else {
    di "qc201 NOT FOUND in 2016 adult"
    * 查找替代变量
    describe, fullnames | findstr "期望"
}

* === 2018 person ===
di _n _n "========== 2018 PERSON - qc201 =========="
use "$CFPS\2018\CFPS2018Stata_\cfps2018person_202512.dta", clear
capture describe qc201
if _rc == 0 {
    describe qc201
    tab qc201, missing
}
else {
    di "qc201 NOT FOUND in 2018 person"
}

* === 2020 person ===
di _n _n "========== 2020 PERSON - qc201 =========="
use "$CFPS\2020\CFPS2020Stata_\cfps2020person_202306.dta", clear
capture describe qc201
if _rc == 0 {
    describe qc201
    tab qc201, missing
}
else {
    di "qc201 NOT FOUND in 2020 person"
}

* === 2022 person ===
di _n _n "========== 2022 PERSON - qc201 =========="
use "$CFPS\2022\CFPS2022Stata\CFPS2022Stata_解密信息参见Instructions\cfps2022person_202410.dta", clear
capture describe qc201
if _rc == 0 {
    describe qc201
    tab qc201, missing
}
else {
    di "qc201 NOT FOUND in 2022 person"
}

log close
