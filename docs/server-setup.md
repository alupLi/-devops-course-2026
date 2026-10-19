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