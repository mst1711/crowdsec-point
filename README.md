# Nginx + CrowdSec Security Monitoring

Этот docker-compose настраивает nginx веб-сервер с CrowdSec для мониторинга и алертинга о подозрительной активности.

## Компоненты

- **Nginx** - веб-сервер с расширенным логированием
- **CrowdSec** - система обнаружения вторжений и анализа логов
- **Metabase** - веб-интерфейс для мониторинга (опционально)

## Быстрый старт

1. **Настройте уведомления** (опционально):
   ```bash
   # Для Slack - отредактируйте crowdsec/notifications/slack.yaml
   # Укажите ваш webhook URL
   
   # Для Email - отредактируйте crowdsec/notifications/email.yaml
   # Укажите SMTP настройки и получателей
   ```

2. **Запустите сервисы**:
   ```bash
   docker-compose up -d
   ```

3. **Проверьте статус**:
   ```bash
   docker-compose ps
   docker-compose logs crowdsec
   ```

## Доступ к сервисам

- **Веб-сайт**: http://localhost:54104 или http://localhost:57885
- **Metabase**: http://localhost:3000 (для мониторинга)
- **Nginx статус**: http://localhost:54104/nginx_status

## Что мониторится

CrowdSec анализирует логи nginx и обнаруживает:

### 🤖 Боты и сканеры
- Подозрительные User-Agent
- Автоматизированное сканирование
- Попытки доступа к скрытым файлам

### 🌊 DDoS атаки
- Аномальное количество запросов с одного IP
- HTTP флуд атаки
- Превышение лимитов запросов

### 🔓 Брутфорс атаки
- Множественные неудачные попытки доступа
- Сканирование директорий
- Попытки доступа к административным панелям

### 🕵️ Сканирование уязвимостей
- Попытки доступа к конфигурационным файлам
- Поиск бэкапов и временных файлов
- Тестирование известных уязвимостей

## Настройка уведомлений

### Slack
1. Создайте Incoming Webhook в вашем Slack workspace
2. Отредактируйте `crowdsec/notifications/slack.yaml`
3. Укажите URL webhook в поле `url`

### Email
1. Отредактируйте `crowdsec/notifications/email.yaml`
2. Укажите SMTP настройки вашего почтового сервера
3. Добавьте email адреса получателей в `recipients`

## Тестирование системы

### Симуляция DDoS атаки
```bash
# Множественные быстрые запросы
for i in {1..100}; do curl -s http://localhost:54104/ > /dev/null; done
```

### Симуляция бота
```bash
# Запрос с подозрительным User-Agent
curl -H "User-Agent: sqlmap/1.0" http://localhost:54104/
```

### Сканирование директорий
```bash
# Попытки доступа к несуществующим файлам
curl http://localhost:54104/admin/
curl http://localhost:54104/.env
curl http://localhost:54104/config.php
```

## Мониторинг и логи

### Просмотр логов
```bash
# Логи nginx
docker compose logs nginx

# Логи CrowdSec
docker compose logs crowdsec

# Алерты CrowdSec
docker compose exec crowdsec cscli alerts list
```

### Статистика
```bash
# Статистика обнаружений
docker compose exec crowdsec cscli metrics

# Активные решения (бан-лист)
docker compose exec crowdsec cscli decisions list
```

## Структура файлов

```
.
├── docker-compose.yml          # Основная конфигурация
├── nginx/
│   ├── nginx.conf             # Конфигурация nginx
│   └── default.conf           # Виртуальный хост
├── crowdsec/
│   ├── acquis.yaml            # Источники данных
│   ├── config.yaml            # Основная конфигурация
│   ├── profiles.yaml          # Профили обработки алертов
│   └── notifications/         # Настройки уведомлений
│       ├── slack.yaml
│       └── email.yaml
├── html/
│   └── index.html             # Тестовая страница
└── logs/
    └── nginx/                 # Логи nginx
```

## Важные замечания

- **Режим мониторинга**: CrowdSec настроен только на алертинг, трафик не блокируется
- **Логи**: Все события сохраняются в базе данных CrowdSec для анализа
- **Производительность**: Конфигурация оптимизирована для минимального влияния на производительность
- **Безопасность**: Nginx настроен с базовыми мерами защиты

## Дополнительная настройка

### Включение блокировки (опционально)
Если нужно включить автоматическую блокировку:

1. Установите bouncer для nginx:
   ```bash
   docker compose exec crowdsec cscli bouncers add nginx-bouncer
   ```

2. Настройте nginx для использования CrowdSec API

### Кастомные сценарии
Можно добавить собственные сценарии обнаружения в `/etc/crowdsec/scenarios/`

### Интеграция с внешними системами
CrowdSec поддерживает интеграцию с различными SIEM системами и платформами мониторинга.