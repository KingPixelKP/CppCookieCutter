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
        shutil.move(old, new)
        
replace("__LIB_SLUG__", "{{ '{{ cookiecutter.lib_slug }}' }}")
replace("__EXEC_SLUG__", "{{ '{{ cookiecutter.exec_slug }}' }}")
replace("__BENCHMARK_SLUG__", "{{ '{{ cookiecutter.bench_slug }}' }}")
replace("__MODULE_SLUG__", "{{ '{{ cookiecutter.module_slug }}' }}")