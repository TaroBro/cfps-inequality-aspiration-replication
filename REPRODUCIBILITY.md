# Reproducibility Guide

This guide describes how an authorized CFPS user can reproduce the analysis
without requiring any restricted data to be stored in this GitHub repository.

## 1. Obtain Data

Apply for CFPS access through the official platform:

https://opendata.pku.edu.cn/dataverse/CFPS

The required source files are listed in `DATA_AVAILABILITY.md`.

## 2. Configure Paths

From the repository root, copy the local configuration template:

```bash
cp config_template.do config_local.do
```

Edit `config_local.do`:

- `OUTDIR`: repository root or another local output directory.
- `CFPS`: local root directory containing the authorized CFPS files.
- `TMPDIR`: local temporary directory, usually `$OUTDIR/_tmp`.

`config_local.do` is ignored by git because it contains machine-specific paths.

## 3. Run The Formal Workflow

Run the audited workflow from the repository root:

```stata
do code/stata/00_run_all.do
```

The master script calls:

1. `code/stata/01_build_analysis_data.do`
2. `code/stata/02_run_final_models.do`

## 4. Expected Local Outputs

The workflow may generate local Stata datasets, CSV tables, text summaries, JSON
summaries, and Stata logs. These files can be used locally for manuscript tables
and checks, but CFPS-derived datasets and logs are intentionally excluded from
the public release.

## 5. Verify The Public Package

Before publishing or archiving, run:

```bash
python scripts/validate_release.py
```

The checker flags restricted data files that are not ignored, local personal
paths in public files, and placeholder citation metadata.

## 6. Reuse In A Journal Submission

For SCI-style review, deposit this public code package and include the data
availability statement from `DATA_AVAILABILITY.md`. Do not upload CFPS-derived
datasets unless the CFPS data owner gives explicit redistribution permission.
