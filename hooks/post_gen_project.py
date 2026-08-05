from pathlib import Path
import shutil

ROOT = Path.cwd()

replacement = "{{ '{{ cookiecutter.lib_slug }}' }}"
template_root = ROOT / "cookiecutter"

# Rename deepest paths first
paths = sorted(
    template_root.rglob("__LIB_SLUG__"),
    key=lambda p: len(p.parts),
    reverse=True,
)

for old in paths:
    new = old.with_name(replacement)
    print(f"{old} -> {new}")
    shutil.move(old, new)