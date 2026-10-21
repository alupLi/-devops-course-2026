#!/usr/bin/env bash
set -euo pipefail

REMOTE="devops@127.0.0.1"
REMOTE_DIR="/var/www/devops-site"
SITE_URL="https://127.0.0.1"
CA_CERT="${HOME}/devops.crt"
LOCAL_DIR="$HOME/site/"

DRY_RUN=""
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN="--dry-run"
fi

if [[ ! -f "${LOCAL_DIR}index.html" ]]; then
    echo "Ошибка: файл ${LOCAL_DIR}index.html не найден!" >&2
    exit 1
fi

# Временно убрана проверка git, так как мы на сервере
# if [[ -n "$(git status --porcelain)" ]]; then
#     echo "Ошибка: в репозитории есть незафиксированные изменения!" >&2
#     exit 1
# fi

rsync -avz --delete --chmod=D755,F644 -e "ssh -p 2222" ${DRY_RUN} "${LOCAL_DIR}" "${REMOTE}:${REMOTE_DIR}/"

if [[ -n "${DRY_RUN}" ]]; then
    exit 0
fi

if ! curl -k -f -s "${SITE_URL}" > /dev/null; then
    echo "Ошибка: ресурс ${SITE_URL} недоступен!" >&2
    exit 1
fi

echo "Деплой успешно завершён."
