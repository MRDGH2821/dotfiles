# opencodex managed Codex PATH
ocx_shim_dir="${HOME}/.opencodex/bin"
ocx_shim_rest="${PATH-}"
ocx_shim_path="${ocx_shim_dir}"
ocx_shim_more=1
while [[ "${ocx_shim_more}" = 1 ]]; do
  case "${ocx_shim_rest}" in
    *:*) ocx_shim_part="${ocx_shim_rest%%:*}"; ocx_shim_rest="${ocx_shim_rest#*:}" ;;
    *) ocx_shim_part="${ocx_shim_rest}"; ocx_shim_more=0 ;;
  esac
  if [[ "${ocx_shim_part}" != "${ocx_shim_dir}" ]]; then ocx_shim_path="${ocx_shim_path}:${ocx_shim_part}"; fi
done
export PATH="${ocx_shim_path}"
unset ocx_shim_dir ocx_shim_rest ocx_shim_path ocx_shim_more ocx_shim_part
