# Gitea
wget -O gitea.tgz https://github.com/go-gitea/gitea/archive/refs/tags/v1.22.6.tar.gz
tar -C /usr/local -xzf gitea.tgz
rm gitea.tgz
cd /usr/local/gitea-*

apk add --no-cache --virtual .build-deps nodejs npm make git go

make frontend
TAGS="bindata" make build
cp ./gitea /usr/local/bin
cd ~
rm -rf /usr/local/gitea-*

apk del .build-deps
apk add --no-cache git

# Run
adduser gitea --disabled-password

export GITEA_PORT="${GITEA_PORT:-3000}"
export MYSQL_DB_HOST="${MYSQL_DB_HOST:-localhost:3306}"
export MYSQL_DB_NAME="${MYSQL_DB_NAME:-gitea}"
export MYSQL_DB_USER="${MYSQL_DB_USER:-gitea}"
export MYSQL_DB_PASSWORD="${MYSQL_DB_PASSWORD:-gitea}"

mkdir /etc/gitea
cat > /etc/gitea/app.ini <<EOF

[server]
HTTP_ADDR = 0.0.0.0
HTTP_PORT = $GITEA_PORT
DISABLE_SSH = true

[database]
DB_TYPE = mysql
HOST = $MYSQL_DB_HOST
NAME = $MYSQL_DB_NAME
USER = $MYSQL_DB_USER
PASSWD = $MYSQL_DB_PASSWORD

[security]
INSTALL_LOCK = true
SECRET_KEY = 12345
INTERNAL_TOKEN = 54321

[oauth2]
ENABLED = false

[log]
MODE = console
LEVEL = Info

EOF

chown gitea:gitea -R /etc/gitea

su gitea -c "/usr/local/bin/gitea web --config=/etc/gitea/app.ini --custom-path=/data -w=/tmp"
