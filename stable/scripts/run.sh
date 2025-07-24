#!/bin/bash
set -Eeo pipefail

echo "*************************************************************************"
echo ".> Starting IB Gateway with IBC and VNC"
echo "*************************************************************************"

# === ENV ===
export DISPLAY=:1
export XAUTHORITY="$HOME/.Xauthority"
pid=()
TRADING_MODE="${TRADING_MODE:-live}"

# === Shutdown Trap ===
stop_ibc() {
    echo ".> 🛑 Received shutdown signal. Cleaning up..."
    pkill x11vnc || true
    pkill Xvfb || true
    pkill twm || true
    kill -SIGTERM "${pid[@]}" || true
    wait "${pid[@]}" || true
    echo ".> Shutdown complete."
}
trap stop_ibc SIGINT SIGTERM

# === Step 1: Inject Credentials into config.ini ===
echo ".> Injecting credentials into config.ini"
if [[ -f "${IBC_PATH}/config.ini.tmpl" ]]; then
    envsubst < "${IBC_PATH}/config.ini.tmpl" > "${IBC_PATH}/config.ini"
    echo ".> ✔️ config.ini generated"
else
    echo ".> ❌ ERROR: config.ini.tmpl not found at ${IBC_PATH}/config.ini.tmpl"
    exit 1
fi

# === Step 2: Start Virtual Display ===
echo ".> Starting Xvfb virtual display on $DISPLAY"
rm -f /tmp/.X1-lock
Xvfb $DISPLAY -screen 0 1024x768x16 &
sleep 2

# === Step 3: Start Basic Window Manager ===
echo ".> Starting twm window manager"
twm &

# === Step 4: Start VNC Server ===
echo ".> Starting x11vnc VNC server"
if [ -n "$VNC_SERVER_PASSWORD" ]; then
    x11vnc -display $DISPLAY -passwd "$VNC_SERVER_PASSWORD" -forever -bg -shared -rfbport 5900 -noxdamage
else
    echo ".> ⚠️  VNC password not set. Skipping VNC startup."
fi

# === Step 5: Start IBC/IB Gateway ===
sleep 3
echo ".> Starting IBC (mode: ${TRADING_MODE})"
"${IBC_PATH}/scripts/ibcstart.sh" "${TWS_MAJOR_VRSN}" -g \
    "--tws-path=${TWS_PATH}" \
    "--ibc-path=${IBC_PATH}" \
    "--ibc-ini=${IBC_PATH}/config.ini" \
    "--on2fatimeout=${TWOFA_TIMEOUT_ACTION}" \
    "--tws-settings-path=${TWS_SETTINGS_PATH:-}" &

pid+=("$!")
echo "${pid[0]}" >"/tmp/pid_${TRADING_MODE}"

# === Wait for Exit ===
wait "${pid[@]}"
exit $?
