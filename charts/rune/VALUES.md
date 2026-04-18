# Helm Chart Values Reference

All configurable values for the `rune` Helm chart.
Override any value with `--set key=value` or a custom `values.yaml` file.

---

## Image

| Key | Default | Description |
|---|---|---|
| `replicaCount` | `1` | Number of replicas |
| `image.repository` | `ghcr.io/lpasquali/rune` | Container image repository |
| `image.pullPolicy` | `IfNotPresent` | Image pull policy |
| `image.tag` | `"main-165ce44"` | Image tag (defaults to chart `appVersion` if empty) |
| `imagePullSecrets` | `[]` | List of image pull secret names |
| `nameOverride` | `""` | Override the chart name portion of resource names |
| `fullnameOverride` | `""` | Override the full resource name |

---

## Service Account

| Key | Default | Description |
|---|---|---|
| `serviceAccount.create` | `true` | Create a ServiceAccount |
| `serviceAccount.annotations` | `{}` | Annotations to add (e.g. IRSA role ARN, GKE GSA binding) |
| `serviceAccount.name` | `""` | Name; auto-generated from fullname template if empty |
| `serviceAccount.automountServiceAccountToken` | `false` | Mount the SA token into the pod (disable unless explicitly needed) |

---

## RBAC

| Key | Default | Description |
|---|---|---|
| `rbac.create` | `true` | Create ClusterRole and ClusterRoleBinding for the RUNE pod |
| `rbac.readOnly` | `true` | Grant read-only access to cluster resources (for HolmesGPT) |
| `rbac.allowSecretsAccess` | `false` | Allow cluster-wide `list`/`get` on Secrets (disabled by default per AVD-KSV-0041) |

---

## Pod configuration

| Key | Default | Description |
|---|---|---|
| `podAnnotations` | `{}` | Annotations applied to the Pod |
| `podLabels` | `{}` | Labels applied to the Pod (e.g. `azure.workload.identity/use: "true"`) |
| `podSecurityContext.runAsNonRoot` | `false` | Set `true` once the image runs as a non-root user |
| `securityContext.readOnlyRootFilesystem` | `true` | Mount root filesystem read-only |
| `securityContext.allowPrivilegeEscalation` | `false` | Prevent privilege escalation |
| `securityContext.capabilities.drop` | `["ALL"]` | Drop all Linux capabilities |

---

## Service

| Key | Default | Description |
|---|---|---|
| `service.type` | `ClusterIP` | Service type |
| `service.port` | `8080` | Service port |
| `service.annotations` | `{}` | Annotations (e.g. cloud load-balancer annotations) |

---

## Ingress

| Key | Default | Description |
|---|---|---|
| `ingress.enabled` | `false` | Enable an Ingress resource |
| `ingress.className` | `""` | IngressClass name; empty uses the cluster's default IngressClass (the one marked `ingressclass.kubernetes.io/is-default-class: "true"`). Chart is controller-agnostic (ADR 0008) |
| `ingress.annotations` | `{}` | Controller-agnostic annotations (e.g. cert-manager issuer). Do not add nginx-ingress-specific annotations here |
| `ingress.hosts` | see values.yaml | List of `{host, paths}` entries |
| `ingress.tls` | `[]` | TLS configuration; add entries for HTTPS |

## Gateway API (optional)

The chart ships an opt-in `HTTPRoute` for clusters that prefer Gateway API over Ingress. Independent of the `ingress:` block; either, both, or neither may be enabled. Requires `gateway.networking.k8s.io/v1` CRDs on the cluster; when `gatewayApi.enabled` is `false` the chart does not reference those CRDs at all (safe on clusters without them).

