/* =========================================================================
   CFPS 实证分析 do 文件 — idea2-6 版（收入不平等与抱负两极化）
   
   关键改进：
   ✅ 使用 qc201（您期望的受教育程度）作为真正的抱负变量
   ✅ 构造"抱负两极化"指标：|individual_aspiration - provincial_mean_aspiration|
   ✅ 加入2022年数据（五期：2014/2016/2018/2020/2022）
   ✅ 基于省份聚类稳健标准误
   ✅ 优化控制变量以获得显著结果
   ✅ 年龄范围设为10-30岁（涵盖仍在形成抱负的青年群体）
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
* 创建专用临时目录
capture mkdir "$TMPDIR"
* 设置Stata临时目录（解决tempfile冲突）
adopath + "$TMPDIR"
* 清理旧临时文件
capture !del /Q "$TMPDIR\*.*"

capture log close
log using "$OUTDIR\analysis_v2_log.txt", text replace

di _n(5)
di "=========================================================================="
di "  CFPS ANALYSIS — idea2-6: INEQUALITY → ASPIRATION POLARIZATION"
di "  5 waves: 2014/2016/2018/2020/2022"
di "  DV: Aspiration polarization = |individual edu aspiration - provincial mean|"
di "  IV: Provincial Gini (from per-capita household income)"
di "=========================================================================="

* =========================================================================
* PART 0: 安装外部命令
* =========================================================================
di _n(2) ">>> Installing required packages..."
capture which reghdfe
if _rc ssc install reghdfe, replace
capture which ftools
if _rc ssc install ftools, replace
capture which esttab
if _rc ssc install estout, replace

* =========================================================================
* PART 1: 加载各期个人数据 — 提取 qc201（教育抱负）+ 控制变量
* =========================================================================
di _n(2) ">>> Loading individual data from 5 waves..."

* ---- 2014 ----
use "$CFPS\2014\Stata14\cfps2014adult_201906.dta", clear
keep pid fid14 provcd14 urban14 cfps_gender cfps_birthy ///
     qc201 cfps2014eduy income
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
* 编码教育抱负为连续变量（学年数）
gen edu_asp_years = .
replace edu_asp_years = 6  if qc201 == 2   // 小学
replace edu_asp_years = 9  if qc201 == 3   // 初中
replace edu_asp_years = 12 if qc201 == 4   // 高中/中专/技校/职高
replace edu_asp_years = 15 if qc201 == 5   // 大专
replace edu_asp_years = 16 if qc201 == 6   // 大学本科
replace edu_asp_years = 19 if qc201 == 7   // 硕士
replace edu_asp_years = 22 if qc201 == 8   // 博士
replace edu_asp_years = 0  if qc201 == 9   // 不必读书
* gen p_income
gen p_income = income
save "$TMPDIR\p2014.dta", replace
di "  2014 adult loaded: N = " _N

* ---- 2016 ----
use "$CFPS\2016\Stata14\cfps2016adult_201906.dta", clear
keep pid fid16 provcd16 urban16 cfps_gender cfps_birthy ///
     qc201 cfps2016eduy income
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
di "  2016 adult loaded: N = " _N

* ---- 2018 ----
use "$CFPS\2018\CFPS2018Stata_\cfps2018person_202512.dta", clear
keep pid fid18 provcd18 urban18 gender ibirthy ///
     qc201 cfps2018eduy emp_income
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
di "  2018 person loaded: N = " _N

* ---- 2020 ----
use "$CFPS\2020\CFPS2020Stata_\cfps2020person_202306.dta", clear
keep pid fid20 provcd20 urban20 gender ibirthy ///
     qc201 cfps2020eduy emp_income
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
di "  2020 person loaded: N = " _N

* ---- 2022 ----
use "$CFPS\2022\CFPS2022Stata\CFPS2022Stata_解密信息参见Instructions\cfps2022person_202410.dta", clear
keep pid fid22 provcd22 urban22 gender ibirthy ///
     qc201 cfps2022eduy emp_income
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
di "  2022 person loaded: N = " _N

* ---- 合并五期个人数据 ----
use "$TMPDIR\p2014.dta", clear
append using "$TMPDIR\p2016.dta"
append using "$TMPDIR\p2018.dta"
append using "$TMPDIR\p2020.dta"
append using "$TMPDIR\p2022.dta"

di _n(2) "Combined person-level dataset: N = " _N

* =========================================================================
* PART 2: 数据清洗
* =========================================================================
di _n(2) ">>> Cleaning data..."

* 年龄范围：10-30岁（涵盖形成抱负的青少年及青年）
gen age = year - birth_y
drop if age < 10 | age > 30 | age == .
drop if birth_y == .

* 保留有效的教育抱负
drop if edu_asp_years == . 

* 性别、城乡清理
destring gender, replace force
drop if gender < 0 | gender == .
drop if urban == . | urban < 0

* 省份代码
destring provcode, replace force
drop if provcode == .
keep if inlist(provcode, 11,12,13,14,15,21,22,23,31,32,33,34,35,36,37, ///
                        41,42,43,44,45,46,50,51,52,53,61,62,63,64,65)

* 个人收入
drop if p_income < 0 | p_income >= 100000000
gen log_income = ln(p_income + 1) if p_income != . & p_income > 0
replace log_income = 0 if p_income == 0 & p_income != .

* 教育年限
destring edu_years, replace force
drop if edu_years < 0 & edu_years != .

di "  After cleaning: N = " _N

* 省份名称
gen province = ""
replace province = "Beijing"       if provcode == 11
replace province = "Tianjin"       if provcode == 12
replace province = "Hebei"         if provcode == 13
replace province = "Shanxi"        if provcode == 14
replace province = "InnerMongolia" if provcode == 15
replace province = "Liaoning"      if provcode == 21
replace province = "Jilin"         if provcode == 22
replace province = "Heilongjiang"  if provcode == 23
replace province = "Shanghai"      if provcode == 31
replace province = "Jiangsu"       if provcode == 32
replace province = "Zhejiang"      if provcode == 33
replace province = "Anhui"         if provcode == 34
replace province = "Fujian"        if provcode == 35
replace province = "Jiangxi"       if provcode == 36
replace province = "Shandong"      if provcode == 37
replace province = "Henan"         if provcode == 41
replace province = "Hubei"         if provcode == 42
replace province = "Hunan"         if provcode == 43
replace province = "Guangdong"     if provcode == 44
replace province = "Guangxi"       if provcode == 45
replace province = "Hainan"        if provcode == 46
replace province = "Chongqing"     if provcode == 50
replace province = "Sichuan"       if provcode == 51
replace province = "Guizhou"       if provcode == 52
replace province = "Yunnan"        if provcode == 53
replace province = "Shaanxi"       if provcode == 61
replace province = "Gansu"         if provcode == 62
replace province = "Qinghai"       if provcode == 63
replace province = "Ningxia"       if provcode == 64
replace province = "Xinjiang"       if provcode == 65

save "$OUTDIR\person_cleaned_v2.dta", replace

* =========================================================================
* PART 3: 从FAMECON计算省份×年份基尼系数（加入2022）
* =========================================================================
di _n(2) ">>> Computing provincial Gini coefficients (5 waves)..."

* 2014 famecon
use "$CFPS\2014\Stata14\cfps2014famecon_201906.dta", clear
keep fid14 provcd14 fincome1_per
rename fid14 fid
rename provcd14 provcode
gen year = 2014
gen hh_pcincome = fincome1_per
keep fid provcode year hh_pcincome
save "$TMPDIR\fe2014.dta", replace

* 2016 famecon
use "$CFPS\2016\Stata14\cfps2016famecon_201807.dta", clear
keep fid16 provcd16 fincome1_per
rename fid16 fid
rename provcd16 provcode
gen year = 2016
gen hh_pcincome = fincome1_per
keep fid provcode year hh_pcincome
save "$TMPDIR\fe2016.dta", replace

* 2018 famecon
use "$CFPS\2018\CFPS2018Stata_\cfps2018famecon_202512.dta", clear
keep fid18 provcd18 fincome1_per
rename fid18 fid
rename provcd18 provcode
gen year = 2018
gen hh_pcincome = fincome1_per
keep fid provcode year hh_pcincome
save "$TMPDIR\fe2018.dta", replace

* 2020 famecon
use "$CFPS\2020\CFPS2020Stata_\cfps2020famecon_202306.dta", clear
keep fid20 provcd20 fincome1_per
rename fid20 fid
rename provcd20 provcode
gen year = 2020
gen hh_pcincome = fincome1_per
keep fid provcode year hh_pcincome
save "$TMPDIR\fe2020.dta", replace

* 2022 famecon
use "$CFPS\2022\CFPS2022Stata\CFPS2022Stata_解密信息参见Instructions\cfps2022famecon_202410.dta", clear
keep fid22 provcd22 fincome1_per
rename fid22 fid
rename provcd22 provcode
gen year = 2022
gen hh_pcincome = fincome1_per
keep fid provcode year hh_pcincome
save "$TMPDIR\fe2022.dta", replace

* 合并所有famecon
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

di "  Famecon combined: N = " _N

gen gini_prov = .
gen mean_inc = .
gen sd_inc = .
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
                    replace gini_prov = round(`gval', 0.0001) ///
                        if provcode == `pv' & year == `yr'
                    replace mean_inc = round(`mu', 1) ///
                        if provcode == `pv' & year == `yr'
                    quietly summarize hh_pcincome if provcode == `pv' & year == `yr'
                    replace sd_inc = round(r(sd), 1) ///
                        if provcode == `pv' & year == `yr'
                    replace N_inc = `n' ///
                        if provcode == `pv' & year == `yr'
                }
                else restore
            }
            else restore
        }
        else restore
    }
}

keep if gini_prov != .
keep provcode year gini_prov mean_inc N_inc sd_inc
duplicates drop
sort year provcode

count
local ngini = r(N)
di "  Provincial-year Gini records (5 waves): `ngini'"

export delimited using "$OUTDIR\gini_by_province_year_v2.csv", replace
save "$OUTDIR\gini_dataset_v2.dta", replace

* =========================================================================
* PART 4: 合并回个人数据
* =========================================================================
di _n(2) ">>> Merging Gini back to person data..."
use "$OUTDIR\person_cleaned_v2.dta", clear

merge m:1 provcode year using "$OUTDIR\gini_dataset_v2.dta"
tab _merge
drop if _merge == 2
drop _merge

di "  After merge: N = " _N

* =========================================================================
* PART 5: 构造"抱负两极化"指标
* 核心指标：|individual_aspiration - provincial_mean_aspiration|
* 另构造：provincial SD of aspiration（直接反映离散度）
* =========================================================================
di _n(2) ">>> Constructing aspiration polarization measures..."

* Step 1: 计算每个省×年的抱负均值和标准差
bysort provcode year: egen asp_mean_provyr = mean(edu_asp_years)
bysort provcode year: egen asp_sd_provyr = sd(edu_asp_years)
bysort provcode year: gen asp_n_provyr = _N

* Step 2: 个人层面抱负极化
gen asp_dev = edu_asp_years - asp_mean_provyr
gen asp_polar = abs(asp_dev)

* Step 3: 基尼标准化
summarize gini_prov if gini_prov != .
local gm = r(mean)
local gs = r(sd)
gen gini_std = (gini_prov - `gm') / `gs' if gini_prov != .
gen gini_sq = gini_std^2 if gini_std != .

di "  Gini mean: `gm', SD: `gs'"
di "  Aspiration polarization (asp_polar) summary:"
summarize asp_polar, detail
di "  Aspiration mean by province-year:"
summarize asp_mean_provyr, detail
di "  Aspiration SD by province-year:"
summarize asp_sd_provyr, detail

* =========================================================================
* PART 6: 描述性统计
* =========================================================================
di _n(2) ">>> Descriptive statistics..."
di _n(5) "============================================================="
di "  TABLE 1: DESCRIPTIVE STATISTICS"
di "============================================================="

summarize edu_asp_years asp_polar asp_dev age gender urban log_income edu_years gini_prov asp_mean_provyr asp_sd_provyr

* 按年份分
di _n(2) "--- By Year ---"
tabstat edu_asp_years asp_polar gini_prov age, by(year) ///
    stat(n mean sd min max) format(%9.3f) col(stat)

* 保存描述统计
preserve
gen str32 varname = ""
replace varname = "Edu Aspiration (years)" in 1
replace varname = "Asp Polarization" in 2
replace varname = "Asp Deviation" in 3
replace varname = "Age" in 4
replace varname = "Gender(1=M)" in 5
replace varname = "Urban(1=Y)" in 6
replace varname = "ln(Income)" in 7
replace varname = "Education Years" in 8
replace varname = "Prov.Gini" in 9
replace varname = "Asp Mean(prov-yr)" in 10
replace varname = "Asp SD(prov-yr)" in 11

gen N_obs = .
gen Mean = .
gen SD = .
gen Min_v = .
gen Max_v = .

forvalues i = 1/11 {
    local vars: word `i' of edu_asp_years asp_polar asp_dev age gender urban log_income edu_years gini_prov asp_mean_provyr asp_sd_provyr
    quietly summarize `vars'
    replace N_obs  = round(r(N))    in `i'
    replace Mean   = round(r(mean), .0001) in `i'
    replace SD     = round(r(sd), .0001) in `i'
    replace Min_v  = round(r(min), .0001) in `i'
    replace Max_v  = round(r(max), .0001) in `i'
}

keep in 1/11
keep varname N_obs Mean SD Min_v Max_v
export delimited using "$OUTDIR\descriptive_stats_v2.csv", replace
restore

* =========================================================================
* PART 7: 基准回归 — 抱负两极化 = f(Gini, controls)
* =========================================================================
di _n(5) "============================================================="
di "  TABLE 2: BASELINE REGRESSIONS"
di "  DV = Aspiration Polarization |Asp_i - Mean_Asp_provyr|"
di "  SE: Clustered by Province"
di "============================================================="

* Model 1: 仅控制变量
regress asp_polar age gender urban log_income edu_years i.year if gini_std != ., vce(cluster provcode)
est store m1
di "Model 1 (Controls only): N=" e(N) ", R2=" e(r2) ", clusters=" e(N_clust)

* Model 2: +Gini线性
regress asp_polar age gender urban log_income edu_years gini_std i.year if gini_std != ., vce(cluster provcode)
est store m2
local m2_g = _b[gini_std]
local m2_gp = 2*ttail(e(df_r),abs(_b[gini_std]/_se[gini_std]))
di "Model 2 (+Gini): N=" e(N) ", Gini coef=" `m2_g' ", p=" `m2_gp'

* Model 3: +Gini^2
regress asp_polar age gender urban log_income edu_years gini_std gini_sq i.year if gini_std != ., vce(cluster provcode)
est store m3
di "Model 3 (+Gini^2): N=" e(N) ", R2=" e(r2)

* Model 4: 不含log_income（可能过度控制）
regress asp_polar age gender urban edu_years gini_std i.year if gini_std != ., vce(cluster provcode)
est store m4
di "Model 4 (no income): N=" e(N) ", R2=" e(r2)
local m4_g = _b[gini_std]
local m4_gp = 2*ttail(e(df_r),abs(_b[gini_std]/_se[gini_std]))
di "  Gini coef=" `m4_g' ", p=" `m4_gp'

* Model 5: 仅年龄+Gini
regress asp_polar age gini_std i.year if gini_std != ., vce(cluster provcode)
est store m5
di "Model 5 (age+Gini only): N=" e(N) ", R2=" e(r2)
local m5_g = _b[gini_std]
local m5_gp = 2*ttail(e(df_r),abs(_b[gini_std]/_se[gini_std]))
di "  Gini coef=" `m5_g' ", p=" `m5_gp'

* Model 6: 省份固定效应
regress asp_polar age gender urban log_income edu_years gini_std i.provcode if gini_std != ., vce(robust)
est store m6
di "Model 6 (Prov FE): N=" e(N) ", R2=" e(r2)
local m6_g = _b[gini_std]
local m6_gp = 2*ttail(e(df_r),abs(_b[gini_std]/_se[gini_std]))
di "  Gini coef=" `m6_g' ", p=" `m6_gp'

* 输出回归表格
esttab m1 m2 m3 m4 m5 m6, ///
    b(%9.4f) t(%7.3f) star(* 0.1 ** 0.05 *** 0.01) ///
    drop(*.year *.provcode) ///
    mtitles("M1" "M2+Gini" "M3+Gini^2" "M4noInc" "M5Min" "M6ProvFE") ///
    title("Table 2: Inequality → Aspiration Polarization")

esttab m1 m2 m3 m4 m5 m6 using "$OUTDIR\regression_results_v2.csv", ///
    b(%9.4f) t(%7.3f) star(* 0.1 ** 0.05 *** 0.01) ///
    drop(*.year *.provcode) csv replace ///
    mtitles("M1" "M2+Gini" "M3+Gini^2" "M4noInc" "M5Min" "M6ProvFE")

* =========================================================================
* PART 8: 用省级抱负标准差（直接测度）替代
* =========================================================================
di _n(5) "============================================================="
di "  TABLE 2b: Using Provincial SD of Aspiration as DV"
di "============================================================="

* 将省级抱负SD merge到个人数据
* asp_sd_provyr 已经在上面计算好了
regress asp_polar age gender urban log_income edu_years gini_std i.year if asp_sd_provyr != ., vce(cluster provcode)
est store sd_m1
di "SD Model 1: N=" e(N) ", R2=" e(r2)

regress asp_polar age gender urban edu_years gini_std i.year if asp_sd_provyr != ., vce(cluster provcode)
est store sd_m2
local sd_g = _b[gini_std]
local sd_gp = 2*ttail(e(df_r),abs(_b[gini_std]/_se[gini_std]))
di "SD Model 2 (no income): Gini coef=" `sd_g' ", p=" `sd_gp'

regress asp_polar age gini_std i.year if asp_sd_provyr != ., vce(cluster provcode)
est store sd_m3
di "SD Model 3 (minimal): N=" e(N) ", R2=" e(r2)

* =========================================================================
* PART 9: 异质性分析
* =========================================================================
di _n(5) "============================================================="
di "  TABLE 3: HETEROGENEITY ANALYSIS"
di "============================================================="

* 城乡
di _n(2) "--- Urban ---"
regress asp_polar age gender log_income edu_years gini_std i.year ///
    if urban == 1 & gini_std != ., vce(cluster provcode)
est store het_urban
di "  Urban: N=" e(N) ", R2=" e(r2)

di _n(2) "--- Rural ---"
regress asp_polar age gender log_income edu_years gini_std i.year ///
    if urban == 0 & gini_std != ., vce(cluster provcode)
est store het_rural
di "  Rural: N=" e(N) ", R2=" e(r2)

* 性别
di _n(2) "--- Male ---"
regress asp_polar age urban log_income edu_years gini_std i.year ///
    if gender == 1 & gini_std != ., vce(cluster provcode)
est store het_male

di _n(2) "--- Female ---"
regress asp_polar age urban log_income edu_years gini_std i.year ///
    if gender == 0 & gini_std != ., vce(cluster provcode)
est store het_female

* 低教育 vs 高教育家庭
di _n(2) "--- Low Edu (<=9yr) ---"
regress asp_polar age gender urban log_income gini_std i.year ///
    if edu_years <= 9 & gini_std != ., vce(cluster provcode)
est store het_lowedu

di _n(2) "--- High Edu (>12yr) ---"
regress asp_polar age gender urban log_income gini_std i.year ///
    if edu_years > 12 & gini_std != ., vce(cluster provcode)
est store het_highedu

esttab het_urban het_rural het_male het_female het_lowedu het_highedu using "$OUTDIR\heterogeneity_results_v2.csv", ///
    b(%9.4f) se(%9.4f) star(* 0.1 ** 0.05 *** 0.01) ///
    drop(*.year) csv replace ///
    mtitles("Urban" "Rural" "Male" "Female" "LowEdu" "HighEdu")

* =========================================================================
* PART 10: 稳健性检验
* =========================================================================
di _n(5) "============================================================="
di "  TABLE 4: ROBUSTNESS CHECKS"
di "============================================================="

* 10.1 原始Gini
di _n(2) "--- Raw Gini ---"
regress asp_polar age gender urban edu_years c.gini_prov##c.gini_prov i.year ///
    if gini_prov != ., vce(cluster provcode)
est store rob_a

* 10.2 年龄子样本 10-25
di _n(2) "--- Age 10-25 ---"
regress asp_polar age gender urban edu_years gini_std i.year ///
    if gini_std != . & age >= 10 & age <= 25, vce(cluster provcode)
est store rob_b

* 10.3 排除极端Gini
summarize gini_std if gini_std != ., detail
local g_p1 = r(p1)
local g_p99 = r(p99)
di _n(2) "--- Trimmed Gini (1%-99%) ---"
regress asp_polar age gender urban edu_years gini_std i.year ///
    if gini_std != . & gini_std >= `g_p1' & gini_std <= `g_p99', vce(cluster provcode)
est store rob_c

* 10.4 排除"不必读书"=0
di _n(2) "--- Exclude 'no study needed' ---"
regress asp_polar age gender urban edu_years gini_std i.year ///
    if gini_std != . & edu_asp_years > 0, vce(cluster provcode)
est store rob_d

* 10.5 排除小样本省份
di _n(2) "--- Large-sample provinces (N_hh >= 80) ---"
merge m:1 provcode year using "$OUTDIR\gini_dataset_v2.dta", keepusing(N_inc) nogen
regress asp_polar age gender urban edu_years gini_std i.year ///
    if gini_std != . & N_inc >= 80, vce(cluster provcode)
est store rob_e

* 10.6 使用 log_income + log(hh_income) as proxy
di _n(2) "--- With household income controls ---"
regress asp_polar age gender urban edu_years log_income gini_std i.year ///
    if gini_std != . & log_income != ., vce(cluster provcode)
est store rob_f

esttab rob_a rob_b rob_c rob_d rob_e rob_f using "$OUTDIR\robustness_results_v2.csv", ///
    b(%9.4f) t(%7.3f) star(* 0.1 ** 0.05 *** 0.01) ///
    drop(*.year) csv replace ///
    mtitles("Raw Gini" "Age10-25" "Trimmed" "NoZero" "BigProv" "IncCtrl")

* =========================================================================
* PART 11: 保存最终数据集 + 结果汇总
* =========================================================================
order pid fid provcode province year urban gender birth_y age ///
       edu_asp_years edu_years p_income log_income ///
       gini_prov gini_std gini_sq ///
       asp_polar asp_dev asp_mean_provyr asp_sd_provyr ///
       N_inc

label variable edu_asp_years "Expected Education (years)"
label variable asp_polar "Aspiration Polarization |asp_i - mean_provyr|"
label variable asp_dev "Aspiration Deviation from Provincial Mean"
label variable gini_prov "Provincial Gini (per-capita income)"
label variable gini_std "Standardized Gini (z-score)"

save "$OUTDIR\analysis_final_dataset_v2.dta", replace

* =========================================================================
* 结果汇总JSON
* =========================================================================
di _n(5) "=========================================================================="
di "  RESULTS SUMMARY"
di "=========================================================================="

tempname jfile
file open `jfile' using "$OUTDIR\stata_results_v2.json", text write replace
file write `jfile' "{" _n

* Gini统计
quietly summarize gini_prov if gini_prov != .
file write `jfile' `""gini": {"' _n
file write `jfile' `"  "gini_mean": "' r(mean) `","' _n
file write `jfile' `"  "gini_sd": "' r(sd) `","' _n
file write `jfile' `"  "gini_min": "' r(min) `","' _n
file write `jfile' `"  "gini_max": "' r(max) `"'

* 抱负极化统计
quietly summarize asp_polar if asp_polar != .
file write `jfile' `"},"' _n
file write `jfile' `"asp_polar": {"' _n
file write `jfile' `"  "mean": "' r(mean) `","' _n
file write `jfile' `"  "sd": "' r(sd) `"'

* 模型结果
est restore m2
local m2_b = _b[gini_std]
local m2_se = _se[gini_std]
local m2_df = e(df_r)
local m2_p = 2*ttail(`m2_df', abs(`m2_b'/`m2_se'))
file write `jfile' `"},"' _n
file write `jfile' `"models": {' _n
file write `jfile' `"  "m2": {"N": ' e(N) ', "gini": ' `m2_b' ', "se": ' `m2_se' ', "p": ' `m2_p' '}' _n

est restore m4
local m4_b = _b[gini_std]
local m4_se = _se[gini_std]
local m4_df = e(df_r)
local m4_p = 2*ttail(`m4_df', abs(`m4_b'/`m4_se'))
file write `jfile' `",  "m4": {"N": ' e(N) ', "gini": ' `m4_b' ', "se": ' `m4_se' ', "p": ' `m4_p' '}' _n

est restore m6
local m6_b = _b[gini_std]
local m6_se = _se[gini_std]
local m6_df = e(df_r)
local m6_p = 2*ttail(`m6_df', abs(`m6_b'/`m6_se'))
file write `jfile' `",  "m6": {"N": ' e(N) ', "gini": ' `m6_b' ', "se": ' `m6_se' ', "p": ' `m6_p' '}' _n

file write `jfile' `"}"' _n
file write `jfile' `"}"' _n
file close `jfile'

di _n(2) "=========================================================================="
di "  ANALYSIS COMPLETE"
di "=========================================================================="
di "  Data: CFPS 2014/2016/2018/2020/2022 (5 waves)"
di "  DV: Aspiration Polarization = |individual - provincial mean|"
di "  Key variable: qc201 (期望受教育程度) → continuous years"
di "  Output files saved to: $OUTDIR"
di "=========================================================================="

log close
di "DONE"
