# Структура проекта Nginx + CrowdSec

## Обзор файлов

```
nginx-crowdsec-security/
├── docker-compose.yml              # Основная конфигурация Docker Compose
├── README.md                       # Основная документация
├── DEPLOYMENT.md                   # Руководство по развертыванию
├── PROJECT_STRUCTURE.md           # Этот файл - описание структуры
├── Makefile                       # Команды для управления проектом
├── test-security.sh               # Скрипт тестирования безопасности
│
├── nginx/                         # Конфигурация Nginx
│   ├── nginx.conf                 # Основная конфигурация nginx
│   └── default.conf               # Конфигурация виртуального хоста
│
├── crowdsec/                      # Конфигурация CrowdSec
│   ├── acquis.yaml                # Источники данных для анализа
│   ├── config.yaml                # Основная конфигурация CrowdSec
│   ├── profiles.yaml              # Профили обработки алертов
│   ├── simulation.yaml            # Режим симуляции (только алерты)
│   └── notifications/             # Настройки уведомлений
│       ├── slack.yaml             # Уведомления в Slack
│       └── email.yaml             # Email уведомления
│
├── html/                          # Веб-контент
│   └── index.html                 # Главная страница сайта
│
└── logs/                          # Директория для логов
    └── nginx/                     # Логи nginx (создается автоматически)
```

## Описание ключевых файлов

### docker-compose.yml
Основной файл конфигурации, определяющий:
- **nginx**: Веб-сервер на портах 54104 и 57885
- **crowdsec**: Система анализа безопасности
- **metabase**: Веб-интерфейс для мониторинга (порт 3000)

### nginx/nginx.conf
Основная конфигурация Nginx с:
- Расширенным форматом логирования для CrowdSec
- Настройками безопасности (таймауты, лимиты буферов)
- Оптимизацией производительности

### nginx/default.conf
Конфигурация виртуального хоста с:
- Настройками CORS и iframe
- Защитой от доступа к скрытым файлам
- Кешированием статических ресурсов
- Страницей статуса nginx

### crowdsec/acquis.yaml
Определяет источники данных:
- Логи доступа nginx (`/var/log/nginx/access.log`)
- Логи ошибок nginx (`/var/log/nginx/error.log`)

### crowdsec/config.yaml
Основная конфигурация CrowdSec:
- Настройки базы данных SQLite
- Конфигурация API сервера
- Настройки Prometheus метрик
- Пути к файлам конфигурации

### crowdsec/profiles.yaml
Профили обработки алертов:
- Настройки для IP-адресов
- Настройки для диапазонов IP
- Привязка к системам уведомлений

### crowdsec/simulation.yaml
Режим симуляции - все сценарии только алертят, не блокируют:
- `crowdsecurity/nginx-bf` - брутфорс атаки
- `crowdsecurity/nginx-req-limit-exceeded` - превышение лимитов
- `crowdsecurity/http-crawl-non_statics` - сканирование
- `crowdsecurity/http-bad-user-agent` - подозрительные боты
- `crowdsecurity/http-sensitive-files` - доступ к чувствительным файлам

### crowdsec/notifications/slack.yaml
Конфигурация Slack уведомлений:
- URL webhook для Slack
- Шаблон сообщения с деталями атаки
- Настройки таймаута

### crowdsec/notifications/email.yaml
Конфигурация email уведомлений:
- SMTP настройки
- Список получателей
- HTML шаблон письма с деталями инцидента

### test-security.sh
Скрипт для тестирования системы безопасности:
- Симуляция DDoS атак
- Тестирование подозрительных User-Agent
- Сканирование директорий
- Генерация 404 ошибок
- Тестирование SQL инъекций

### Makefile
Команды для управления проектом:
- `make start` - запуск сервисов
- `make stop` - остановка сервисов
- `make test` - тестирование безопасности
- `make logs` - просмотр логов
- `make status` - статус сервисов

## Автоматически создаваемые файлы

При запуске docker-compose создаются:

```
logs/nginx/
├── access.log                     # Логи доступа nginx
└── error.log                      # Логи ошибок nginx

Docker volumes:
├── crowdsec-db/                   # База данных CrowdSec
└── crowdsec-config/               # Конфигурация CrowdSec
```

## Порты и сервисы

| Сервис | Порт | Описание |
|--------|------|----------|
| Nginx | 54104 | Основной веб-сервер (HTTP) |
| Nginx | 57885 | Дополнительный порт (HTTPS ready) |
| Metabase | 3000 | Веб-интерфейс мониторинга |
| CrowdSec API | 8080 | Внутренний API (не экспонируется) |
| Prometheus | 6060 | Метрики (не экспонируется) |

## Безопасность

### Nginx защита
- Скрытие версии сервера
- Ограничение размера запросов (1KB)
- Таймауты для предотвращения медленных атак
- Защита от доступа к конфигурационным файлам

### CrowdSec мониторинг
- Анализ логов в реальном времени
- Обнаружение аномалий с помощью ML
- Интеграция с глобальной базой угроз
- Детальное логирование всех событий

## Кастомизация

### Добавление новых сценариев
1. Создайте файл в `crowdsec/scenarios/`
2. Добавьте сценарий в `crowdsec/profiles.yaml`
3. Перезапустите CrowdSec

### Настройка дополнительных уведомлений
1. Создайте файл в `crowdsec/notifications/`
2. Добавьте уведомление в `crowdsec/profiles.yaml`
3. Перезапустите CrowdSec

### Изменение портов
1. Отредактируйте `docker-compose.yml`
2. Обновите `nginx/default.conf` при необходимости
3. Перезапустите сервисы

## Мониторинг

### Логи для анализа
- `/logs/nginx/access.log` - все HTTP запросы
- `/logs/nginx/error.log` - ошибки nginx
- `docker-compose logs crowdsec` - события CrowdSec

### Метрики
- CrowdSec метрики: `cscli metrics`
- Nginx статус: `http://localhost:54104/nginx_status`
- Prometheus метрики: `http://localhost:6060/metrics`

### Алерты
- CrowdSec алерты: `cscli alerts list`
- Решения: `cscli decisions list`
- Уведомления в Slack/Email при обнаружении атак