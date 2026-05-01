# GitHub Publishing Steps

1. Run the release checker:

```bash
python scripts/validate_release.py
```

2. Confirm ignored data files before staging:

```bash
git status --short --ignored
```

All `.dta` files and `_tmp/` contents should appear as ignored, not staged.

3. Stage the public release files:

```bash
git add .gitignore README.md DATA_AVAILABILITY.md REPRODUCIBILITY.md CITATION.cff LICENSE
git add RELEASE_MANIFEST.md config_template.do code docs metadata scripts
```

4. Review the staged files:

```bash
git status --short
git diff --cached --stat
```

5. Commit and push:

```bash
git commit -m "Organize CFPS replication package"
git branch -M main
git remote add origin https://github.com/TaroBro/cfps-inequality-aspiration-replication.git
git push -u origin main
```

Before pushing, confirm that `CITATION.cff` still matches the final repository
URL and author information.
