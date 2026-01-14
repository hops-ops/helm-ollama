# helm-ollama

A Crossplane Configuration package that installs the Ollama Helm chart with a minimal, stable interface.

## Overview

`helm-ollama` renders a single Helm release for Ollama. It exposes only the inputs needed
for chart values, namespace, and release name, keeping the interface stable while allowing full Helm overrides.

Ollama is an open-source tool for running large language models (LLMs) locally.

## Features

- **Minimal Helm interface**: values and overrideAllValues with stable defaults
- **Predictable naming**: defaults to `<clusterName>-ollama` in the `ollama` namespace
- **GitOps friendly**: ships a `.gitops/` deploy chart

## Prerequisites

- Crossplane installed in the cluster
- Crossplane providers:
  - `provider-helm` (>=v1.0.6)
- Crossplane function:
  - `function-auto-ready` (>=v0.6.0)

## Quick Start

```yaml
apiVersion: pkg.crossplane.io/v1
kind: Configuration
metadata:
  name: helm-ollama
spec:
  package: ghcr.io/hops-ops/helm-ollama:latest
```

```yaml
apiVersion: helm.hops.ops.com.ai/v1alpha1
kind: Ollama
metadata:
  name: ollama
  namespace: example-env
spec:
  clusterName: example-cluster
  values:
    ollama:
      models:
        pull:
        - llama3.2
```

## GPU Support

Ollama supports GPU acceleration for faster inference:

```yaml
apiVersion: helm.hops.ops.com.ai/v1alpha1
kind: Ollama
metadata:
  name: ollama
  namespace: example-env
spec:
  clusterName: example-cluster
  values:
    ollama:
      gpu:
        enabled: true
        type: nvidia
        number: 1
      models:
        pull:
        - llama3.2
```

## Development

```bash
make render
make validate
make test
```
