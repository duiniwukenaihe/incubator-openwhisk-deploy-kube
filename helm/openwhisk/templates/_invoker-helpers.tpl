# Licensed to the Apache Software Foundation (ASF) under one or more contributor
# license agreements; and to You under the Apache License, Version 2.0.

{{- define "openwhisk.docker_volumes" -}}
- name: cgroup
  hostPath:
    path: "/sys/fs/cgroup"
- name: runc
  hostPath:
    path: "/run/runc"
- name: dockerrootdir
  hostPath:
    {{- if .Values.invoker.containerFactory.dind }}
    path: "/dind/docker/containers"
    {{- else }}
    path: "/var/lib/docker/containers"
    {{- end }}
- name: dockersock
  hostPath:
    path: "/var/run/docker.sock"
{{- end -}}

{{- define "openwhisk.docker_volume_mounts" -}}
- name: cgroup
  mountPath: "/sys/fs/cgroup"
- name: runc
  mountPath: "/run/runc"
- name: dockersock
  mountPath: "/var/run/docker.sock"
- name: dockerrootdir
  mountPath: "/containers"
{{- end -}}

{{- define "openwhisk.docker_pull_runtimes" -}}
- name: docker-pull-runtimes
  image: "{{- .Values.docker.registry.name -}}{{- .Values.utility.imageName -}}:{{- .Values.utility.imageTag -}}"
  imagePullPolicy: {{ .Values.utility.imagePullPolicy | quote }}
  command: ["/usr/local/bin/ansible-playbook", "/invoker-scripts/playbook.yml"]
  volumeMounts:
  - name: dockersock
    mountPath: "/var/run/docker.sock"
  - name: scripts-dir
    mountPath: "/invoker-scripts/playbook.yml"
    subPath: "playbook.yml"
  env:
    # action runtimes
    - name: "RUNTIMES_MANIFEST"
      value: {{ template "openwhisk.runtimes_manifest" . }}
{{- if ne .Values.docker.registry.name "" }}
    - name: "RUNTIMES_REGISTRY"
      value: "{{- .Values.docker.registry.name -}}"
    - name: "RUNTIMES_REGISTRY_USERNAME"
      valueFrom:
        secretKeyRef:
          name: {{ .Release.Name }}-docker.registry.auth
          key: docker_registry_username
    - name: "RUNTIMES_REGISTRY_PASSWORD"
      valueFrom:
        secretKeyRef:
          name: {{ .Release.Name }}-docker.registry.auth
          key: docker_registry_password
{{- end -}}
{{- end -}}

