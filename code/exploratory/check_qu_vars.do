/* 检查2018/2020中qu变量和qm变量 */
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
log using "$OUTDIR\check_qu_vars.log", text replace

* === 2020 person ===
use "$CFPS\2020\CFPS2020Stata_\cfps2020person_202306.dta", clear

di _n "========== 2020 PERSON - qu & qm VARIABLES =========="

foreach v in qu201 qu202 qu201a qu202a qu91 qu911 qu92 qu921 qu93 qu931 qu94 qu941 qu951 qu952 qu953 qu954 qu955 qu801 qu802 qu803 qu804 qu805 qu806 qu11 qu111 qu5 {
    di _n "--- `v' ---"
    capture describe `v'
    if _rc == 0 {
        describe `v'
        tab `v', missing
    }
}

* 也查看qm变量（心理模块部分）
di _n "=== QM Variables (2020) ==="
foreach v in qm9 qm501a qm991 qm992 qm6 qm20 qm2011 qm2016 qm1101 qm1102 qm1103 qm1104 qm3011 qm3012 qm3013 qm3014 qm3015 qm3016 qm3017 qme201 qme202 qme203 qme204 qme205 qme206 qme207 qme208 qme209 {
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
