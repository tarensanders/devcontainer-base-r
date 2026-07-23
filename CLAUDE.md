# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

This repo defines a published devcontainer base image for R projects: `ghcr.io/tarensanders/r-base:latest`. There is no application code — the entire product is the image built from `.devcontainer/devcontainer.json`. Downstream R projects pull this image and add only their own R packages.

## How it builds and ships

- `.github/workflows/build.yml` builds the image with `devcontainers/ci` and pushes to GHCR on every push to `main`, weekly (Mondays 00:00 UTC, to pick up upstream R package updates), and on manual dispatch.
- There is no local build/test/lint command. To validate a change before pushing, either open the repo in VS Code and rebuild the devcontainer, or run `devcontainer build --workspace-folder .` if the devcontainer CLI is available.
- Pushing to `main` publishes the image, which affects all downstream projects using `:latest`.

## Key design constraints

- **`devcontainer.json` is the single source of truth.** The `customizations.vscode` extensions and settings are baked into the published image's `devcontainer.metadata` label, and downstream projects inherit them from there. Downstream projects must not repeat them — so changes here propagate to every consumer.
- **README.md mirrors devcontainer.json.** The package list, extension table, and feature table in README.md must be kept in sync when editing `.devcontainer/devcontainer.json`.
- **Feature install order matters:** Node.js is forced first via `overrideFeatureInstallOrder` because Claude Code (and some R packages) require it.
- R packages install via the `rocker-org/devcontainer-features/r-packages` feature; GitHub-hosted packages use the `github::owner/repo` prefix in the same comma-separated `packages` string.
