from pathlib import Path
import shutil

ROOT = Path.cwd()

template_root = ROOT


def replace_path(find, replace):
    # Rename deepest paths first
    paths = sorted(
        template_root.rglob(find),
        key=lambda p: len(p.parts),
        reverse=True,
    )

    for old in paths:
        new = old.with_name(replace)
        shutil.move(old, new)


def replace_text(find, replace):
    for path in template_root.rglob("*"):
        if not path.is_file():
            continue

        try:
            content = path.read_text()
        except UnicodeDecodeError:
            continue

        if find in content:
            path.write_text(content.replace(find, replace))


replace_path("__LIB_SLUG__", "{{ '{{ cookiecutter.lib_slug }}' }}")
replace_path("__EXEC_SLUG__", "{{ '{{ cookiecutter.exec_slug }}' }}")
replace_path("__BENCHMARK_SLUG__", "{{ '{{ cookiecutter.bench_slug }}' }}")
replace_path("__MODULE_SLUG__", "{{ '{{ cookiecutter.module_slug }}' }}")

authors = "{{ cookiecutter.authors }}".split(",")

replace_text(
    "__AUTHORS__",
    "\n".join(f"* {a.strip()}" for a in authors)
)