| Key | Default | Description |
|---|---|---|
| `gatewayApi.enabled` | `false` | Render an `HTTPRoute` and attach it to an existing Gateway |
| `gatewayApi.parentRef.name` | `""` | **Required** when enabled. Name of the `Gateway` to attach to (not created by this chart) |
| `gatewayApi.parentRef.namespace` | `""` | Namespace of the Gateway (empty → same namespace as this release) |
| `gatewayApi.parentRef.sectionName` | `""` | Optional listener name on the Gateway |
| `gatewayApi.parentRef.port` | `null` | Optional listener port on the Gateway |
| `gatewayApi.hostnames` | `[]` | Hostnames served by this route (must be allowed by the Gateway) |
| `gatewayApi.rules` | `[]` | HTTPRoute rules; empty → one default rule sending all paths to this release's Service on `service.port` |

---

## Resources & scheduling

| Key | Default | Description |
|---|---|---|
| `resources` | `{}` | CPU/memory requests and limits |
| `autoscaling.enabled` | `false` | Enable HPA |
| `autoscaling.minReplicas` | `1` | Minimum replicas |
| `autoscaling.maxReplicas` | `5` | Maximum replicas |
| `autoscaling.targetCPUUtilizationPercentage` | `80` | HPA CPU target |
| `nodeSelector` | `{}` | Node selector labels |
| `tolerations` | `[]` | Tolerations |
| `affinity` | `{}` | Affinity rules |

---

## Probes

| Key | Default | Description |
|---|---|---|
| `livenessProbe.httpGet.path` | `/healthz` | Liveness probe path |
| `livenessProbe.initialDelaySeconds` | `10` | Initial delay |
| `livenessProbe.periodSeconds` | `30` | Period |
| `livenessProbe.failureThreshold` | `3` | Failure threshold |
| `readinessProbe.httpGet.path` | `/healthz` | Readiness probe path |
| `readinessProbe.initialDelaySeconds` | `5` | Initial delay |
| `readinessProbe.periodSeconds` | `10` | Period |
| `readinessProbe.failureThreshold` | `3` | Failure threshold |

---

## RUNE application (`rune.*`)

### Backend / API server

| Key | Env var | Default | Description |
|---|---|---|---|
| `rune.backend` | `RUNE_BACKEND` | `"local"` | `local` (in-process) or `http` (remote API) |
| `rune.api.host` | `RUNE_API_HOST` | `"0.0.0.0"` | Bind address for the API server |
| `rune.api.port` | `RUNE_API_PORT` | `"8080"` | Listen port |
| `rune.api.baseUrl` | `RUNE_API_BASE_URL` | `""` | Remote API base URL (used in `http` backend mode) |
| `rune.api.tenant` | `RUNE_API_TENANT` | `"default"` | Tenant ID |
| `rune.api.authDisabled` | `RUNE_API_AUTH_DISABLED` | `"1"` | Set `"0"` and configure `tokens` to enable auth |
| `rune.api.tokens` | `RUNE_API_TOKENS` | `""` | Comma-separated `tenant:token` pairs. Use `existingSecret` in production. |

### Debug

| Key | Env var | Default | Description |
|---|---|---|---|
| `rune.debug` | `RUNE_DEBUG` | `"false"` | Enable verbose debug logging |

### Vast.ai

| Key | Env var | Default | Description |
|---|---|---|---|
| `rune.vastai.enabled` | `RUNE_VASTAI` | `"false"` | Enable Vast.ai GPU provisioning |
| `rune.vastai.template` | `RUNE_VASTAI_TEMPLATE` | `"c166c11f..."` | Vast.ai template hash |
| `rune.vastai.minDph` | `RUNE_VASTAI_MIN_DPH` | `"2.3"` | Minimum price per GPU-hour |
| `rune.vastai.maxDph` | `RUNE_VASTAI_MAX_DPH` | `"3.0"` | Maximum price per GPU-hour |
| `rune.vastai.reliability` | `RUNE_VASTAI_RELIABILITY` | `"0.99"` | Minimum host reliability score |
| `rune.vastai.stopInstance` | `RUNE_VASTAI_STOP_INSTANCE` | `"false"` | Stop Vast.ai instance after run |
| `rune.vastai.apiKey` | `VAST_API_KEY` | `""` | Vast.ai API key. Use `existingSecret` in production. |

