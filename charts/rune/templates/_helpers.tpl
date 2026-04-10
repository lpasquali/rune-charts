{{/*
Expand the name of the chart.
*/}}
{{- define "rune.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this
(by the DNS naming spec). If the release name contains the chart name it will be
used as a full name.
*/}}
{{- define "rune.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart label.
*/}}
{{- define "rune.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels applied to every resource.
*/}}
{{- define "rune.labels" -}}
helm.sh/chart: {{ include "rune.chart" . }}
{{ include "rune.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels used in Deployment / Service.
*/}}
{{- define "rune.selectorLabels" -}}
app.kubernetes.io/name: {{ include "rune.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use.
*/}}
{{- define "rune.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "rune.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Render the full image reference (repository:tag).
*/}}
{{- define "rune.image" -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion }}
{{- printf "%s:%s" .Values.image.repository $tag }}
{{- end }}

{{/*
Fully qualified Postgres subchart service name (must match charts/postgres templates).
*/}}
{{- define "rune.postgres.fullname" -}}
{{- $p := .Values.postgres | default dict }}
{{- if $p.fullnameOverride }}
{{- $p.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "postgres" $p.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
RUNE_DB_URL for the bundled Postgres StatefulSet (pod-0 + headless Service DNS).
Passwords with URL-reserved characters may need rune.database.existingSecret instead.
*/}}
{{- define "rune.dbUrl" -}}
{{- $pg := .Values.postgres }}
{{- $port := $pg.service.port | default 5432 }}
{{- $host := printf "%s-0.%s.%s.svc.cluster.local" (include "rune.postgres.fullname" .) (include "rune.postgres.fullname" .) .Release.Namespace }}
{{- printf "postgresql://%s:%s@%s:%v/%s" $pg.auth.username $pg.auth.password $host $port $pg.auth.database }}
{{- end }}
