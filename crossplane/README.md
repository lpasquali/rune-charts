# Crossplane Infrastructure Provisioning for RUNE

This directory contains Crossplane XRDs (Composite Resource Definitions), Compositions, and
examples for declarative provisioning of PostgreSQL and S3 resources for RUNE installations.

## Quick Start

### Prerequisites

- Kubernetes cluster (kind, EKS, GKE, AKS, or on-prem)
- Crossplane v2.2.0 installed
- CNPG operator (if using on-prem PostgreSQL)
- Cloud provider credentials configured (if using AWS/GCP/Azure)

### Installation

1. **Install Crossplane**
   ```bash
   helm install crossplane oci://ghcr.io/crossplane/crossplane:v2.2.0 \
     --namespace crossplane-system --create-namespace
   ```

2. **Install CNPG operator** (for on-prem path)
   ```bash
   helm install cnpg cloudnative-pg/cloudnative-pg \
     --namespace cnpg-system --create-namespace
   ```

3. **Apply Crossplane package**
   ```bash
   kubectl apply -f xrds/
   kubectl apply -f functions.yaml
   kubectl apply -f providers.yaml
   kubectl apply -f rbac/
   kubectl apply -f config/
   ```

4. **Apply a RuneDatabase Claim**
   ```bash
   kubectl apply -f examples/rune-database-cnpg.yaml
   ```

5. **Verify Secret written**
   ```bash
   kubectl get secret rune-db-secret -n rune -o jsonpath='{.data.RUNE_DB_URL}' | base64 -d
   ```

6. **Install RUNE (charts unchanged)**
   ```bash
   helm install rune . -f ../charts/rune/values-crossplane-cnpg.yaml -n rune
   ```

## Architecture

### XRDs

- **`RuneDatabase`** — Provision PostgreSQL (AWS RDS, GCP Cloud SQL, Azure Flexible Server, or on-prem CNPG)
- **`RuneObjectStore`** — Provision S3-compatible storage (AWS S3, GCP GCS, Azure Blob, or on-prem MinIO)

Both write the exact Secrets that `rune-charts` already consumes via `existingSecret` in Helm values.

### Compositions

- `compositions/cnpg/` — on-prem PostgreSQL via CNPG operator
- `compositions/minio/` — on-prem S3 via MinIO Tenant
- `compositions/aws/` — AWS RDS + S3 (Phase 1b)
- `compositions/gcp/` — GCP Cloud SQL + GCS (Phase 1b)
- `compositions/azure/` — Azure Flexible Server + Blob (Phase 1b)

## Documentation

- [Getting Started](docs/getting-started.md)
- [On-prem Airgapped Deployments](docs/airgapped.md)
- [AWS](docs/aws.md) | [GCP](docs/gcp.md) | [Azure](docs/azure.md)
- [Migration Path](docs/migration.md)

## References

- [ADR 0007: Crossplane Infrastructure Provisioning](../../docs/architecture/adrs/0007-crossplane-infrastructure-provisioning.md)
- [Crossplane v2.2](https://docs.crossplane.io/latest/)
- [Epic #266](https://github.com/lpasquali/rune-docs/issues/266)
