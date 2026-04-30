/* 查找CFPS 2022中的抱负相关变量 - 重点搜索 */
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
log using "$OUTDIR\explore_2022_v3.log", text replace

use "$CFPS\2022\CFPS2022Stata\CFPS2022Stata_解密信息参见Instructions\cfps2022person_202410.dta", clear

* === 搜索所有变量描述中含"抱负" "期望" "收入" "未来" "信心" 的变量 ===

* qg1201_min / qg1201_max / qg1201_est 看起来像预期收入区间
di _n "=== qg1201_min (预期收入下限?) ==="
summarize qg1201_min, detail

di _n "=== qg1201_max (预期收入上限?) ==="
summarize qg1201_max, detail

di _n "=== qg1201_est (预期收入估计?) ==="
summarize qg1201_est, detail

* qg1202/qg1203/qg1204 也可能是预期相关
di _n "=== qg1202 ==="
summarize qg1202, detail

di _n "=== qg1203 ==="
summarize qg1203, detail

di _n "=== qg1204_min ==="
summarize qg1204_min, detail

di _n "=== qg1204_max ==="
summarize qg1204_max, detail

di _n "=== qg1204_est ==="
summarize qg1204_est, detail

* qg1301 - qg1305
di _n "=== qg1301 ==="
tab qg1301, missing

di _n "=== qg1302 ==="
summarize qg1302, detail

di _n "=== qg1303 ==="
tab qg1303, missing

di _n "=== qg1304 ==="
tab qg1304, missing

di _n "=== qg1305 ==="
tab qg1305, missing

* qu变量 (可能涉及期望/信心)
di _n "=== qu201 (未来?) ==="
tab qu201, missing

di _n "=== qu201a ==="
tab qu201a, missing

di _n "=== qu5 ==="
summarize qu5, detail

di _n "=== qu501 ==="
summarize qu501, detail

di _n "=== qu11 ==="
tab qu11, missing

di _n "=== qu91 ==="
tab qu91, missing

di _n "=== qu92 ==="
tab qu92, missing

di _n "=== qu93 ==="
tab qu93, missing

di _n "=== qu94 ==="
tab qu94, missing

di _n "=== qu951 ==="
tab qu951, missing

di _n "=== qu952 ==="
tab qu952, missing

* qea模块 (社会经济)
di _n "=== qea0 ==="
tab qea0, missing

di _n "=== qea1 ==="
tab qea1, missing

di _n "=== qea2 ==="
tab qea2, missing

di _n "=== qea201y ==="
summarize qea201y, detail

di _n "=== qea201m ==="
summarize qea201m, detail

di _n "=== qea202 ==="
tab qea202, missing

di _n "=== qea203code ==="
tab qea203code, missing

* eeb变量 (自评)
di _n "=== eeb1 ==="
tab eeb1, missing

di _n "=== eeb2 ==="
tab eeb2, missing

* 收入变量
di _n "=== emp_income ==="
summarize emp_income, detail

di _n "=== incomea ==="
summarize incomea, detail

di _n "=== incomeb ==="
summarize incomeb, detail

* 检查 qi201_i 区间
di _n "=== qi201_s_1 to qi201_a_5 ==="
foreach v in qi201_s_1 qi201_s_2 qi201_s_3 qi201_s_4 qi201_s_5 qi201_a_1 qi201_a_2 qi201_a_3 qi201_a_4 qi201_a_5 qi201_a_6 qi201_a_7 qi201_a_77 qi201_a_78 {
    di _n "--- `v' ---"
    capture tab `v', missing
    if _rc {
        capture summarize `v`, detail
    }
}

log close
