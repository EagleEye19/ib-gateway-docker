#!/bin/bash
set -e

# 🧩 Fetch parameters from AWS SSM
USERID=$(aws ssm get-parameter --name "IB_USER" --with-decryption --query "Parameter.Value" --output text)
PASSWORD=$(aws ssm get-parameter --name "IB_PASSWORD" --with-decryption --query "Parameter.Value" --output text)
TOTP_SECRET=$(aws ssm get-parameter --name "IB_TOTP_SECRET" --with-decryption --query "Parameter.Value" --output text)
VNC_PASSWORD=$(aws ssm get-parameter --name "VNC_PASSWORD" --with-decryption --query "Parameter.Value" --output text)

# 📝 Generate .env file
cat <<EOF > .env
TWS_USERID=$USERID
TWS_PASSWORD=$PASSWORD
TOTP_SECRET=$TOTP_SECRET
# ib-gateway
#TWS_SETTINGS_PATH=/home/ibgateway/Jts
# tws
#TWS_SETTINGS_PATH=/config/tws_settings
TWS_SETTINGS_PATH=/home/ibgateway/Jts
TWS_ACCEPT_INCOMING=
TRADING_MODE=live
READ_ONLY_API=no
VNC_SERVER_PASSWORD=$VNC_PASSWORD
TWOFA_TIMEOUT_ACTION=restart
TWOFA_DEVICE=
BYPASS_WARNING=
AUTO_RESTART_TIME=11:59 PM
AUTO_LOGOFF_TIME=
TWS_COLD_RESTART=
SAVE_TWS_SETTINGS=
RELOGIN_AFTER_TWOFA_TIMEOUT=yes
EXISTING_SESSION_DETECTED_ACTION=primary
ALLOW_BLIND_TRADING=no
TIME_ZONE=America/Chicago
CUSTOM_CONFIG=
SSH_TUNNEL=
SSH_OPTIONS=
SSH_ALIVE_INTERVAL=
SSH_ALIVE_COUNT=
SSH_PASSPHRASE=
SSH_REMOTE_PORT=
SSH_USER_TUNNEL=
SSH_RESTART=
SSH_VNC_PORT=
EOF

echo "✅ .env file generated from SSM"
