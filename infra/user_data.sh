#!/bin/bash

cat <<EOF > /etc/webapp.env
DB_HOST=${db_host}
DB_USER=${db_username}
DB_PASS=${db_password}
DB_NAME=${db_name}
EOF

systemctl daemon-reexec
systemctl enable webapp
systemctl start webapp