from pathlib import Path
import shutil

ROOT = Path.cwd()

template_root = ROOT / "cookiecutter"

def replace(find, replace):
    # Rename deepest paths first
    paths = sorted(
        template_root.rglob(find),
        key=lambda p: len(p.parts),
        reverse=True,
    )

    for old in paths:
        new = old.with_name(replace)
        print(f"{old} -> {new}")
        shutil.move(old, new)
        
replace("__LIB_SLUG__", "{{ '{{ cookiecutter.lib_slug }}' }}")
replace("__EXEC_SLUG__", "{{ '{{ cookiecutter.exec_slug }}' }}")