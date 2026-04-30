# Data Availability Statement

## Public Release Policy

This GitHub repository does not include CFPS microdata or CFPS-derived Stata
datasets. The local analysis files are excluded by `.gitignore` because they are
derived from the China Family Panel Studies (CFPS).

The CFPS Data User Agreement states that users may not distribute CFPS data in
original or modified form on journal websites or third-party platforms. For that
reason, uploading the `.dta` files in this directory to GitHub would not be a
compliant open-science release.

Official sources:

- CFPS Data User Agreement:
  https://www.isss.pku.edu.cn/cfps/en/data/DataUserAgreement/index.htm
- CFPS Dataverse:
  https://opendata.pku.edu.cn/dataverse/CFPS
- CFPS DOI:
  https://doi.org/10.18170/DVN/45LCSO

## Recommended Manuscript Statement

The data underlying this study are from the China Family Panel Studies (CFPS),
administered by the Institute of Social Science Survey, Peking University.
Because the CFPS Data User Agreement prohibits redistribution of CFPS data in
original or modified form through journal websites or third-party platforms, the
analysis datasets cannot be publicly deposited in this repository. Qualified
researchers can apply for access through the official CFPS data platform
(https://opendata.pku.edu.cn/dataverse/CFPS) and reproduce the analyses using
the Stata scripts and metadata provided here.

## Source Files Needed For Reproduction

Authorized users should arrange the CFPS files under the local `CFPS` root so
the paths in `config_local.do` resolve to the following files:

- `2014/Stata14/cfps2014adult_201906.dta`
- `2014/Stata14/cfps2014famecon_201906.dta`
- `2016/Stata14/cfps2016adult_201906.dta`
- `2016/Stata14/cfps2016famecon_201807.dta`
- `2018/CFPS2018Stata_/cfps2018person_202512.dta`
- `2018/CFPS2018Stata_/cfps2018famecon_202512.dta`
- `2020/CFPS2020Stata_/cfps2020person_202306.dta`
- `2020/CFPS2020Stata_/cfps2020famecon_202306.dta`
- `2022/CFPS2022Stata/CFPS2022Stata_解密信息参见Instructions/cfps2022person_202410.dta`
- `2022/CFPS2022Stata/CFPS2022Stata_解密信息参见Instructions/cfps2022famecon_202410.dta`

## What Is Shared Publicly

- Analysis code.
- Variable-level metadata and codebooks.
- Reproduction instructions.
- Citation and licensing files.

## What Is Not Shared Publicly

- Individual-level CFPS records.
- Family-level CFPS records.
- Province-year or individual-level datasets derived from CFPS unless explicit
  redistribution permission is obtained from the data owner.
- Local logs or temporary files that may reveal restricted data contents.
