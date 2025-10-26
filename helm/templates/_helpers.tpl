{{- define "epro.fullname" -}}
{{- printf "%s-%s" .Release.Name "epro" | trunc 63 | trimSuffix "-" -}}
{{- end }}
