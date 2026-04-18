# RUNE Crossplane Compositions

Optional, opt-in infrastructure-as-code provisioning for RUNE's external resources (PostgreSQL, object storage), delivered as Crossplane v2 Compositions.

## Why

RUNE deployments consume external PostgreSQL and object storage via Kubernetes Secrets (`rune-db-secret`, `rune-s3-secret`) — the stable contract introduced with the `existingSecret` values in the rune Helm chart. This folder provides Crossplane **CompositeResourceDefinitions** (XRDs) and **Compositions** that, given a `RuneDatabase` / `RuneObjectStore` Claim, provision the underlying resource **and** write those Secrets for the chart to pick up verbatim.

See **[ADR 0007](https://github.com/lpasquali/rune-docs/blob/main/docs/architecture/adrs/0007-crossplane-infrastructure-provisioning.md)** in `rune-docs` for the decision record, provider selection, cascade-deletion rationale, and SLSA L3 exception.

## Scope

```
crossplane/
├── xrds/                         # Composite type definitions (v1, LegacyCluster)
│   ├── runedatabase.yaml         # RuneDatabase  (group database.infra.rune.ai)
│   └── runeobjectstore.yaml      # RuneObjectStore (group storage.infra.rune.ai)
├── compositions/
│   ├── aws/      composition.yaml # RDS + S3 + IAM
│   ├── gcp/      composition.yaml # Cloud SQL + GCS + IAM
│   ├── azure/    composition.yaml # Flexible Server + Blob Storage
│   ├── cnpg/     composition.yaml # On-prem CNPG PostgreSQL
│   └── minio/    composition.yaml # On-prem MinIO Tenant
├── examples/                      # RuneDatabase / RuneObjectStore Claims
│   ├── rune-database-{aws,gcp,azure,cnpg}.yaml
│   └── rune-objectstore-{aws,gcp,azure,minio}.yaml
└── rbac.yaml                      # ClusterRole for provider-kubernetes
```

## Stable contract (zero chart changes)

Every Composition's **last** step writes one of these Secrets. The `rune` chart consumes them unchanged via `rune.database.existingSecret` / `s3.existingSecret`.

| Secret           | Keys                                                   | Consumed by                  |
|------------------|--------------------------------------------------------|------------------------------|
| `rune-db-secret` | `RUNE_DB_URL`                                          | `rune.database.existingSecret` |
| `rune-s3-secret` | `S3_ACCESS_KEY_ID`, `S3_SECRET_ACCESS_KEY`, `S3_ENDPOINT`, `S3_BUCKET` | `s3.existingSecret` |

## Prerequisites

Install once per cluster (outside this chart):

- **Crossplane v2.2.x** (core) — e.g. `helm install crossplane crossplane-stable/crossplane -n crossplane-system --create-namespace`.
- **Functions**: `function-patch-and-transform`, `function-go-templating`, `function-auto-ready`.
- **Provider**: `provider-kubernetes` with a `ProviderConfig` named `kubernetes-provider` (referenced by every Composition here).
- **Cloud providers only**: `upbound/provider-aws`, `upbound/provider-gcp`, `upbound/provider-azure` with the appropriate `ProviderConfig`.
- **On-prem only**: the **CNPG operator** (for `RuneDatabase`/cnpg) and/or the **MinIO operator** (for `RuneObjectStore`/minio). Neither is installed by this chart.

## Using a Composition

Apply one of the example Claims and match it with a Helm values overlay:

```sh
# 1. Provision infra
kubectl apply -f crossplane/examples/rune-database-cnpg.yaml
kubectl apply -f crossplane/examples/rune-objectstore-minio.yaml

# 2. Install the rune chart pointing at the Secrets the Composition wrote
helm install rune ./charts/rune \
    --namespace rune --create-namespace \
    --set rune.database.existingSecret=rune-db-secret \
    --set s3.existingSecret=rune-s3-secret
```

For cloud deployments, ready-made values overlays live at `charts/rune/values-crossplane-{aws,gcp,azure}.yaml`.

## Secret deletion policy

Every Composition sets `deletionPolicy: Delete` on the provider-kubernetes `Object` that writes the Secret. Deleting the `RuneDatabase` / `RuneObjectStore` Claim cascades to deletion of the underlying managed resource **and** the Secret — on purpose, to avoid orphaned credentials. See ADR 0007 for the rationale and rollback expectations.

## Local validation

```sh
crossplane beta validate crossplane/xrds crossplane/compositions/**/composition.yaml
```

The same command runs in CI as `helm / RuneGate/Validate/Crossplane` in `quality-gates.yml`.

## Out of scope

- **rune-operator readiness gate** (`RuneBenchmark.spec.infrastructureRef`) — tracked as a separate follow-up in the epic.
- **Airgapped bundling** — the airgapped `build-bundle.sh` carries Crossplane images behind `--include-crossplane`; Helm-level automation lives in `rune-airgapped`.
