# Руководство по развертыванию Nginx + CrowdSec

## Системные требования

- Docker Engine 20.10+
- Docker Compose 2.0+
- Linux система с поддержкой iptables
- Минимум 2GB RAM
- 10GB свободного места на диске

## Быстрое развертывание

### 1. Клонирование и подготовка

```bash
# Скачайте все файлы конфигурации
# Убедитесь, что у вас есть все файлы из этого проекта

# Создайте необходимые директории
mkdir -p logs/nginx

# Установите права на выполнение
chmod +x test-security.sh
```

### 2. Настройка уведомлений (опционально)

#### Slack уведомления
Отредактируйте `crowdsec/notifications/slack.yaml`:
```yaml
url: "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"
```

#### Email уведомления
Отредактируйте `crowdsec/notifications/email.yaml`:
```yaml
smtp_host: smtp.gmail.com
smtp_port: 587
smtp_username: "your-email@gmail.com"
smtp_password: "your-app-password"
recipients:
  - "admin@yourdomain.com"
```

### 3. Запуск сервисов

```bash
# Запуск всех сервисов
docker-compose up -d

# Проверка статуса
docker-compose ps

# Просмотр логов
docker-compose logs -f
```

### 4. Проверка работоспособности

```bash
# Проверка доступности nginx
curl http://localhost:54104

# Проверка CrowdSec
docker-compose exec crowdsec cscli metrics

# Просмотр алертов
docker-compose exec crowdsec cscli alerts list
```

## Архитектура решения

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     Client      │───▶│     Nginx       │───▶│   Backend       │
│                 │    │   (Port 54104)  │    │   (Optional)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │   Access Logs   │
                       │ /var/log/nginx/ │
                       └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐    ┌─────────────────┐
                       │    CrowdSec     │───▶│ Notifications   │
                       │   (Analysis)    │    │ (Slack/Email)   │
                       └─────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │    Metabase     │
                       │  (Port 3000)    │
                       └─────────────────┘
```

## Мониторинг и алертинг

### Типы обнаруживаемых атак

1. **DDoS атаки**
   - Аномальное количество запросов с одного IP
   - HTTP флуд атаки
   - Превышение лимитов запросов

2. **Боты и сканеры**
   - Подозрительные User-Agent (sqlmap, nikto, etc.)
   - Автоматизированное сканирование
   - Попытки доступа к скрытым файлам

3. **Брутфорс атаки**
   - Множественные неудачные попытки доступа
   - Сканирование директорий
   - Попытки доступа к админ панелям

4. **Сканирование уязвимостей**
   - Попытки доступа к конфигурационным файлам
   - Поиск бэкапов и временных файлов
   - Тестирование известных уязвимостей

### Настройка алертов

CrowdSec настроен в режиме **только алертинг** - подозрительный трафик не блокируется, но все инциденты:
- Логируются в базу данных
- Отправляются уведомления в Slack/Email
- Отображаются в веб-интерфейсе Metabase

## Команды управления

### Основные команды
```bash
# Запуск
make start

# Остановка
make stop

# Перезапуск
make restart

# Просмотр логов
make logs

# Статус сервисов
make status

# Тестирование безопасности
make test
```

### CrowdSec команды
```bash
# Просмотр алертов
docker-compose exec crowdsec cscli alerts list

# Метрики
docker-compose exec crowdsec cscli metrics

# Решения (бан-лист)
docker-compose exec crowdsec cscli decisions list

# Обновление hub
docker-compose exec crowdsec cscli hub update
```

## Тестирование системы

Запустите тестовый скрипт для проверки обнаружения атак:

```bash
./test-security.sh
```

Скрипт выполнит:
- Симуляцию DDoS атаки (100 быстрых запросов)
- Тестирование подозрительных User-Agent
- Сканирование директорий и файлов
- Генерацию множественных 404 ошибок
- Тестирование подозрительных параметров

## Веб-интерфейсы

- **Основной сайт**: http://localhost:54104
- **Metabase (мониторинг)**: http://localhost:3000
- **Nginx статус**: http://localhost:54104/nginx_status (только локально)

## Безопасность

### Настройки Nginx
- Скрытие версии сервера
- Ограничение размера запросов
- Защита от переполнения буферов
- Таймауты для предотвращения медленных атак

### Настройки CrowdSec
- Анализ в реальном времени
- Машинное обучение для обнаружения аномалий
- Интеграция с глобальной базой угроз
- Детальное логирование всех событий

## Производственное развертывание

### Рекомендации для продакшена

1. **SSL/TLS**
   ```bash
   # Добавьте SSL сертификаты в nginx/ssl/
   # Обновите nginx/default.conf для HTTPS
   ```

2. **Мониторинг ресурсов**
   ```bash
   # Настройте мониторинг CPU/RAM/Disk
   # Установите алерты на высокое потребление ресурсов
   ```

3. **Бэкапы**
   ```bash
   # Регулярные бэкапы базы данных CrowdSec
   # Бэкапы конфигурационных файлов
   ```

4. **Логирование**
   ```bash
   # Настройте ротацию логов
   # Интеграцию с внешними системами логирования
   ```

## Устранение неполадок

### Частые проблемы

1. **CrowdSec не запускается**
   ```bash
   # Проверьте логи
   docker-compose logs crowdsec
   
   # Проверьте конфигурацию
   docker-compose exec crowdsec cscli config show
   ```

2. **Уведомления не приходят**
   ```bash
   # Проверьте конфигурацию уведомлений
   docker-compose exec crowdsec cscli notifications list
   
   # Тест уведомлений
   docker-compose exec crowdsec cscli notifications test slack_alerts
   ```

3. **Высокое потребление ресурсов**
   ```bash
   # Проверьте метрики
   docker-compose exec crowdsec cscli metrics
   
   # Настройте лимиты в docker-compose.yml
   ```

## Поддержка

- **Документация CrowdSec**: https://docs.crowdsec.net/
- **Документация Nginx**: https://nginx.org/en/docs/
- **GitHub Issues**: Создайте issue с описанием проблемы

## Лицензия

Этот проект использует открытые компоненты:
- Nginx: BSD-like license
- CrowdSec: MIT License