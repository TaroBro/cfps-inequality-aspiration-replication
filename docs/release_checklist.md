# GitHub Release Checklist

Use this checklist before making the repository public.

- Confirm that no `.dta`, `.sav`, `.sas7bdat`, `.rds`, `.zip`, `.rar`, or raw
  data extracts are tracked by git.
- Confirm that `config_local.do` is not tracked.
- Confirm that public Stata files are under `code/` rather than scattered in the
  repository root.
- Confirm that `README.md`, `DATA_AVAILABILITY.md`, `REPRODUCIBILITY.md`, and
  `CITATION.cff` have correct project, author, and repository information.
- Confirm that `RELEASE_MANIFEST.md` clearly describes what is included and
  excluded.
- Confirm that the manuscript includes the CFPS data availability statement.
- Run `python scripts/validate_release.py`.
- If a journal requests deposited data, point reviewers to the official CFPS
  access route unless explicit redistribution permission has been obtained.
