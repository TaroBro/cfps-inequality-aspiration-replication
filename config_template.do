/*
Copy this file to config_local.do and edit the paths for your machine.
config_local.do is intentionally ignored by git.
*/

global OUTDIR "E:/path/to/this/repository"
global CFPS   "E:/path/to/CFPS"
global TMPDIR "$OUTDIR/_tmp"

capture mkdir "$OUTDIR"
capture mkdir "$TMPDIR"
