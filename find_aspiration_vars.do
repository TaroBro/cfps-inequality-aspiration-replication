/* 搜索CFPS各期adult/person中与"抱负"相关的变量
   重点搜索：主观社会地位、未来信心、未来预期收入
*/
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
log using "$OUTDIR\find_aspiration_vars.log", text replace

* ==========================================
* 2014 adult
* ==========================================
di _n "========== 2014 ADULT - KEY VARIABLES =========="
use "$CFPS\2014\Stata14\cfps2014adult_201906.dta", clear

* 搜索含"收入"的变量
di _n "--- Variables containing 'income' ---"
lookfor income

* 搜索"社会" 或 "地位" 或 "信心" 或 "未来"
* 通过描述变量标签搜索
describe, fullnames

* ==========================================
* 2018 person
* ==========================================
di _n _n "========== 2018 PERSON - KEY VARIABLES =========="
use "$CFPS\2018\CFPS2018Stata_\cfps2018person_202512.dta", clear

* 所有含"income"的变量
di _n "--- Variables containing 'income' ---"
lookfor income

* wv变量可能是社会经济地位相关
di _n "--- wv variables ---"
foreach v in wv101 wv102 wv103 wv104 wv105 wv106 wv107 wv108 wv1 {
    di _n "--- `v' ---"
    capture describe `v'
    if _rc == 0 {
        describe `v'
        tab `v', missing
    }
}

* qm心理模块（非QM传统量表，而是心理/认知类）
di _n "=== qm9 ==="
describe qm9
tab qm9, missing

di _n "=== qm20 ==="
describe qm20
summarize qm20, detail

di _n "=== qm6 ==="
describe qm6
tab qm6, missing

di _n "=== qm501a ==="
describe qm501a
tab qm501a, missing

* ==========================================
* 2020 person
* ==========================================
di _n _n "========== 2020 PERSON - KEY VARIABLES =========="
use "$CFPS\2020\CFPS2020Stata_\cfps2020person_202306.dta", clear

* wv变量
di _n "--- wv variables ---"
foreach v in wv101 wv102 wv103 wv104 wv105 wv106 wv107 wv108 wv1 {
    di _n "--- `v' ---"
    capture describe `v'
    if _rc == 0 {
        describe `v'
        tab `v', missing
    }
}

* qm变量
di _n "=== qm9 ==="
describe qm9
tab qm9, missing

di _n "=== qm20 ==="
describe qm20
summarize qm20, detail

di _n "=== qm6 ==="
describe qm6
tab qm6, missing

* qm801-qm803
foreach v in qm801 qm802 qm803 {
    di _n "--- `v' ---"
    capture describe `v'
    if _rc == 0 {
        describe `v'
        tab `v', missing
    }
}

* ==========================================
* 2022 person  
* ==========================================
di _n _n "========== 2022 PERSON - KEY VARIABLES =========="
use "$CFPS\2022\CFPS2022Stata\CFPS2022Stata_解密信息参见Instructions\cfps2022person_202410.dta", clear

* qm变量
di _n "--- qm variables ---"
foreach v in qm2011 qm2016 qm3n qm6 qm1001 qm1002 qm1003 qm1004 qm1005 qm1006 qm501a qms1 qms2 qms3 qms4 qm20 qme201 qme202 qme203 qme204 qme205 qme206 qme207 qme208 qme209 {
    di _n "--- `v' ---"
    capture describe `v'
    if _rc == 0 {
        describe `v'
        capture tab `v', missing
        if _rc {
            capture summarize `v`, detail
        }
    }
}

* wv变量
di _n "--- wv variables ---"
foreach v in wv101 wv102 wv103 wv104 wv105 wv106 wv107 wv108 wv1 {
    di _n "--- `v' ---"
    capture describe `v'
    if _rc == 0 {
        describe `v'
        capture tab `v', missing
        if _rc {
            capture summarize `v', detail
        }
    }
}

* qv变量
di _n "--- qv variables ---"
foreach v in qv01 qv02 qv03 qv04 qv101a qv101c qv102 qv103code qv103code_q qv103code_qi qv103code_qs qv104 qv201y qv201b qv202 qv203code qv203code_q qv203code_qi qv203code_qs qv204 {
    di _n "--- `v' ---"
    capture describe `v'
    if _rc == 0 {
        describe `v'
        capture tab `v', missing
        if _rc {
            capture summarize `v', detail
        }
    }
}

log close
