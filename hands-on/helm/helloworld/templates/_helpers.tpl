{{- define "mycharts.labels"  }}
  labels:
    generator: helm
    deployedby: rumeysa
    date: {{ now | htmlDate }}
{{- end }}

{{- define "secret.defaultlabels"}}
name: secrets
namespaces: {{ .Release.Namespace}}
release: {{ .Release.Name}}
chart: secret
createdBy: rumeysa
{{- end}}

