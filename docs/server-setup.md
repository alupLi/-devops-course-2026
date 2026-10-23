# Конфигурация виртуальной машины devops-vm

## 1. Параметры машины
- Объём оперативной памяти: 2048 МБ
- Количество ядер процессора: 2
- Объём дискового накопителя: 25 ГБ (динамически расширяемый)

## 2. Сетевые интерфейсы
- Адаптер 1 (NAT): полученный адрес 10.0.2.15/24. Назначение: доступ виртуальной машины в Интернет для загрузки пакетов.
- Адаптер 2 (Host-only): полученный адрес 192.168.56.102/24. Назначение: подключение с хостовой системы к виртуальной машине (SSH, веб-сервер в практической №6).

## 3. Правило проброса портов
- Порт хостовой системы: 2222
- Порт гостевой системы: 2222

## 4. Учётные записи
- Пользователь `student` (входит в группы: student, adm, cdrom, sudo и др.). Аутентификация по паролю (используется для sudo).
- Пользователь `devops` (входит в группы: devops, sudo, users). Аутентификация по ключу SSH (ed25519).

## 5. Служба SSH
- Порт: 2222
- Расположение файла конфигурации: /etc/ssh/sshd_config и /etc/ssh/sshd_config.d/99-hardening.conf
- Изменённые директивы и их значения:
  - Port 2222
  - PermitRootLogin no
  - PasswordAuthentication no
  - PubkeyAuthentication yes
  - PermitEmptyPasswords no
  - MaxAuthTries 3
  - LoginGraceTime 30
  - AllowUsers devops
  - X11Forwarding no
  - ClientAliveInterval 300
  - ClientAliveCountMax 2
  (Примечание: файл /etc/ssh/sshd_config.d/50-cloud-init.conf содержит закомментированную директиву PasswordAuthentication).

## 6. Правила межсетевого экрана (UFW)
- Политики по умолчанию: deny (incoming), allow (outgoing), deny (routed).
- Перечень правил:
  - 2222/tcp LIMIT (SSH rate-limited)
  - 80/tcp ALLOW (HTTP)
  - 443/tcp ALLOW (HTTPS)

## 7. Снимки состояния
- `01-clean-install` — создан 15.10.2026 15:35 (сразу после установки).
- `02-keys-configured` — создан 15.10.2026 16:51 (после настройки ключевой аутентификации).
- `03-ssh-hardened` — создан 19.10.2026 (после усиления защиты SSH).

## 8. Веб-сервер
- Устанавливаемый пакет: nginx
- Конфигурация ресурса: /etc/nginx/sites-available/devops-site
- Каталог ресурса: /var/www/devops-site (владелец devops:devops, права 755)
- Сертификат: /etc/ssl/certs/devops.crt (права 644)
- Ключ: /etc/ssl/private/devops.key (владелец root, права 600)
- Команда формирования сертификата: `openssl req -x509 -nodes -days 365 ...`
- Срок действия: 365 дней

## 9. Контейнеризация
- Docker Engine установлен из официального репозитория.
- Участники группы docker: devops.
- Расположение проекта на сервере: /home/devops/app.
- Расположение файла .env: /home/devops/app/.env (права 600).
- Публикуемые порты и адреса: 127.0.0.1:5000 (приложение). Порт 5432 не публикуется.
- Именованные тома: app_db_data.
- Конфигурация обратного прокси: location /app/ { proxy_pass http://127.0.0.1:5000/; }
