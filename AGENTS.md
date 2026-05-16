# AGENTS.md — Armbian Build Framework

## Entry point

```bash
./compile.sh [COMMAND] [KEY=VALUE...]
```

- No args = interactive mode (defaults to OS image build or docker under macOS)
- `./compile.sh build` = non-interactive OS image build
- Source path **must not contain whitespace**; requires **Bash 5.x**

## Key commands

| Command | What it does |
|---------|-------------|
| `build` | Full OS image (default) |
| `kernel` | Build kernel artifact only |
| `kernel-config` | Interactive kernel config (`KERNEL_CONFIGURE=yes`) |
| `uboot` | Build u-boot artifact only |
| `firmware` | Build firmware artifact |
| `requirements` | Install host build deps (**run first on new host**, needs sudo) |
| `docker` | Build inside Docker container |
| `flash` | Flash built image to SD/USB |
| `inventory-boards` | List all supported boards as JSON |
| `configdump` | Dump resolved configuration as JSON |
| `rewrite-kernel-patches` | Rebase kernel patches via round-trip to git |
| `rewrite-uboot-patches` | Rebase u-boot patches via round-trip to git |
| `dts-check` | Validate DTS/DTB files (builds nothing) |

## Essential build parameters (KEY=VALUE)

- `BOARD=<name>` — board config name (e.g. `rockchip-rk3528-fastyumjin`, `uefi-x86`)
- `BRANCH=<current|edge|legacy|vendor>` — kernel branch
- `RELEASE=<noble|bookworm|jammy>` — userspace release
- `BUILD_DESKTOP=<yes|no>`, `BUILD_MINIMAL=<yes|no>`
- `KERNEL_CONFIGURE=<yes|no>` — interactive kernel config during build
- `CREATE_PATCHES=<yes>` — pause build to create patches from source dirs
- `CLEAN_LEVEL=<...>` — build cache cleaning policy
- `EXPERT=<yes>` — show all board options
- `COMPRESS_OUTPUTIMAGE=<sha,img,xz|...>` — output compression
- `SHARE_LOG=<yes>` — upload logs to armlog (CI default)

## Common workflow

```bash
# First-time setup
sudo ./compile.sh requirements

# Build a full image
./compile.sh build BOARD=uefi-x86 BRANCH=current RELEASE=noble BUILD_MINIMAL=yes

# Build just the kernel
./compile.sh kernel BOARD=rockchip-rk3528-fastyumjin BRANCH=vendor

# Interactive kernel config
./compile.sh kernel-config BOARD=xxx BRANCH=yyy
```

## Directory layout

| Path | Purpose |
|------|---------|
| `compile.sh` | **Only** file the user should invoke; do NOT edit |
| `lib/single.sh` | Bash 5.x/macOS checks, loads CLI system |
| `lib/library-functions.sh` | **Auto-generated** — do NOT edit. Regenerate with `bash lib/tools/gen-library.sh` |
| `lib/functions/` | All shell function scripts, sourced in sorted order |
| `lib/functions/cli/` | CLI command definitions (`commands.sh`) and handlers |
| `config/boards/*.conf` | Stable board configs; also `.wip` (WIP), `.csc`/`.tvb` (community), `.eos` (EOL) |
| `config/sources/` | SoC family definitions (`.conf`, `.inc`) |
| `extensions/*.sh` | Extension scripts (70+) activated via `ENABLE_EXTENSIONS` |
| `patch/` | Kernel / u-boot patches by family and branch |
| `userpatches/` | User override directory (kernel patches, config files) |
| `cache/`, `output/`, `.tmp/` | Build artifacts (gitignored) |
| `packages/` | Debian packaging scripts, BSP files, firmware blobs |

## Linting & formatting

```bash
# ShellCheck (auto-downloads, checks config + lib code)
bash lib/tools/shellcheck.sh

# shfmt formatting (auto-downloads, checks all shell files)
bash lib/tools/shellfmt.sh
```

- ShellCheck severity: `error` for config files, `critical` for lib code
- Specific SC codes are excluded (SC2034, SC2207, SC2046, SC2086, SC2206)

## Style conventions (`.editorconfig`)

- Shell scripts (`.sh`, `.inc`, `.conf`, `.eos`, `.wip`, `.tvb`, `.csc`): **tabs**, indent 4
- YAML: spaces, indent 2
- Python: spaces, indent 4, max line 150
- `binary_next_line = false`, `switch_case_indent = true`, `space_redirects = true`
- Globally: LF endings, UTF-8, trim trailing whitespace (except `.md` and `.patch`)

## Key constraints

- The framework is **Bash-only** (Python only for auxiliary tooling scripts in `lib/tools/`)
- Config files are shell-sourced — they can set variables, call functions, etc.
- Board configs live in `config/boards/`, sourced dynamically by name
- All scripts use `set -e` (errexit) and `set -o errtrace`
- Always regenerate `lib/library-functions.sh` after adding/removing function files under `lib/functions/`
- `./compile.sh` requires the repo root as working directory

## Architecture notes

- The CLI system (`lib/functions/cli/`) maps 1st arguments to handlers via `armbian_register_commands`
- Each handler has `cli_<name>_pre_run` and `cli_<name>_run` functions
- The "undecided" handler auto-launches `build` (Linux) or `docker` (macOS)
- Extension system composes shell functions dynamically at build time
- Artifact system handles incremental builds per component (kernel, u-boot, firmware, rootfs, BSP, etc.)
