# Thin wrapper over the CMake presets and flake outputs, so every command works
# from any shell without direnv. Build logic lives in CMakePresets.json and flake.nix.
#
#   make test PRESET=asan

PRESET ?= debug
BUILD_DIR := .build/$(PRESET)

# Inside `nix develop` or direnv run tools directly; otherwise enter the dev shell per command.
ifdef IN_NIX_SHELL
NIX :=
else
NIX := nix develop --command
endif

.PHONY: help configure build test{% if cookiecutter.project_type in ["app", "hybrid"] %} run{% endif %} format check static shell clean
.DEFAULT_GOAL := help

help: ## Show this help
	@grep -E '^[a-z]+:.*## ' $(MAKEFILE_LIST) | awk -F ':.*## ' '{ printf "  %-10s %s\n", $$1, $$2 }'

# Configure only when the build directory is missing; Ninja re-runs CMake when CMakeLists change.
$(BUILD_DIR)/CMakeCache.txt:
	$(NIX) cmake --preset $(PRESET)

configure: $(BUILD_DIR)/CMakeCache.txt ## Configure PRESET (default: debug)

build: configure ## Build PRESET
	$(NIX) cmake --build --preset $(PRESET)

test: build ## Build and run the tests for PRESET
	$(NIX) ctest --preset $(PRESET)
{%- if cookiecutter.project_type in ["app", "hybrid"] %}

run: build ## Build and run the main executable
	cd $(BUILD_DIR)/bin && ./{{ cookiecutter.project_slug }}
{%- endif %}

format: ## Format Nix and C/C++ files
	nix fmt

check: ## Sandboxed build, tests and format check (same as CI)
	nix flake check -L

static: ## Fully static release build into ./result (Linux only)
	nix build -L .#static

shell: ## Open the dev shell in your current shell
	nix develop --command "$${SHELL:-bash}"

clean: ## Remove build directories and nix result links
	rm -rf .build result result-*
