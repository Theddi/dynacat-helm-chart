{{- define icons.path }}
{{ ternary "/assets/icons" "/icons" $.Values.selfhstIcons.dynacatInternal }}
{{- end }}