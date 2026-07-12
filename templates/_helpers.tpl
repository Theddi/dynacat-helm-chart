{{- define "dynacat.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "dynacat.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end }}

{{- define "dynacat.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{ include "dynacat.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "dynacat.selectorLabels" -}}
app.kubernetes.io/name: {{ include "dynacat.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "dynacat.icons.fullname" -}}
{{- printf "%s-selfhst-icons" (include "dynacat.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "dynacat.icons.selectorLabels" -}}
app.kubernetes.io/name: selfhst-icons
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* Filesystem directory dynacat serves under the /assets/ URL path */}}
{{- define "dynacat.assetsPath" -}}
{{- $config := .Values.config | default dict -}}
{{- $server := $config.server | default dict -}}
{{- index $server "assets-path" | default "/app/assets" -}}
{{- end }}

{{/* Port dynacat listens on, kept in sync with config.server.port */}}
{{- define "dynacat.port" -}}
{{- $config := .Values.config | default dict -}}
{{- $server := $config.server | default dict -}}
{{- $server.port | default 8080 -}}
{{- end }}
