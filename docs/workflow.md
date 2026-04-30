# Analysis Workflow

The formal workflow is intentionally short:

```stata
do code/stata/00_master.do
```

## Step 1: Build Analysis Data

`code/stata/01_build_analysis_data.do` reads authorized CFPS source files for
2014, 2016, 2018, 2020, and 2022. It standardizes common variables across waves,
constructs educational aspiration in years, restricts the analytic age range,
computes province-year Gini coefficients from household per-capita income, and
builds local analysis files.

## Step 2: Run Models

`code/stata/02_run_final_models.do` runs the final model suite:

- Quantile regressions.
- Income and education interaction models.
- Income, education, and age subgroup analyses.
- Directional aspiration-deviation checks.
- Minimal models and bootstrap checks.

## Exploratory Scripts

Scripts under `code/exploratory/` document how variables were inspected before
the final workflow was settled. They are kept for transparency but are not part
of the main reproduction path.
