# Reproducibility Guide

## 1. Configure Local Paths

Copy the template and edit it locally:

```bash
cp config_template.do config_local.do
```

Set:

- `OUTDIR`: this repository directory.
- `CFPS`: the root directory containing authorized CFPS data files.
- `TMPDIR`: a local temporary output directory, normally `$OUTDIR/_tmp`.

`config_local.do` is ignored by git because it contains machine-specific paths.

## 2. Run The Stata Pipeline

Run the scripts from the repository root:

```stata
do analysis_v3.do
do analysis_v4.do
```

`analysis_v3.do` constructs the cleaned analysis inputs from authorized CFPS
source data. `analysis_v4.do` performs the final model checks and exports tables.

## 3. Expected Local Outputs

The scripts may generate local `.dta`, `.csv`, `.txt`, `.json`, and Stata log
files. CFPS-derived datasets and logs are intentionally excluded from the public
GitHub release.

## 4. Release Check

Before publishing or archiving the repository, run:

```bash
python scripts/validate_release.py
```

The checker looks for restricted data files that are not ignored, direct CFPS
data artifacts, and hard-coded personal paths.

## 5. Journal Deposit

For SCI-style review, deposit the public code package and include the data
availability statement from `DATA_AVAILABILITY.md`. Do not upload CFPS-derived
data unless the CFPS data owner provides explicit redistribution permission.