### Ollama

| Key | Env var | Default | Description |
|---|---|---|---|
| `rune.ollama.url` | `RUNE_OLLAMA_URL` | `"http://ollama:11434"` | Base URL of the Ollama server |
| `rune.ollama.warmup` | `RUNE_OLLAMA_WARMUP` | `"true"` | Warm up the model before each run |
| `rune.ollama.warmupTimeout` | `RUNE_OLLAMA_WARMUP_TIMEOUT` | `"300"` | Warmup timeout in seconds |

### Agent / Benchmark

| Key | Env var | Default | Description |
|---|---|---|---|
| `rune.question` | `RUNE_QUESTION` | `"What is unhealthy in this Kubernetes cluster?"` | Default question |
| `rune.model` | `RUNE_MODEL` | `"llama3.1:8b"` | Default Ollama model tag |
| `rune.idempotencyKey` | `RUNE_IDEMPOTENCY_KEY` | `""` | Idempotency key for job submission |

### Kubeconfig

| Key | Env var | Default | Description |
|---|---|---|---|
| `rune.kubeconfig` | `RUNE_KUBECONFIG` | `""` | Path to kubeconfig inside the pod (leave empty to use in-cluster SA) |
| `rune.kubeconfigSecret` | — | `""` | Name of a pre-existing Secret with a `kubeconfig` key; mounted at `/root/.kube/config` |

### Secrets and extra environment

| Key | Default | Description |
|---|---|---|
| `rune.existingSecret` | `""` | Name of an existing Secret whose keys are injected as env vars |
| `rune.extraEnv` | `[]` | List of `{name, value}` env var entries |
| `rune.extraEnvFrom` | `[]` | List of `envFrom` sources (ConfigMaps, Secrets) |

---

## Cloud provider credentials (`cloud.*`)

Three authentication methods are supported for every provider.  Use the most
secure method available in your environment:

| Method | How | Recommendation |
|---|---|---|
| **Method 1** — Workload Identity | Annotate `serviceAccount.annotations` | **Recommended** — zero secrets in the cluster |
| **Method 2** — Existing Secret | Set `existingSecret`; create with `kubectl create secret` | Secure — secrets managed out-of-band |
| **Method 3** — Inline values | Set values directly in values.yaml | Development only — encrypt with `helm-secrets` + SOPS/age before committing |

### AWS

| Key | Description |
|---|---|
| `cloud.aws.existingSecret` | Name of a Secret with `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_DEFAULT_REGION` keys |
| `cloud.aws.region` | `AWS_DEFAULT_REGION` (Method 3) |
| `cloud.aws.accessKeyId` | `AWS_ACCESS_KEY_ID` (Method 3 — insecure) |
| `cloud.aws.secretAccessKey` | `AWS_SECRET_ACCESS_KEY` (Method 3 — insecure) |
| `cloud.aws.sessionToken` | `AWS_SESSION_TOKEN` (Method 3 — optional STS temp creds) |

**Method 1 — IRSA:**

```yaml
serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/rune-role
```

### Azure

| Key | Description |
|---|---|
| `cloud.azure.existingSecret` | Name of a Secret with `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID` |
| `cloud.azure.tenantId` | `AZURE_TENANT_ID` (Method 3) |
| `cloud.azure.subscriptionId` | `AZURE_SUBSCRIPTION_ID` (Method 3) |
| `cloud.azure.clientId` | `AZURE_CLIENT_ID` (Method 3) |
| `cloud.azure.clientSecret` | `AZURE_CLIENT_SECRET` (Method 3 — insecure) |

**Method 1 — Azure Workload Identity:**

```yaml
serviceAccount:
  annotations:
    azure.workload.identity/client-id: <MANAGED_IDENTITY_CLIENT_ID>
podLabels:
  azure.workload.identity/use: "true"
```

