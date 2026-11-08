from pathlib import Path
import shutil
import stat
import subprocess
from datetime import datetime

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


def remove_path(path: Path):
    if not path.exists():
        return

    if path.is_dir():
        shutil.rmtree(path)
    else:
        path.unlink()


def try_run(*args: str) -> bool:
    try:
        subprocess.run(
            args,
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    except (FileNotFoundError, subprocess.CalledProcessError):
        return False

    return True


# Cookiecutter copies file modes, so a template read from the Nix store
# (`nix run github:KingPixelKP/CppCookieCutter`) yields read-only files.
for path in [template_root, *template_root.rglob("*")]:
    if not path.is_symlink():
        path.chmod(path.stat().st_mode | stat.S_IWUSR)

replace_path("__LIB_SLUG__","{{ '{{ cookiecutter.lib_slug }}' }}")
replace_path("__EXEC_SLUG__", "{{ '{{ cookiecutter.exec_slug }}' }}")
replace_path("__BENCHMARK_SLUG__", "{{ '{{ cookiecutter.bench_slug }}' }}")
replace_path("__MODULE_SLUG__", "{{ '{{ cookiecutter.module_slug }}' }}")

authors = "{{ cookiecutter.authors }}".split(",")
authors_raw = "{{ cookiecutter.authors }}"

replace_text("__AUTHORS__", "\n".join(f"* {a.strip()}" for a in authors))
replace_text("__COPYRIGHT_HOLDER__", authors_raw)
replace_text("__COPYRIGHT_YEAR__", str(datetime.now().year))

if "{{ cookiecutter.license }}" == "None":
    remove_path(template_root / "LICENSE")

if "{{ cookiecutter.include_ci }}" != "y":
    remove_path(template_root / ".github")
    remove_path(template_root / ".gitlab-ci.yml")

if "{{ cookiecutter.include_docs }}" != "y":
    remove_path(template_root / "docs")

project_type = "{{ cookiecutter.project_type }}"

if project_type == "app":
    remove_path(template_root / "libs" / "math")
    # Keep libs/ in git so it is obvious where new libraries go.
    (template_root / "libs" / ".gitkeep").touch()
elif project_type == "library":
    remove_path(template_root / "src")

if "{{ cookiecutter.initialize_git }}" == "y":
    if try_run("git", "init"):
        # Flakes only see git-tracked files, so stage everything before locking.
        if try_run("git", "add", "."):
            if try_run("nix", "flake", "lock"):
                try_run("git", "add", "flake.lock")

            if "{{ cookiecutter.create_initial_commit }}" == "y":
                try_run("git", "commit", "-m", "Initial commit")
