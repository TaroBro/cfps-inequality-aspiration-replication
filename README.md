# CFPS Inequality and Educational Aspiration Replication Package

This repository is an SCI-style replication package for a study of provincial
income inequality and educational aspiration dispersion using the China Family
Panel Studies (CFPS).

The repository is intentionally code-first. It shares the audited analysis
workflow, metadata, and data-access instructions, but it does not share CFPS
microdata or CFPS-derived Stata datasets.

## Data Access And Compliance

CFPS data are governed by the CFPS Data User Agreement. Because the agreement
does not permit redistribution of CFPS data in original or modified form on
journal websites or third-party platforms, the `.dta` files used locally are not
included in this public repository.

See [DATA_AVAILABILITY.md](DATA_AVAILABILITY.md) for the manuscript-ready data
availability statement and official CFPS access route.

## Repository Structure

```text
.
|-- README.md
|-- DATA_AVAILABILITY.md
|-- REPRODUCIBILITY.md
|-- RELEASE_MANIFEST.md
|-- CITATION.cff
|-- LICENSE
|-- config_template.do
|-- code/
|   |-- stata/
|   |   |-- 00_run_all.do
|   |   |-- 01_build_analysis_data.do
|   |   `-- 02_run_final_models.do
|   |-- exploratory/
|   `-- legacy/
|-- docs/
|-- metadata/
`-- scripts/
```

## Reproduce The Analysis

1. Obtain authorized CFPS data from the official CFPS platform.
2. Copy `config_template.do` to `config_local.do`.
3. Edit `config_local.do` so `CFPS` points to the local CFPS root directory and
   `OUTDIR` points to this repository.
4. From the repository root, run:

```stata
do code/stata/00_run_all.do
```

5. Before depositing or updating the public repository, run:

```bash
python scripts/validate_release.py
```

## Main Workflow

- `code/stata/01_build_analysis_data.do` reads authorized CFPS source files,
  cleans the analytic sample, computes province-year Gini coefficients, and
  constructs local CFPS-derived analysis files.
- `code/stata/02_run_final_models.do` runs quantile regressions, interaction
  models, subgroup analyses, age-sample checks, directional-deviation models,
  and minimal/bootstrap robustness checks.
- `metadata/data_dictionary.csv` provides variable-level metadata generated from
  the local analysis files. It contains no row-level records.

## Requirements

- Stata.
- Stata package `estout` / `esttab` for table export.
- Python 3 for release validation.
- Authorized local access to CFPS 2014, 2016, 2018, 2020, and 2022 data.

## License

Code and documentation are released under the MIT License. No license is granted
for CFPS data or CFPS-derived analysis datasets; those remain governed by the
CFPS Data User Agreement.

## Data Citation

Institute of Social Science Survey, Peking University. China Family Panel
Studies (CFPS). Peking University Open Research Data Platform.
https://doi.org/10.18170/DVN/45LCSO
