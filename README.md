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

R 4 via [`rocker/r-ver:4`](https://rocker-project.org/), which includes R, radian, and common system libraries.

### Features

| Feature | Description |
| --- | --- |
| Node.js | Required by Claude Code and some R packages |
| Quarto CLI | Quarto document rendering |
| Claude Code | Anthropic Claude Code CLI and VS Code extension |
| R history | Persistent R console history across container rebuilds |

### R packages

Standard CRAN packages: `broom`, `broom.helpers`, `conflicted`, `crew`, `data.table`, `devtools`, `dotenv`, `foreign`, `glue`, `gt`, `gtsummary`, `here`, `janitor`, `knitr`, `languageserver`, `qs2`, `readxl`, `rlang`, `rmarkdown`, `rstudioapi`, `shiny`, `shinyWidgets`, `shinybusy`, `tarchetypes`, `targets`, `tidyverse`, `visNetwork`

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
    "source=claude-code-config-${devcontainerId},target=/home/rstudio/.claude,type=volume"
    // Uncomment for projects that mount external data:
    // ,"source=${localEnv:DATA_DIR},target=/workspace/data,type=bind"
  ]
}
```

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
- **The image is rebuilt weekly** (Mondays 00:00 UTC) and on every push to
  `main`. Pin by digest for reproducibility.