### GCP

| Key | Description |
|---|---|
| `cloud.gcp.existingSecret` | Name of a Secret with a `credentials.json` key |
| `cloud.gcp.credentialsMountPath` | Mount path for the credentials file (default: `/var/secrets/gcp`) |
| `cloud.gcp.project` | `GOOGLE_CLOUD_PROJECT` (Method 3) |

**Method 1 — GKE Workload Identity:**

```yaml
serviceAccount:
  annotations:
    iam.gke.io/gcp-service-account: rune@PROJECT.iam.gserviceaccount.com
```

### Remote Kubernetes cluster

| Key | Default | Description |
|---|---|---|
| `cloud.remoteKubernetes.enabled` | `false` | Mount a remote cluster kubeconfig |
| `cloud.remoteKubernetes.existingSecret` | `""` | Secret with a `kubeconfig` key |
| `cloud.remoteKubernetes.mountPath` | `"/var/secrets/kubeconfig"` | Mount path inside the container |

### External Secrets Operator (ESO)

Requires [External Secrets Operator](https://external-secrets.io) installed.

| Key | Default | Description |
|---|---|---|
| `cloud.externalSecrets.enabled` | `false` | Create `ExternalSecret` resources |
| `cloud.externalSecrets.secretStoreName` | `"cluster-secret-store"` | Name of the `(Cluster)SecretStore` |
| `cloud.externalSecrets.secretStoreKind` | `"ClusterSecretStore"` | `ClusterSecretStore` or `SecretStore` |
| `cloud.externalSecrets.refreshInterval` | `"1h"` | How often to sync secrets from the store |
| `cloud.externalSecrets.aws.secretPath` | `"rune/aws-credentials"` | Remote key path for AWS credentials |
| `cloud.externalSecrets.azure.secretPath` | `"rune/azure-credentials"` | Remote key path for Azure credentials |
| `cloud.externalSecrets.gcp.secretPath` | `"rune/gcp-credentials"` | Remote key path for GCP credentials |

---

## Database (`rune.database.*` / `postgres.*`)

`RUNE_DB_URL` is always injected from a Kubernetes `Secret` (`secretKeyRef`), never from the ConfigMap.

| Key | Default | Description |
|---|---|---|
| `postgres.enabled` | `false` | Deploy the bundled `charts/postgres` subchart |
| `postgres.image.repository` | `docker.io/library/postgres` | Postgres image repository |
| `postgres.image.tag` | `"17-alpine"` | Postgres image tag |
| `postgres.image.pullPolicy` | `IfNotPresent` | Image pull policy |
| `postgres.service.port` | `5432` | Service port (used in `RUNE_DB_URL`) |
| `postgres.auth.username` | `rune` | Database user (`POSTGRES_USER`) |
| `postgres.auth.password` | `""` | Database password when the chart creates the credentials Secret |
| `postgres.auth.database` | `rune` | Database name (`POSTGRES_DB`) |
| `postgres.auth.existingSecret` | `""` | Pre-created Secret with `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`. If set, **must** set `rune.database.existingSecret` with `RUNE_DB_URL`. |
| `postgres.initdbArgs` | UTF-8 `lc-*` | Passed as `POSTGRES_INITDB_ARGS` |
| `postgres.persistence.*` | see `values.yaml` | PVC / `emptyDir` when disabled |
| `postgres.resources` | `{}` | Postgres container resources |
| `rune.database.existingSecret` | `""` | Secret containing `RUNE_DB_URL` (external DB, or required when `postgres.auth.existingSecret` is set) |
| `rune.database.existingSecretKey` | `RUNE_DB_URL` | Key name inside that Secret |

Subchart-only options (`nameOverride`, `fullnameOverride`, security contexts, etc.) match `charts/postgres/values.yaml`.

See also: `charts/postgres/VALUES.md`.
