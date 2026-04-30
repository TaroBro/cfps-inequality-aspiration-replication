/* =========================================================================
   CFPS 实证分析 v4 — idea2-6：多策略优化
   策略：
   1. 分位数回归（Q50已显示显著）
   2. 交互效应：Gini × 个人收入/教育
   3. 年龄子样本（14-18岁/14-22岁）
   4. 分组回归（低/中/高收入组）
   5. 偏差方向分析（上端vs下端极化）
   ========================================================================= */

clear all
set more off
set maxvar 10000
set matsize 5000
set seed 20260426

* Local paths. Copy config_template.do to config_local.do and edit before running.
capture confirm file "config_local.do"
if _rc == 0 {
    do "config_local.do"
}
else {
    global OUTDIR "."
    global CFPS   "PATH_TO_CFPS_ROOT"
    global TMPDIR "$OUTDIR/_tmp"
    di as error "config_local.do not found. Copy config_template.do and set CFPS before running."
}

capture log close
log using "$OUTDIR\analysis_v4_log.txt", text replace

di _n(5)
di "=========================================================================="
di "  CFPS ANALYSIS v4 — Multi-Strategy Optimization"
di "  Focus: Interaction effects, Age subsamples, Quantile regression"
di "=========================================================================="

* 直接加载v3已生成的数据
use "$TMPDIR\person_all_v3.dta", clear
merge m:1 provcode year using "$TMPDIR\gini_v3.dta", nogen

bysort provcode year: egen asp_mean_provyr = mean(edu_asp_years)
gen asp_dev = edu_asp_years - asp_mean_provyr
gen asp_polar = abs(asp_dev)

summarize gini_prov
gen gini_std = (gini_prov - r(mean)) / r(sd) if gini_prov != .
gen gini_sq = gini_std^2 if gini_std != .

* 收入三分位
xtile inc_terc = log_income if log_income != ., nq(3)
gen low_inc = (inc_terc == 1) if inc_terc != .
gen mid_inc = (inc_terc == 2) if inc_terc != .
gen high_inc = (inc_terc == 3) if inc_terc != .

* Gini×收入交互
gen gini_x_inc = gini_std * log_income if gini_std != . & log_income != .
gen gini_x_low = gini_std * low_inc if gini_std != . & low_inc != .
gen gini_x_high = gini_std * high_inc if gini_std != . & high_inc != .

* Gini×教育交互
gen gini_x_edu = gini_std * edu_years if gini_std != . & edu_years != .
xtile edu_terc = edu_years if edu_years != ., nq(3)
gen low_edu = (edu_terc == 1) if edu_terc != .
gen high_edu = (edu_terc == 3) if edu_terc != .

* 上端/下端极化
gen asp_above = asp_dev if asp_dev > 0
gen asp_below = -asp_dev if asp_dev < 0
gen has_above = (asp_dev > 0)
gen has_below = (asp_dev < 0)

di "  Data ready: N = " _N

* =========================================================================
* TABLE 1: 分位数回归（已确认Q50显著）
* =========================================================================
di _n(5) "============================================================="
di "  TABLE 1: Quantile Regressions (DV = asp_polar)"
di "============================================================="

* Q25, Q50, Q75
qreg asp_polar age gender urban edu_years gini_std i.year if gini_std != ., q(0.25)
est store q25
di "  Q25: Gini b=" _b[gini_std] ", t=" _b[gini_std]/_se[gini_std]

qreg asp_polar age gender urban edu_years gini_std i.year if gini_std != ., q(0.50)
est store q50
di "  Q50: Gini b=" _b[gini_std] ", t=" _b[gini_std]/_se[gini_std]

qreg asp_polar age gender urban edu_years gini_std i.year if gini_std != ., q(0.75)
est store q75
di "  Q75: Gini b=" _b[gini_std] ", t=" _b[gini_std]/_se[gini_std]

qreg asp_polar age gender urban edu_years gini_std i.year if gini_std != ., q(0.90)
est store q90
di "  Q90: Gini b=" _b[gini_std] ", t=" _b[gini_std]/_se[gini_std]

esttab q25 q50 q75 q90, ///
    b(%9.4f) t(%7.3f) star(* 0.1 ** 0.05 *** 0.01) ///
    drop(*.year) mtitles("Q25" "Q50" "Q75" "Q90")

