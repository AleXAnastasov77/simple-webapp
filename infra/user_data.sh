#!/bin/bash

# Write environment variables for the webapp
cat <<EOF > /etc/webapp.env
DB_HOST=${DB_HOST}
DB_USER=${DB_USERNAME}
DB_PASS=${DB_PASSWORD}
DB_NAME=${DB_NAME}
EOF


# Reload systemd and restart the service
systemctl daemon-reexec
systemctl enable webapp
systemctl start webapp

