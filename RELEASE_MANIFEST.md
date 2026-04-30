# Release Manifest

Release date: 2026-04-30

## Included In The Public Repository

- Stata analysis code under `code/stata/`.
- Exploratory variable-inspection scripts under `code/exploratory/`.
- Legacy analysis code under `code/legacy/`.
- Data availability and reproducibility documentation.
- Variable-level metadata under `metadata/`.
- A release validation helper under `scripts/`.
- Citation and license files.

## Excluded From The Public Repository

- CFPS raw microdata.
- CFPS-derived `.dta` files.
- Temporary Stata datasets under `_tmp/`.
- Local Stata logs, CSV result tables, and JSON summaries generated from CFPS.
- Local manuscript drafts such as `.docx` files.
- Machine-specific configuration in `config_local.do`.

## Validation

Run:

```bash
python scripts/validate_release.py
```

Expected result before release:

```text
errors: 0
warnings: 0
```
