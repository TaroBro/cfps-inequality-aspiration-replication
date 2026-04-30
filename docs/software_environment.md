# Software Environment

The analysis code is written for Stata. The public release helper is written in
Python.

## Required

- Stata.
- Python 3.10 or later for `scripts/validate_release.py`.

## Stata Packages

The analysis scripts use `esttab`, provided by the Stata package `estout`.
`code/legacy/analysis_v2_legacy.do` also checks for `reghdfe` and `ftools`.

In Stata:

```stata
ssc install estout, replace
```

Optional legacy dependencies:

```stata
ssc install reghdfe, replace
ssc install ftools, replace
```

## Operating System Notes

Paths are configured through `config_local.do`. The repository uses forward or
backward slashes only in local Stata path macros, so the workflow can be adapted
to Windows, macOS, or Linux as long as the CFPS directory structure is preserved.
