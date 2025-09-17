#!/bin/bash

# Write environment variables for the webapp
cat <<EOF > /etc/webapp.env
DB_HOST=${DB_HOST}
DB_USER=${DB_USER}
DB_PASS=${DB_PASS}
DB_NAME=${DB_NAME}
EOF


# Reload systemd and restart the service
systemctl daemon-reexec
systemctl restart webapp

