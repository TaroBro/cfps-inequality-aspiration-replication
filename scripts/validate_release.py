"""Check that the repository is safe to publish as a CFPS replication package.

The goal is not to prove legal compliance. It catches common mistakes before a
GitHub release: unignored data files, local machine paths, and placeholder
citation metadata.
"""

from __future__ import annotations

import fnmatch
import re
import sys
from pathlib import Path


RESTRICTED_EXTENSIONS = {
    ".dta",
    ".sav",
    ".sas7bdat",
    ".por",
    ".xpt",
    ".rdata",
    ".rds",
}

ARCHIVE_EXTENSIONS = {
    ".zip",
    ".rar",
    ".7z",
    ".tar",
    ".gz",
}

SKIP_DIRS = {".git", "__pycache__", ".pytest_cache"}
LOCAL_PATH_RE = re.compile(
    r"([A-Za-z]:\\Users\\|[A-Za-z]:/Users/|/Users/|/home/[^/\s]+/)"
)


def load_gitignore(root: Path) -> list[str]:
    gitignore = root / ".gitignore"
    if not gitignore.exists():
        return []
    patterns: list[str] = []
    for raw in gitignore.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("!"):
            continue
        patterns.append(line)
    return patterns


def is_ignored(path: Path, root: Path, patterns: list[str]) -> bool:
    rel = path.relative_to(root).as_posix()
    parts = rel.split("/")
    for pattern in patterns:
        clean = pattern.rstrip("/")
        if pattern.endswith("/"):
            if rel == clean or rel.startswith(clean + "/") or clean in parts:
                return True
            continue
        if fnmatch.fnmatch(rel, pattern) or fnmatch.fnmatch(path.name, pattern):
            return True
    return False


def iter_files(root: Path):
    for path in root.rglob("*"):
        if path.is_dir():
            continue
        if any(part in SKIP_DIRS for part in path.relative_to(root).parts):
            continue
        yield path


def main() -> int:
    root = Path(__file__).resolve().parents[1]
    patterns = load_gitignore(root)
    errors: list[str] = []
    warnings: list[str] = []
    ignored_restricted = 0

    for path in iter_files(root):
        rel = path.relative_to(root).as_posix()
        ignored = is_ignored(path, root, patterns)
        suffix = path.suffix.lower()

        if suffix in RESTRICTED_EXTENSIONS:
            if ignored:
                ignored_restricted += 1
            else:
                errors.append(f"Restricted data file is not ignored: {rel}")
            continue

        if suffix in ARCHIVE_EXTENSIONS and not ignored:
            warnings.append(f"Archive file should be reviewed before release: {rel}")

        if ignored:
            continue

        if suffix in {".md", ".do", ".py", ".txt", ".cff", ".yml", ".yaml", ".json"}:
            try:
                text = path.read_text(encoding="utf-8", errors="ignore")
            except OSError as exc:
                warnings.append(f"Could not read {rel}: {exc}")
                continue
            if rel != "scripts/validate_release.py" and LOCAL_PATH_RE.search(text):
                errors.append(f"Hard-coded personal path found in public file: {rel}")
            if rel == "CITATION.cff" and ("TODO" in text or "OWNER/REPOSITORY" in text):
                warnings.append("CITATION.cff still contains placeholder metadata.")

    print("Release validation summary")
    print(f"  ignored restricted data files: {ignored_restricted}")
    print(f"  errors: {len(errors)}")
    print(f"  warnings: {len(warnings)}")

    for item in errors:
        print(f"ERROR: {item}")
    for item in warnings:
        print(f"WARNING: {item}")

    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