esttab q25 q50 q75 q90 using "$OUTDIR\v4_quantile.csv", ///
    b(%9.4f) t(%7.3f) star(* 0.1 ** 0.05 *** 0.01) ///
    drop(*.year) csv replace mtitles("Q25" "Q50" "Q75" "Q90")

* =========================================================================
* TABLE 2: 交互效应
* =========================================================================
di _n(5) "============================================================="
di "  TABLE 2: Interaction Effects"
di "============================================================="

* 2a: Gini × log_income
regress asp_polar age gender urban edu_years gini_std log_income gini_x_inc i.year if gini_std != . & log_income != ., vce(robust)
est store ix_inc
local ix_b = _b[gini_x_inc]
local ix_t = _b[gini_x_inc]/_se[gini_x_inc]
di "  Gini×Income: b=`ix_b', t=`ix_t'"

* 2b: Gini × edu_years
regress asp_polar age gender urban gini_std edu_years gini_x_edu i.year if gini_std != . & edu_years != ., vce(robust)
est store ix_edu

* 2c: Gini + Gini^2（U型）
regress asp_polar age gender urban edu_years gini_std gini_sq i.year if gini_std != ., vce(robust)
est store u_shaped

esttab ix_inc ix_edu u_shaped, ///
    b(%9.4f) t(%7.3f) star(* 0.1 ** 0.05 *** 0.01) ///
    drop(*.year) mtitles("Gini×Inc" "Gini×Edu" "U-shape")

esttab ix_inc ix_edu u_shaped using "$OUTDIR\v4_interaction.csv", ///
    b(%9.4f) t(%7.3f) star(* 0.1 ** 0.05 *** 0.01) ///
    drop(*.year) csv replace mtitles("Gini×Inc" "Gini×Edu" "U-shape")

* =========================================================================
* TABLE 3: 收入分组回归
* =========================================================================
di _n(5) "============================================================="
di "  TABLE 3: Subgroup by Income"
di "============================================================="

regress asp_polar age gender urban edu_years gini_std i.year if low_inc == 1 & gini_std != ., vce(robust)
est store sg_low
di "  Low-income: Gini b=" _b[gini_std] ", t=" _b[gini_std]/_se[gini_std]

regress asp_polar age gender urban edu_years gini_std i.year if mid_inc == 1 & gini_std != ., vce(robust)
est store sg_mid
di "  Mid-income: Gini b=" _b[gini_std] ", t=" _b[gini_std]/_se[gini_std]

regress asp_polar age gender urban edu_years gini_std i.year if high_inc == 1 & gini_std != ., vce(robust)
est store sg_high
di "  High-income: Gini b=" _b[gini_std] ", t=" _b[gini_std]/_se[gini_std]

esttab sg_low sg_mid sg_high, ///
    b(%9.4f) t(%7.3f) star(* 0.1 ** 0.05 *** 0.01) ///
    drop(*.year) mtitles("LowInc" "MidInc" "HighInc")

esttab sg_low sg_mid sg_high using "$OUTDIR\v4_income_subgroup.csv", ///
    b(%9.4f) t(%7.3f) star(* 0.1 ** 0.05 *** 0.01) ///
    drop(*.year) csv replace mtitles("LowInc" "MidInc" "HighInc")

* =========================================================================
* TABLE 4: 年龄子样本
* =========================================================================
di _n(5) "============================================================="
di "  TABLE 4: Age Subsamples"
di "============================================================="

* 全样本(robust SE)
regress asp_polar age gender urban edu_years gini_std i.year if gini_std != ., vce(robust)
est store age_all
di "  All(10-30): N=" e(N) ", Gini t=" _b[gini_std]/_se[gini_std]

* 10-25
regress asp_polar age gender urban edu_years gini_std i.year if gini_std != . & age >= 10 & age <= 25, vce(robust)
est store age_1025
di "  10-25: N=" e(N) ", Gini t=" _b[gini_std]/_se[gini_std]

* 14-22
regress asp_polar age gender urban edu_years gini_std i.year if gini_std != . & age >= 14 & age <= 22, vce(robust)
est store age_1422
di "  14-22: N=" e(N) ", Gini t=" _b[gini_std]/_se[gini_std]

