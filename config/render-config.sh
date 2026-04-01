#!/bin/bash

cd "$(dirname "$0")"

echo "[render-config.sh] This script will manually render .env (from config/env/.env) values to:"
echo "      config/appsettings.json"
echo "      ingress/traefik-config.yaml"
echo "      ingress/ingress.yaml"
echo ""

echo "[render-config.sh] Checking if the .env is present..."
if [ ! -f ./env/.env ]; then
    echo "[render-config.sh] Error: ./env/.env not found!"
    echo "[render-config.sh] Please copy ./env/.env.example to ./env/.env and configure it"
    exit 1
fi

set -a
source ./env/.env
set +a

envsubst < ./appsettings.template.json > ./appsettings.json
echo "[render-config.sh] Rendered config/appsettings.json"

envsubst < ./../ingress/traefik-config.template.yaml > ./../ingress/traefik-config.yaml
echo "[render-config.sh] Rendered ingress/traefik-config.yaml"

envsubst < ./../ingress/ingress.template.yaml > ./../ingress/ingress.yaml
echo "[render-config.sh] Rendered ingress/ingress.yaml"

echo "[render-config.sh] Done."
