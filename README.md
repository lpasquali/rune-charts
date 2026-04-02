# rune-charts

Standalone Helm chart repository for RUNE.

## Contents

- `charts/rune` — the primary Helm chart for deploying the RUNE API server workload
- `.github/workflows/` — CI and quality/security gates for chart linting, rendering, packaging, and scanning

## Local Usage

```bash
helm lint ./charts/rune
helm template rune ./charts/rune >/tmp/rune-rendered.yaml
helm package ./charts/rune --destination dist/
```

## Secrets Handling

The chart includes a template secret values example intended for encrypted workflows using SOPS/age and `helm-secrets`.

See `charts/rune/secret.values.example.yaml`.

## Relationship to Other Repositories

- application source: `rune`
- operator source: `rune-operator`
- documentation: `rune-docs`