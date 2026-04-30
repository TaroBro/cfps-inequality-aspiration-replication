/* 查找child/childproxy中的教育期望变量 */
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
log using "$OUTDIR\check_child.log", text replace

* === 2014 child ===
di _n "========== 2014 CHILD =========="
use "$CFPS\2014\Stata14\cfps2014child_201906.dta", clear
describe, short
di _n "--- All variable names ---"
describe, simple

* === 2018 childproxy ===
di _n _n "========== 2018 CHILDPROXY =========="
use "$CFPS\2018\CFPS2018Stata_\cfps2018childproxy_202512.dta", clear
describe, short
di _n "--- All variable names ---"
describe, simple

* === 2020 childproxy ===
di _n _n "========== 2020 CHILDPROXY =========="
use "$CFPS\2020\CFPS2020Stata_\cfps2020childproxy_202306.dta", clear
describe, short
di _n "--- All variable names ---"
describe, simple

* === 2022 childproxy ===
di _n _n "========== 2022 CHILDPROXY =========="
use "$CFPS\2022\CFPS2022Stata\CFPS2022Stata_解密信息参见Instructions\cfps2022childproxy_202410.dta", clear
describe, short
di _n "--- All variable names ---"
describe, simple

log close
