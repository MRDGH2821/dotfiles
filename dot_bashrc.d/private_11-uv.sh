#!/usr/bin/env bash

# UV
eval "$(uv --generate-shell-completion bash)" || true
eval "$(uvx --generate-shell-completion bash)" || true
