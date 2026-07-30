# devcontainer-base-r

A published devcontainer image for R projects, bundling R 4, Claude Code,
Quarto, tidyverse, targets, and a standard set of VS Code extensions and
settings. Projects pull this image and add only their own R packages.

## Image URL

```text
ghcr.io/tarensanders/r-base:latest
```

The image is rebuilt weekly to pick up upstream package updates. For
long-term reproducibility, pin by digest:

```text
ghcr.io/tarensanders/r-base@sha256:<digest>
```

## What's included

### Base image

R 4.5 via [`rocker/r-ver:4.5`](https://rocker-project.org/), which includes R, radian, and common system libraries. Pinned to 4.5 because R 4.6 breaks the vscode-R session watcher ([REditorSupport/vscode-R#1696](https://github.com/REditorSupport/vscode-R/issues/1696)); revert to `:4` once vscode-R 3.0.0 is stable.

### Features

| Feature | Description |
| --- | --- |
| Node.js | Required by Claude Code and some R packages |
| Quarto CLI | Quarto document rendering |
| Claude Code | Anthropic Claude Code CLI and VS Code extension |
| R history | Persistent R console history across container rebuilds |
| GitHub CLI | `gh` for PRs, issues, releases, and API calls |
| Docker (outside-of-docker) | `docker` CLI talking to the host daemon via the mounted socket |
| Shell utilities | `jq`, `ripgrep` (`rg`), `fd-find` (`fdfind`), `bat` (`batcat`), `tree`, `htop` |

### R packages

Standard CRAN packages: `broom`, `broom.helpers`, `broom.mixed`, `bslib`, `conflicted`, `crew`, `data.table`, `devtools`, `dotenv`, `DT`, `foreign`, `glue`, `gt`, `gtsummary`, `here`, `janitor`, `knitr`, `labelled`, `languageserver`, `lavaan`, `lintr`, `lme4`, `lmerTest`, `markdown`, `qs2`, `quarto`, `readxl`, `rlang`, `rmarkdown`, `rstudioapi`, `shiny`, `shinyWidgets`, `shinybusy`, `tarchetypes`, `targets`, `tidyverse`, `visNetwork`

From GitHub: `milesmcbain/fnmate`, `milesmcbain/tflow`

### VS Code extensions

| Extension | Description |
| --- | --- |
| `REditorSupport.r` | R language support |
| `RDebugger.r-debugger` | R debugger |
| `Posit.air-vscode` | Air R formatter (default R formatter) |
| `quarto.quarto` | Quarto document support |
| `anthropic.claude-code` | Claude Code |
| `GitHub.copilot` + `copilot-chat` | GitHub Copilot |
| `GitHub.vscode-pull-request-github` | GitHub Pull Requests |
| `ms-python.python` + `charliermarsh.ruff` | Python support with Ruff formatter |
| `ms-toolsai.jupyter` | Jupyter notebooks |
| `yzhang.markdown-all-in-one` + `DavidAnson.vscode-markdownlint` | Markdown editing and linting |
| `streetsidesoftware.code-spell-checker` | Spell checker (Australian English + scientific terms) |
| `redhat.vscode-yaml` | YAML support |
| `mechatroner.rainbow-csv` | CSV highlighting |
| `janisdd.vscode-edit-csv` | CSV table editor |
| `tomoki1207.pdf` | PDF viewer |
| `christian-kohler.path-intellisense` | Path autocomplete |
| `ms-azuretools.vscode-docker` | Docker support |

## Consuming from a project

Create `.devcontainer/devcontainer.json` in your project with only the
project-specific additions. Extensions and settings are inherited from
the base image's `devcontainer.metadata` label — do not repeat them here.

```jsonc
{
  "name": "<project-name>",
  "image": "ghcr.io/tarensanders/r-base:latest",
  "features": {
    "ghcr.io/rocker-org/devcontainer-features/r-packages:1": {
      "packages": "<comma-separated project-specific packages>",
      "installSystemRequirements": true
    }
  },
  "mounts": [
    "source=claude-code-config-${devcontainerId},target=/home/rstudio/.claude,type=volume",
    "source=gh-config-${devcontainerId},target=/home/rstudio/.gh,type=volume"
    // Uncomment for projects that mount external data:
    // ,"source=${localEnv:DATA_DIR},target=/workspace/data,type=bind"
  ]
}
```

## Updating an existing project to the latest image

Rebuilding a devcontainer reuses the locally cached image — it does not
check GHCR for a newer one. To pick up a new base image in a project:

```sh
docker pull ghcr.io/tarensanders/r-base:latest
```

Then in VS Code run **Dev Containers: Rebuild Container** from the Command
Palette (`Ctrl+Shift+P`). Claude Code login and R history survive the
rebuild — they live in named volumes, not the container.

## Using the image in CI

The published image is a normal Docker image and can be used directly in
GitHub Actions without any devcontainer tooling:

```yaml
jobs:
  pipeline:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/tarensanders/r-base:latest
    steps:
      - uses: actions/checkout@v4
      - run: Rscript -e 'targets::tar_make()'
```

For reproducible artefacts, pin by digest rather than `:latest`.

## Notes

- **Extensions and settings are inherited** from the base image's
  `devcontainer.metadata` label. Projects should not repeat the extensions
  list or settings block — doing so causes drift when the base updates.
- **Claude Code login persists across rebuilds.** The base image sets
  `CLAUDE_CONFIG_DIR=/home/rstudio/.claude`, so all Claude Code state
  (including `.claude.json`, which otherwise lives outside `~/.claude`)
  lands in the volume mounted at `/home/rstudio/.claude`. Each project's
  volume is keyed by `${devcontainerId}`, so you authenticate once per
  project, not once per rebuild.
- **GitHub CLI login persists across rebuilds** the same way. The base
  image sets `GH_CONFIG_DIR=/home/rstudio/.gh`, so the token written by
  `gh auth login` (the device-code flow works inside the container) lands
  in the volume mounted at `/home/rstudio/.gh`. Note that plain
  `git push`/`pull` needs none of this — VS Code forwards your host git
  credentials and SSH agent automatically; `gh` auth is only for API
  operations (PRs, releases, etc.).
- **The image is rebuilt weekly** (Mondays 00:00 UTC) and on every push to
  `main`. Pin by digest for reproducibility.
- **A GitHub Release is created whenever a build changes R package
  versions**, listing the new digest and a diff of the changes. Watch the
  repo's releases to be notified when it's worth re-pulling the image.
  Weekly rebuilds where nothing changed still push a new digest (no-cache
  builds are not byte-reproducible) but create no release.