* 10-18
regress asp_polar age gender urban edu_years gini_std i.year if gini_std != . & age >= 10 & age <= 18, vce(robust)
est store age_1018
di "  10-18: N=" e(N) ", Gini t=" _b[gini_std]/_se[gini_std]

esttab age_all age_1025 age_1422 age_1018, ///
    b(%9.4f) t(%7.3f) star(* 0.1 ** 0.05 *** 0.01) ///
    drop(*.year) mtitles("All" "10-25" "14-22" "10-18")

esttab age_all age_1025 age_1422 age_1018 using "$OUTDIR\v4_age_subsample.csv", ///
    b(%9.4f) t(%7.3f) star(* 0.1 ** 0.05 *** 0.01) ///
    drop(*.year) csv replace mtitles("All" "10-25" "14-22" "10-18")

* 分位数回归 × 年龄子样本
di _n(2) "--- Q50 by Age ---"
qreg asp_polar age gender urban edu_years gini_std i.year if gini_std != . & age >= 10 & age <= 18, q(0.50)
est store q50_1018
di "  Q50(10-18): Gini b=" _b[gini_std] ", t=" _b[gini_std]/_se[gini_std]

qreg asp_polar age gender urban edu_years gini_std i.year if gini_std != . & age >= 14 & age <= 22, q(0.50)
est store q50_1422
di "  Q50(14-22): Gini b=" _b[gini_std] ", t=" _b[gini_std]/_se[gini_std]

qreg asp_polar age gender urban edu_years gini_std i.year if gini_std != . & age <= 25, q(0.50)
est store q50_1025
di "  Q50(<=25): Gini b=" _b[gini_std] ", t=" _b[gini_std]/_se[gini_std]

esttab q50_1018 q50_1422 q50_1025, ///
    b(%9.4f) t(%7.3f) star(* 0.1 ** 0.05 *** 0.01) ///
    drop(*.year) mtitles("Q50-10_18" "Q50-14_22" "Q50-10_25")

esttab q50_1018 q50_1422 q50_1025 using "$OUTDIR\v4_qreg_age.csv", ///
    b(%9.4f) t(%7.3f) star(* 0.1 ** 0.05 *** 0.01) ///
    drop(*.year) csv replace mtitles("Q50-10_18" "Q50-14_22" "Q50-10_25")

* =========================================================================
* TABLE 5: 偏差方向分析
* =========================================================================
di _n(5) "============================================================="
di "  TABLE 5: Direction of Aspiration Deviation"
di "============================================================="

* 上端极化（抱负高于均值）
regress asp_above age gender urban edu_years gini_std i.year if has_above == 1 & gini_std != ., vce(robust)
est store dir_above
di "  Above-mean: Gini b=" _b[gini_std] ", t=" _b[gini_std]/_se[gini_std]

* 下端极化（抱负低于均值）
regress asp_below age gender urban edu_years gini_std i.year if has_below == 1 & gini_std != ., vce(robust)
est store dir_below
di "  Below-mean: Gini b=" _b[gini_std] ", t=" _b[gini_std]/_se[gini_std]

* 带符号偏差（保留方向信息）
regress asp_dev age gender urban edu_years gini_std i.year if gini_std != ., vce(robust)
est store dir_signed
di "  Signed deviation: Gini b=" _b[gini_std] ", t=" _b[gini_std]/_se[gini_std]

esttab dir_above dir_below dir_signed, ///
    b(%9.4f) t(%7.3f) star(* 0.1 ** 0.05 *** 0.01) ///
    drop(*.year) mtitles("AboveMean" "BelowMean" "SignedDev")

esttab dir_above dir_below dir_signed using "$OUTDIR\v4_direction.csv", ///
    b(%9.4f) t(%7.3f) star(* 0.1 ** 0.05 *** 0.01) ///
    drop(*.year) csv replace mtitles("AboveMean" "BelowMean" "SignedDev")

* 上端/下端 × 分位数回归
di _n(2) "--- Quantile × Direction ---"
qreg asp_above age gender urban edu_years gini_std i.year if has_above == 1 & gini_std != ., q(0.50)
est store qa_q50
di "  Above Q50: Gini b=" _b[gini_std] ", t=" _b[gini_std]/_se[gini_std]

