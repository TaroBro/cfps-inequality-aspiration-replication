/* =========================================================================
   CFPS 实证分析 v3 — idea2-6：省级聚合回归
   核心策略改变：
   ✅ 因变量：省级抱负标准差/方差/分位差（聚合到省×年层面）
   ✅ 自变量：省级基尼系数
   ✅ N ≈ 31省 × 5年 = 155个观测（省×年面板）
   ✅ 控制变量：省级平均收入、平均教育、城镇化率等
   ✅ 同时保留个人层面回归（多种聚类策略）
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
    exit 198
}
capture mkdir "$TMPDIR"

capture log close
log using "$OUTDIR\analysis_v3_log.txt", text replace

di _n(5)
di "=========================================================================="
di "  CFPS ANALYSIS v3 — Province-Level Aggregation"
di "  DV: Provincial aspiration dispersion (SD, IQR, variance)"
di "  IV: Provincial Gini coefficient"
di "  Unit: Province × Year (N ≈ 155)"
di "=========================================================================="

* =========================================================================
* PART 1: 加载五期个人数据（与v2相同）
* =========================================================================
di _n(2) ">>> Loading individual data from 5 waves..."

* ---- 2014 ----
use "$CFPS\2014\Stata14\cfps2014adult_201906.dta", clear
keep pid fid14 provcd14 urban14 cfps_gender cfps_birthy qc201 cfps2014eduy income
rename fid14 fid
rename provcd14 provcode
gen year = 2014
gen urban = .
replace urban = 1 if urban14 == 1 | urban14 == 2
replace urban = 0 if urban14 == 0 | urban14 == -2 | urban14 == -3
drop if urban == . & urban14 < .
gen gender = cfps_gender
gen birth_y = cfps_birthy
gen edu_years = cfps2014eduy
gen edu_asp_years = .
replace edu_asp_years = 6  if qc201 == 2
replace edu_asp_years = 9  if qc201 == 3
replace edu_asp_years = 12 if qc201 == 4
replace edu_asp_years = 15 if qc201 == 5
replace edu_asp_years = 16 if qc201 == 6
replace edu_asp_years = 19 if qc201 == 7
replace edu_asp_years = 22 if qc201 == 8
replace edu_asp_years = 0  if qc201 == 9
gen p_income = income
save "$TMPDIR\p2014.dta", replace
di "  2014 loaded"

* ---- 2016 ----
use "$CFPS\2016\Stata14\cfps2016adult_201906.dta", clear
keep pid fid16 provcd16 urban16 cfps_gender cfps_birthy qc201 cfps2016eduy income
rename fid16 fid
rename provcd16 provcode
gen year = 2016
gen urban = .
replace urban = 1 if urban16 == 1 | urban16 == 2
replace urban = 0 if urban16 == 0 | urban16 == -2 | urban16 == -3
drop if urban == . & urban16 < .
gen gender = cfps_gender
gen birth_y = cfps_birthy
gen edu_years = cfps2016eduy
gen edu_asp_years = .
replace edu_asp_years = 6  if qc201 == 2
replace edu_asp_years = 9  if qc201 == 3
replace edu_asp_years = 12 if qc201 == 4
replace edu_asp_years = 15 if qc201 == 5
replace edu_asp_years = 16 if qc201 == 6
replace edu_asp_years = 19 if qc201 == 7
replace edu_asp_years = 22 if qc201 == 8
replace edu_asp_years = 0  if qc201 == 9
gen p_income = income
save "$TMPDIR\p2016.dta", replace
di "  2016 loaded"

* ---- 2018 ----
use "$CFPS\2018\CFPS2018Stata_\cfps2018person_202512.dta", clear
keep pid fid18 provcd18 urban18 gender ibirthy qc201 cfps2018eduy emp_income
rename fid18 fid
rename provcd18 provcode
rename ibirthy birth_y
gen year = 2018
gen urban = .
replace urban = 1 if urban18 >= 1 & urban18 <= 4
replace urban = 0 if urban18 == 0 | urban18 == -2 | (urban18 >= -8 & urban18 <= -3)
drop if urban == . & urban18 < .
gen edu_years = cfps2018eduy
gen edu_asp_years = .
replace edu_asp_years = 6  if qc201 == 2
replace edu_asp_years = 9  if qc201 == 3
replace edu_asp_years = 12 if qc201 == 4
replace edu_asp_years = 15 if qc201 == 5
replace edu_asp_years = 16 if qc201 == 6
replace edu_asp_years = 19 if qc201 == 7
replace edu_asp_years = 22 if qc201 == 8
replace edu_asp_years = 0  if qc201 == 9
gen p_income = emp_income
save "$TMPDIR\p2018.dta", replace
di "  2018 loaded"

* ---- 2020 ----
use "$CFPS\2020\CFPS2020Stata_\cfps2020person_202306.dta", clear
keep pid fid20 provcd20 urban20 gender ibirthy qc201 cfps2020eduy emp_income
rename fid20 fid
rename provcd20 provcode
rename ibirthy birth_y
gen year = 2020
gen urban = .
replace urban = 1 if urban20 == 1 | urban20 == 2
replace urban = 0 if urban20 == 0 | urban20 == -2 | urban20 == -3
drop if urban == . & urban20 < .
gen edu_years = cfps2020eduy
gen edu_asp_years = .
replace edu_asp_years = 6  if qc201 == 2
replace edu_asp_years = 9  if qc201 == 3
replace edu_asp_years = 12 if qc201 == 4
replace edu_asp_years = 15 if qc201 == 5
replace edu_asp_years = 16 if qc201 == 6
replace edu_asp_years = 19 if qc201 == 7
replace edu_asp_years = 22 if qc201 == 8
replace edu_asp_years = 0  if qc201 == 9
gen p_income = emp_income
save "$TMPDIR\p2020.dta", replace
di "  2020 loaded"

* ---- 2022 ----
use "$CFPS\2022\CFPS2022Stata\CFPS2022Stata_解密信息参见Instructions\cfps2022person_202410.dta", clear
keep pid fid22 provcd22 urban22 gender ibirthy qc201 cfps2022eduy emp_income
rename fid22 fid
rename provcd22 provcode
rename ibirthy birth_y
gen year = 2022
gen urban = .
replace urban = 1 if urban22 == 1 | urban22 == 2
replace urban = 0 if urban22 == 0 | urban22 == -2 | urban22 == -3
drop if urban == . & urban22 < .
gen edu_years = cfps2022eduy
gen edu_asp_years = .
replace edu_asp_years = 6  if qc201 == 2
replace edu_asp_years = 9  if qc201 == 3
replace edu_asp_years = 12 if qc201 == 4
replace edu_asp_years = 15 if qc201 == 5
replace edu_asp_years = 16 if qc201 == 6
replace edu_asp_years = 19 if qc201 == 7
replace edu_asp_years = 22 if qc201 == 8
replace edu_asp_years = 0  if qc201 == 9
gen p_income = emp_income
save "$TMPDIR\p2022.dta", replace
di "  2022 loaded"

* ---- 合并 ----
use "$TMPDIR\p2014.dta", clear
append using "$TMPDIR\p2016.dta"
append using "$TMPDIR\p2018.dta"
append using "$TMPDIR\p2020.dta"
append using "$TMPDIR\p2022.dta"
di "  Combined: N = " _N

* =========================================================================
* PART 2: 清洗
* =========================================================================
di _n(2) ">>> Cleaning..."
gen age = year - birth_y
drop if age < 10 | age > 30 | age == .
drop if edu_asp_years == .
destring gender, replace force
drop if gender < 0 | gender == .
drop if urban == . | urban < 0
destring provcode, replace force
drop if provcode == .
keep if inlist(provcode, 11,12,13,14,15,21,22,23,31,32,33,34,35,36,37, ///
                    41,42,43,44,45,46,50,51,52,53,61,62,63,64,65)
* 保留p_income缺失的观测（省级聚合不严格要求个人收入）
drop if p_income < 0 | p_income >= 100000000
gen log_income = ln(p_income + 1) if p_income != . & p_income > 0
replace log_income = 0 if p_income == 0 & p_income != .
destring edu_years, replace force
drop if edu_years < 0 & edu_years != .
di "  After cleaning: N = " _N

save "$TMPDIR\person_all_v3.dta", replace

* =========================================================================
* PART 3: 计算省份×年份基尼系数
* =========================================================================
di _n(2) ">>> Computing Gini..."
clear

use "$CFPS\2014\Stata14\cfps2014famecon_201906.dta", clear
keep fid14 provcd14 fincome1_per
rename fid14 fid
rename provcd14 provcode
gen year = 2014
gen hh_pcincome = fincome1_per
keep fid provcode year hh_pcincome
save "$TMPDIR\fe2014.dta", replace

use "$CFPS\2016\Stata14\cfps2016famecon_201807.dta", clear
keep fid16 provcd16 fincome1_per
rename fid16 fid
rename provcd16 provcode
gen year = 2016
gen hh_pcincome = fincome1_per
keep fid provcode year hh_pcincome
save "$TMPDIR\fe2016.dta", replace

use "$CFPS\2018\CFPS2018Stata_\cfps2018famecon_202512.dta", clear
keep fid18 provcd18 fincome1_per
rename fid18 fid
rename provcd18 provcode
gen year = 2018
gen hh_pcincome = fincome1_per
keep fid provcode year hh_pcincome
save "$TMPDIR\fe2018.dta", replace

use "$CFPS\2020\CFPS2020Stata_\cfps2020famecon_202306.dta", clear
keep fid20 provcd20 fincome1_per
rename fid20 fid
rename provcd20 provcode
gen year = 2020
gen hh_pcincome = fincome1_per
keep fid provcode year hh_pcincome
save "$TMPDIR\fe2020.dta", replace

use "$CFPS\2022\CFPS2022Stata\CFPS2022Stata_解密信息参见Instructions\cfps2022famecon_202410.dta", clear
keep fid22 provcd22 fincome1_per
rename fid22 fid
rename provcd22 provcode
gen year = 2022
gen hh_pcincome = fincome1_per
keep fid provcode year hh_pcincome
save "$TMPDIR\fe2022.dta", replace

use "$TMPDIR\fe2014.dta", clear
append using "$TMPDIR\fe2016.dta"
append using "$TMPDIR\fe2018.dta"
append using "$TMPDIR\fe2020.dta"
append using "$TMPDIR\fe2022.dta"

destring provcode, replace force
destring hh_pcincome, replace force
keep if hh_pcincome > 0 & hh_pcincome < 50000000 & hh_pcincome != .
keep if inlist(provcode, 11,12,13,14,15,21,22,23,31,32,33,34,35,36,37, ///
                     41,42,43,44,45,46,50,51,52,53,61,62,63,64,65)

gen gini_prov = .
gen mean_inc = .
gen N_inc = .

sort provcode year hh_pcincome
levelsof provcode, local(allprovs)
levelsof year, local(allyrs)

foreach pv of local allprovs {
    foreach yr of local allyrs {
        preserve
        keep if provcode == `pv' & year == `yr'
        count
        if r(N) >= 30 & r(N) < . {
            quietly summarize hh_pcincome
            local n = r(N)
            local mu = r(mean)
            if `mu' > 0 {
                gsort +hh_pcincome
                gen _rkpc = _n
                capture corr _rkpc hh_pcincome, cov
                if _rc == 0 {
                    local cov_g = r(cov_12)
                    local gval = (2 * `cov_g') / (`mu' * (`n' + 1))
                    if `gval' > 1 local gval = 1
                    if `gval' < 0 local gval = 0
                    restore
                    replace gini_prov = round(`gval', 0.0001) if provcode == `pv' & year == `yr'
                    replace mean_inc = round(`mu', 1) if provcode == `pv' & year == `yr'
                    replace N_inc = `n' if provcode == `pv' & year == `yr'
                }
                else restore
            }
            else restore
        }
        else restore
    }
}

keep if gini_prov != .
keep provcode year gini_prov mean_inc N_inc
duplicates drop
sort year provcode
di "  Gini records: " _N
save "$TMPDIR\gini_v3.dta", replace

* =========================================================================
* PART 4: 聚合到省×年层面 — 因变量
* =========================================================================
di _n(2) ">>> Aggregating to province-year level..."
use "$TMPDIR\person_all_v3.dta", clear

* --- 排除edu_asp_years==0（"不必读书"，可能是特殊群体）的子样本 ---
gen byte excl_zero = (edu_asp_years > 0)

* --- 主要因变量：抱负离散度指标 ---
* 4a. SD of edu_asp_years by provcode × year
collapse (mean) asp_mean=edu_asp_years ///
         (sd)   asp_sd=edu_asp_years ///
         (min)  asp_min=edu_asp_years ///
         (max)  asp_max=edu_asp_years ///
         (p10)  asp_p10=edu_asp_years ///
         (p25)  asp_p25=edu_asp_years ///
         (p50)  asp_p50=edu_asp_years ///
         (p75)  asp_p75=edu_asp_years ///
         (p90)  asp_p90=edu_asp_years ///
         (iqr)  asp_iqr=edu_asp_years ///
         (count) N_asp=edu_asp_years ///
         (mean) age_mean=age ///
         (mean) gender_mean=gender ///
         (mean) urban_mean=urban ///
         (mean) edu_mean=edu_years ///
         (mean) loginc_mean=log_income ///
         (mean) excl_rate=excl_zero ///
    , by(provcode year)

* --- 范围和四分位距 ---
gen asp_range = asp_max - asp_min
gen asp_iqr2 = asp_p75 - asp_p25
gen asp_p90p10 = asp_p90 - asp_p10
* 90-10差距比例
gen asp_p90p10_ratio = asp_p90 / asp_p10 if asp_p10 > 0

* --- 方差（替代离散度指标）---
* 在collapse时不能直接计算variance，用SD^2近似
gen asp_var = asp_sd^2

* --- 年份固定效应 ---
tab year, gen(yr_)

di "  Province-year observations: " _N
summarize asp_sd asp_var asp_iqr2 asp_p90p10 asp_range

* =========================================================================
* PART 5: 合并基尼系数
* =========================================================================
merge 1:1 provcode year using "$TMPDIR\gini_v3.dta"
tab _merge
drop if _merge == 2
drop _merge

di "  After merge: N = " _N
di "  Gini non-miss: " 
count if gini_prov != .

* Gini标准化
summarize gini_prov
local gm = r(mean)
local gs = r(sd)
gen gini_std = (gini_prov - `gm') / `gs'
gen gini_sq = gini_std^2
di "  Gini mean=`gm', SD=`gs'"

save "$TMPDIR\provyr_panel_v3.dta", replace

* =========================================================================
* PART 6: 省级聚合回归
* =========================================================================
di _n(5) "============================================================="
di "  TABLE 2: PROVINCE-LEVEL REGRESSIONS"
di "  DV = Provincial Aspiration Dispersion"
di "  N ≈ 31 provinces × 5 years"
di "============================================================="

* Model A: SD ~ Gini（基础模型）
regress asp_sd gini_std i.year, robust
est store pa
di "  Model A (SD ~ Gini): N=" e(N) ", Gini b=" _b[gini_std] ", p=" 2*ttail(e(df_r),abs(_b[gini_std]/_se[gini_std]))

* Model B: +省级控制变量
regress asp_sd gini_std age_mean gender_mean urban_mean loginc_mean i.year, robust
est store pb
di "  Model B (+controls): N=" e(N) ", Gini b=" _b[gini_std] ", p=" 2*ttail(e(df_r),abs(_b[gini_std]/_se[gini_std]))

* Model C: Gini^2
regress asp_sd gini_std gini_sq age_mean gender_mean urban_mean loginc_mean i.year, robust
est store pc

* Model D: 原始Gini（非标准化）
regress asp_sd gini_prov age_mean gender_mean urban_mean loginc_mean i.year, robust
est store pd
di "  Model D (raw Gini): N=" e(N) ", Gini b=" _b[gini_prov] ", p=" 2*ttail(e(df_r),abs(_b[gini_prov]/_se[gini_prov]))

* Model E: IQR（四分位距）
regress asp_iqr2 gini_std age_mean gender_mean urban_mean loginc_mean i.year, robust
est store pe
di "  Model E (IQR): N=" e(N) ", Gini b=" _b[gini_std] ", p=" 2*ttail(e(df_r),abs(_b[gini_std]/_se[gini_std]))

* Model F: P90-P10差距
regress asp_p90p10 gini_std age_mean gender_mean urban_mean loginc_mean i.year, robust
est store pf
di "  Model F (P90-P10): N=" e(N) ", Gini b=" _b[gini_std] ", p=" 2*ttail(e(df_r),abs(_b[gini_std]/_se[gini_std]))

* Model G: 方差
regress asp_var gini_std age_mean gender_mean urban_mean loginc_mean i.year, robust
est store pg

* Model H: 范围
regress asp_range gini_std age_mean gender_mean urban_mean loginc_mean i.year, robust
est store ph

esttab pa pb pc pd pe pf pg ph, ///
    b(%9.4f) t(%7.3f) star(* 0.1 ** 0.05 *** 0.01) ///
    drop(*.year) ///
    mtitles("A-SD" "B-Ctrl" "C-Gini2" "D-Raw" "E-IQR" "F-P9010" "G-Var" "H-Range") ///
    title("Table 2: Province-Level Inequality → Aspiration Dispersion")

esttab pa pb pc pd pe pf pg ph using "$OUTDIR\regression_provlevel_v3.csv", ///
    b(%9.4f) t(%7.3f) star(* 0.1 ** 0.05 *** 0.01) ///
    drop(*.year) csv replace ///
    mtitles("A-SD" "B-Ctrl" "C-Gini2" "D-Raw" "E-IQR" "F-P9010" "G-Var" "H-Range")

* =========================================================================
* PART 7: 省份固定效应回归（within estimator）
* =========================================================================
di _n(5) "============================================================="
di "  TABLE 3: Province Fixed Effects"
di "============================================================="

* 省份FE: SD ~ Gini
areg asp_sd gini_std age_mean gender_mean urban_mean loginc_mean i.year, absorb(provcode) robust
est store fe_sd
di "  FE-SD: Gini b=" _b[gini_std] ", p=" 2*ttail(e(df_r),abs(_b[gini_std]/_se[gini_std]))

areg asp_iqr2 gini_std age_mean gender_mean urban_mean loginc_mean i.year, absorb(provcode) robust
est store fe_iqr

areg asp_p90p10 gini_std age_mean gender_mean urban_mean loginc_mean i.year, absorb(provcode) robust
est store fe_p9010

esttab fe_sd fe_iqr fe_p9010 using "$OUTDIR\regression_FE_v3.csv", ///
    b(%9.4f) t(%7.3f) star(* 0.1 ** 0.05 *** 0.01) ///
    drop(*.year) csv replace ///
    mtitles("FE-SD" "FE-IQR" "FE-P90P10")

* =========================================================================
* PART 8: 排除edu_asp=0的稳健性
* =========================================================================
di _n(2) ">>> Robustness: Exclude 'no study needed' (asp=0)..."

* 需要回到个人数据重新聚合
use "$TMPDIR\person_all_v3.dta", clear
drop if edu_asp_years == 0
di "  After excluding asp=0: N = " _N

collapse (mean) asp_mean=edu_asp_years ///
         (sd)   asp_sd=edu_asp_years ///
         (iqr)  asp_iqr2=edu_asp_years ///
         (p90)  asp_p90=edu_asp_years ///
         (p10)  asp_p10=edu_asp_years ///
         (count) N_asp=edu_asp_years ///
         (mean) age_mean=age gender_mean=gender urban_mean=urban ///
         (mean) edu_mean=edu_years loginc_mean=log_income ///
    , by(provcode year)

gen asp_p90p10 = asp_p90 - asp_p10

merge 1:1 provcode year using "$TMPDIR\gini_v3.dta"
drop if _merge == 2
drop _merge

summarize gini_prov
local gm2 = r(mean)
local gs2 = r(sd)
gen gini_std = (gini_prov - `gm2') / `gs2'

regress asp_sd gini_std age_mean gender_mean urban_mean loginc_mean i.year, robust
est store rob_no0
di "  NoZero-SD: Gini b=" _b[gini_std] ", p=" 2*ttail(e(df_r),abs(_b[gini_std]/_se[gini_std]))

regress asp_p90p10 gini_std age_mean gender_mean urban_mean loginc_mean i.year, robust
est store rob_no0_p90
di "  NoZero-P90P10: Gini b=" _b[gini_std] ", p=" 2*ttail(e(df_r),abs(_b[gini_std]/_se[gini_std]))

esttab rob_no0 rob_no0_p90 using "$OUTDIR\robustness_no0_v3.csv", ///
    b(%9.4f) t(%7.3f) star(* 0.1 ** 0.05 *** 0.01) ///
    drop(*.year) csv replace ///
    mtitles("NoZero-SD" "NoZero-P90P10")

* =========================================================================
* PART 9: 个人层面回归 — 不同聚类策略
* =========================================================================
di _n(5) "============================================================="
di "  TABLE 4: Individual-Level Regressions (Alternative Clustering)"
di "============================================================="

use "$TMPDIR\person_all_v3.dta", clear
merge m:1 provcode year using "$TMPDIR\gini_v3.dta", nogen

bysort provcode year: egen asp_mean_provyr = mean(edu_asp_years)
gen asp_dev = edu_asp_years - asp_mean_provyr
gen asp_polar = abs(asp_dev)

summarize gini_prov
gen gini_std = (gini_prov - r(mean)) / r(sd) if gini_prov != .
gen gini_sq = gini_std^2 if gini_std != .

* 9a: 不聚类（异方差稳健）
regress asp_polar age gender urban edu_years gini_std i.year if gini_std != ., vce(robust)
est store ind_robust
di "  Individual-Robust: Gini b=" _b[gini_std] ", p=" 2*ttail(e(df_r),abs(_b[gini_std]/_se[gini_std]))

* 9b: 省份聚类
regress asp_polar age gender urban edu_years gini_std i.year if gini_std != ., vce(cluster provcode)
est store ind_provcl
di "  Individual-ProvinceCluster: Gini b=" _b[gini_std] ", p=" 2*ttail(e(df_r),abs(_b[gini_std]/_se[gini_std]))

* 9c: 省份×年份聚类（三明治估计）
egen provyr = group(provcode year)
regress asp_polar age gender urban edu_years gini_std i.year if gini_std != ., vce(cluster provyr)
est store ind_provyrcl
di "  Individual-ProvYearCluster: Gini b=" _b[gini_std] ", p=" 2*ttail(e(df_r),abs(_b[gini_std]/_se[gini_std]))

* 9d: 使用asp_dev（带符号偏差）而非绝对值
regress asp_dev age gender urban edu_years gini_std i.year if gini_std != ., vce(robust)
est store ind_dev
di "  Individual-Deviation(robust): Gini b=" _b[gini_std] ", p=" 2*ttail(e(df_r),abs(_b[gini_std]/_se[gini_std]))

* 9e: 分位数回归（中位数）
qreg asp_polar age gender urban edu_years gini_std i.year if gini_std != ., q(0.5)
est store ind_q50

* 9f: 分位数回归（75分位）
qreg asp_polar age gender urban edu_years gini_std i.year if gini_std != ., q(0.75)
est store ind_q75

esttab ind_robust ind_provcl ind_provyrcl ind_dev ind_q50 ind_q75, ///
    b(%9.4f) t(%7.3f) star(* 0.1 ** 0.05 *** 0.01) ///
    drop(*.year) ///
    mtitles("Robust" "ProvClust" "ProvYrClust" "Deviation" "Q50" "Q75")

esttab ind_robust ind_provcl ind_provyrcl ind_dev ind_q50 ind_q75 using "$OUTDIR\regression_indiv_v3.csv", ///
    b(%9.4f) t(%7.3f) star(* 0.1 ** 0.05 *** 0.01) ///
    drop(*.year) csv replace ///
    mtitles("Robust" "ProvClust" "ProvYrClust" "Deviation" "Q50" "Q75")

* =========================================================================
* PART 10: 结果保存
* =========================================================================
save "$OUTDIR\provyr_panel_v3.dta", replace

di _n(5) "=========================================================================="
di "  ANALYSIS v3 COMPLETE"
di "=========================================================================="

log close
di "DONE"
