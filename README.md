# CFPS Inequality and Educational Aspiration Replication Package

This repository contains Stata code and reproducibility documentation for an
analysis of provincial income inequality and educational aspiration dispersion
using China Family Panel Studies (CFPS) data.

## Important Data Notice

The local `.dta` files in this working directory are derived from CFPS. They are
not included in the public release. The CFPS Data User Agreement prohibits
redistributing CFPS data, in original or modified form, on journal websites or
third-party platforms. GitHub is a third-party platform, so this repository is
structured as a compliant replication package: code, metadata, and instructions
are public; CFPS-derived data remain private.

See [DATA_AVAILABILITY.md](DATA_AVAILABILITY.md) for the recommended manuscript
statement and instructions for obtaining the source data from the official CFPS
platform.

## Repository Contents

- `analysis_v3.do`: builds cleaned individual-level files, provincial Gini
  measures, and province-year analysis inputs from authorized local CFPS data.
- `analysis_v4.do`: runs the final robustness, interaction, subgroup, and
  quantile-regression analyses.
- `analysis_v2.do`: earlier analysis version retained for provenance.
- `check_*.do`, `explore_2022_vars.do`, `find_aspiration_vars.do`: exploratory
  scripts used to inspect CFPS variables.
- `config_template.do`: local path template. Copy it to `config_local.do` before
  running the Stata scripts.
- `metadata/`: schema-level metadata generated from local analysis files. It
  does not contain row-level CFPS data.
- `scripts/validate_release.py`: release hygiene checker for accidental data
  leakage and hard-coded local paths.

## Quick Start

1. Apply for and download CFPS data from the official CFPS platform.
2. Copy `config_template.do` to `config_local.do`.
3. Edit `config_local.do` so `CFPS` points to the local CFPS root directory and
   `OUTDIR` points to this repository.
4. In Stata, run:

```stata
do analysis_v3.do
do analysis_v4.do
```

5. Before publishing to GitHub, run:

```bash
python scripts/validate_release.py
```

## Requirements

- Stata with standard commands used in the scripts.
- `estout` / `esttab` for regression table export.
- Python 3 for the release validation helper.

## License

The code and documentation in this repository are released under the MIT
License. No license is granted for CFPS data or CFPS-derived analysis datasets;
those remain governed by the CFPS Data User Agreement.

## Data Citation

Institute of Social Science Survey, Peking University. China Family Panel
Studies (CFPS). Peking University Open Research Data Platform.
https://doi.org/10.18170/DVN/45LCSO
