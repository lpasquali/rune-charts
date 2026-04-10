# `postgres` subchart — values reference

Used as an optional dependency of `charts/rune` (`postgres.enabled`). Keys below are under `postgres:` in the parent chart.

| Key | Default | Description |
|---|---|---|
| `image.repository` | `docker.io/library/postgres` | Container image |
| `image.tag` | `17-alpine` | Image tag |
| `image.pullPolicy` | `IfNotPresent` | Pull policy |
| `nameOverride` / `fullnameOverride` | `""` | Name overrides |
| `service.port` | `5432` | Headless Service port |
| `auth.username` | `rune` | `POSTGRES_USER` |
| `auth.password` | `""` | `POSTGRES_PASSWORD` when the chart creates the Secret |
| `auth.database` | `rune` | `POSTGRES_DB` |
| `auth.existingSecret` | `""` | Use an existing Secret with `POSTGRES_*` keys; parent chart must supply `RUNE_DB_URL` separately |
| `initdbArgs` | UTF-8 `lc-*` | `POSTGRES_INITDB_ARGS` for `initdb` |
| `persistence.enabled` | `true` | Use a PVC for `PGDATA`; if `false`, `emptyDir` |
| `persistence.storageClass` | `""` | Storage class (`""` → cluster default) |
| `persistence.size` | `8Gi` | PVC size |
| `persistence.accessMode` | `ReadWriteOnce` | PVC access mode |
| `persistence.existingClaim` | `""` | Bind an existing PVC instead of creating one |
| `resources` | `{}` | Container resources |
| `podSecurityContext` | non-root, `fsGroup` 999, `RuntimeDefault` seccomp | Pod security |
| `containerSecurityContext` | `readOnlyRootFilesystem`, drop all caps | Container security |
