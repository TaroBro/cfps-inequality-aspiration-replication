/* =========================================================================
   Master replication script

   Run from the repository root:
       do code/stata/00_master.do

   This script assumes that config_template.do has been copied to
   config_local.do and edited for the local CFPS data path.
   ========================================================================= */

clear all
set more off

capture confirm file "config_local.do"
if _rc {
    di as error "config_local.do not found."
    di as error "Copy config_template.do to config_local.do and set OUTDIR, CFPS, and TMPDIR."
    exit 198
}

do "config_local.do"

capture mkdir "$OUTDIR"
capture mkdir "$TMPDIR"

di _n(2) "Step 1/2: Build local analysis data from authorized CFPS files"
do "code/stata/01_build_analysis_data.do"

di _n(2) "Step 2/2: Run final models and robustness checks"
do "code/stata/02_run_final_models.do"

di _n(2) "Replication workflow complete."
