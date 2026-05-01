# Local Data Release Audit

Audit date: 2026-04-30

The files below were found in the local workspace. They are excluded from the
public GitHub release because they are CFPS data or CFPS-derived datasets.

| File | Rows | Columns | Release decision | Reason |
| --- | ---: | ---: | --- | --- |
| `analysis_final_dataset_v2.dta` | 7,840 | 60 | Do not publish | Individual-level CFPS-derived data with person/family IDs and income variables. |
| `gini_dataset_v2.dta` | 128 | 6 | Do not publish | Province-year aggregate derived from CFPS household income data. |
| `person_cleaned.dta` | 7,294 | 49 | Do not publish | Individual-level cleaned CFPS-derived data. |
| `person_cleaned_v2.dta` | 7,840 | 28 | Do not publish | Individual-level cleaned CFPS-derived data. |
| `provyr_panel_v3.dta` | 7,840 | 42 | Do not publish | Despite its name, this local file is individual-level CFPS-derived data. |
| `_tmp/*.dta` | varies | varies | Do not publish | Temporary intermediate CFPS-derived files. |

The public release contents are limited to code, documentation, configuration
templates, and schema-level metadata.
