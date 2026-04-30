# Code Directory

This directory separates the audited replication workflow from exploratory
scripts.

- `stata/00_run_all.do`: main entry point for reproduction.
- `stata/01_build_analysis_data.do`: constructs local CFPS-derived analysis
  files from authorized CFPS source data.
- `stata/02_run_final_models.do`: runs final models and exports analysis
  outputs.
- `exploratory/`: variable-inspection scripts kept for transparency.
- `legacy/`: earlier analysis versions retained for provenance only.

Run the formal workflow from the repository root:

```stata
do code/stata/00_run_all.do
```
