{{/*
Expand the name of the chart.
*/}}
{{- define "rune-audit.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
>>>>>>> 9948934 (feat: add Helm chart for rune-audit CronJob deployment)
*/}}
{{- define "rune-audit.fullname" -}}
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
<<<<<<< HEAD
Create chart name and version as used by the chart label.
=======
Create chart label.
*/}}
{{- define "rune-audit.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
Common labels applied to every resource.
*/}}
{{- define "rune-audit.labels" -}}
helm.sh/chart: {{ include "rune-audit.chart" . }}
{{ include "rune-audit.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
Selector labels.
*/}}
{{- define "rune-audit.selectorLabels" -}}
app.kubernetes.io/name: {{ include "rune-audit.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
Create the name of the service account to use.
*/}}
{{- define "rune-audit.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "rune-audit.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
<<<<<<< HEAD
=======

{{/*
Render the full image reference (repository:tag).
*/}}
{{- define "rune-audit.image" -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion }}
{{- printf "%s:%s" .Values.image.repository $tag }}
{{- end }}
>>>>>>> 9948934 (feat: add Helm chart for rune-audit CronJob deployment)
