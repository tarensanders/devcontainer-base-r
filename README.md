# devcontainer-base-r

A published devcontainer image for R projects, bundling R 4, Claude Code,
Quarto, tidyverse, targets, and a standard set of VS Code extensions and
settings. Projects pull this image and add only their own R packages.

## Image URL

```
ghcr.io/tarensanders/r-base:latest
```

The image is rebuilt weekly to pick up upstream package updates. For
long-term reproducibility, pin by digest:

```
ghcr.io/tarensanders/r-base@sha256:<digest>
```

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
