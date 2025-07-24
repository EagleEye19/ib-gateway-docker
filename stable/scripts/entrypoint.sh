#!/bin/bash
set -e

# Expand environment variables into the IBC config
envsubst < "$IBC_INI_TMPL" > "$IBC_INI"

# Optional: Show a masked preview (excluding password)
echo "[INFO] Rendered config.ini:"
grep -v "Password" "$IBC_INI" || true

# Hand off to original CMD (e.g., run.sh)
exec "$@"
