/* 检查各期CFPS person/adult数据中教育抱负变量qp201的值标签 */
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
    exit 198
}

capture log close
log using "$OUTDIR\check_qa_vars.log", text replace

* === 2014 adult - 查找主观社会阶层、未来信心等变量 ===
di _n "========== 2014 ADULT =========="
use "$CFPS\2014\Stata14\cfps2014adult_201906.dta", clear

di _n "=== qp201 ==="
tab qp201, missing nolabel
di _n "=== qp201 (with label) ==="
tab qp201, missing

di _n "=== qp202 ==="
tab qp202, missing

di _n "=== qea204 (subjective class) ==="
tab qea204, missing

* 查找所有qa开头变量
describe qa* qea* 

* === 2018 person ===
di _n _n "========== 2018 PERSON =========="
use "$CFPS\2018\CFPS2018Stata_\cfps2018person_202512.dta", clear

di _n "=== qp201 ==="
tab qp201, missing

di _n "=== qea204 ==="
tab qea204, missing

* 查找qu变量（期望/未来相关）
di _n "=== qu variables ==="
capture describe qu*, simple
if _rc {
    di "No qu variables"
}

* === 2020 person ===
di _n _n "========== 2020 PERSON =========="
use "$CFPS\2020\CFPS2020Stata_\cfps2020person_202306.dta", clear

di _n "=== qp201 ==="
tab qp201, missing

di _n "=== qea204 ==="
tab qea204, missing

* 查找所有期望/主观相关变量
di _n "=== qu variables ==="
capture describe qu*, simple
if _rc {
    di "No qu variables"
}

* 查找qm变量
di _n "=== qm variables ==="
describe qm*, simple

* 查找所有变量（选择关键变量）
describe qp* qea* qa* qu*, simple

log close