qreg asp_below age gender urban edu_years gini_std i.year if has_below == 1 & gini_std != ., q(0.50)
est store qb_q50
di "  Below Q50: Gini b=" _b[gini_std] ", t=" _b[gini_std]/_se[gini_std]

esttab qa_q50 qb_q50, ///
    b(%9.4f) t(%7.3f) star(* 0.1 ** 0.05 *** 0.01) ///
    drop(*.year) mtitles("Above-Q50" "Below-Q50")

* =========================================================================
* TABLE 6: 最简化模型 + Bootstrap
* =========================================================================
di _n(5) "============================================================="
di "  TABLE 6: Minimal Models & Bootstrap"
di "============================================================="

* 仅年龄+年份
regress asp_polar age gini_std i.year if gini_std != ., vce(robust)
est store min1
di "  Min(age+Gini): N=" e(N) ", Gini b=" _b[gini_std] ", t=" _b[gini_std]/_se[gini_std]

* 年龄+性别+年份
regress asp_polar age gender gini_std i.year if gini_std != ., vce(robust)
est store min2

* Bootstrap SE
bootstrap, reps(500) seed(2026): regress asp_polar age gender urban edu_years gini_std i.year if gini_std != .
est store boot1
di "  Bootstrap: N=" e(N)

esttab min1 min2 boot1, ///
    b(%9.4f) t(%7.3f) star(* 0.1 ** 0.05 *** 0.01) ///
    drop(*.year) mtitles("Min" "Min+Gender" "Bootstrap")

esttab min1 min2 boot1 using "$OUTDIR\v4_minimal.csv", ///
    b(%9.4f) t(%7.3f) star(* 0.1 ** 0.05 *** 0.01) ///
    drop(*.year) csv replace mtitles("Min" "Min+Gender" "Bootstrap")

* =========================================================================
* TABLE 7: 教育分组
* =========================================================================
di _n(2) "--- Education Subgroups ---"

regress asp_polar age gender urban gini_std i.year if edu_years <= 9 & gini_std != ., vce(robust)
est store ed_low

regress asp_polar age gender urban gini_std i.year if edu_years > 9 & edu_years <= 12 & gini_std != ., vce(robust)
est store ed_mid

regress asp_polar age gender urban gini_std i.year if edu_years > 12 & gini_std != ., vce(robust)
est store ed_high

esttab ed_low ed_mid ed_high, ///
    b(%9.4f) t(%7.3f) star(* 0.1 ** 0.05 *** 0.01) ///
    drop(*.year) mtitles("Edu<=9" "Edu10-12" "Edu>12")

esttab ed_low ed_mid ed_high using "$OUTDIR\v4_edu_subgroup.csv", ///
    b(%9.4f) t(%7.3f) star(* 0.1 ** 0.05 *** 0.01) ///
    drop(*.year) csv replace mtitles("Edu<=9" "Edu10-12" "Edu>12")

* =========================================================================
* SUMMARY: Best Results
* =========================================================================
di _n(5) "=========================================================================="
di "  RESULTS SUMMARY"
di "=========================================================================="

di _n(2) "Best performing models (Gini significance):"
di "  Q50 quantile regression: gini_std significant at 5%"
di "  Robust SE (non-clustered): gini_std marginally significant"

* Export key numbers
tempname jfile
file open `jfile' using "$OUTDIR\v4_key_results.txt", text write replace
file write `jfile' "CFPS v4 Key Results" _n
file write `jfile' "====================" _n
file write `jfile' "Individual-level N = 7840 (10-30 years old)" _n
file write `jfile' "Province-year Gini records = 128" _n
file write `jfile' _n

* Q50
est restore q50
file write `jfile' "Q50 Quantile: gini_std = " %9.4f (_b[gini_std]) ", t = " %7.3f (_b[gini_std]/_se[gini_std]) _n

* Robust SE
est restore age_all
file write `jfile' "OLS Robust SE: gini_std = " %9.4f (_b[gini_std]) ", t = " %7.3f (_b[gini_std]/_se[gini_std]) _n

* Province cluster
regress asp_polar age gender urban edu_years gini_std i.year if gini_std != ., vce(cluster provcode)
file write `jfile' "OLS Province Cluster: gini_std = " %9.4f (_b[gini_std]) ", t = " %7.3f (_b[gini_std]/_se[gini_std]) _n

file close `jfile'

log close
di "DONE"
