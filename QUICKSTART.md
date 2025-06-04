# 🚀 Быстрый старт Nginx + CrowdSec

## За 5 минут до запуска

### 1. Предварительные требования
```bash
# Убедитесь, что Docker установлен
docker --version
docker-compose --version

# Или установите Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

### 2. Запуск системы
```bash
# Клонируйте/скачайте все файлы проекта
# Перейдите в директорию проекта

# Запустите все сервисы
docker compose up -d

# Проверьте статус
docker compose ps
```

### 3. Проверка работы
```bash
# Откройте в браузере
http://localhost:54104

# Или проверьте через curl
curl http://localhost:54104
```

### 4. Тестирование безопасности
```bash
# Запустите тесты
./test-security.sh

# Проверьте алерты
docker compose exec crowdsec cscli alerts list
```

## 🎯 Что получите

- ✅ **Nginx** веб-сервер на портах 54104 и 57885
- ✅ **CrowdSec** анализ безопасности в реальном времени  
- ✅ **Dashboard** веб-интерфейс мониторинга на порту 3000
- ✅ **Автоматические алерты** при обнаружении атак
- ✅ **Готовые тесты** для проверки системы

## 🔧 Настройка уведомлений (опционально)

### Slack
```bash
# Отредактируйте crowdsec/notifications/slack.yaml
# Укажите ваш webhook URL
url: "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"
```

### Email
```bash
# Отредактируйте crowdsec/notifications/email.yaml
# Укажите SMTP настройки
smtp_host: smtp.gmail.com
smtp_username: "your-email@gmail.com"
recipients:
  - "admin@yourdomain.com"
```

## 🛡️ Что мониторится

- **DDoS атаки** - множественные запросы с одного IP
- **Боты и сканеры** - подозрительные User-Agent
- **Брутфорс** - попытки подбора паролей
- **Сканирование уязвимостей** - поиск конфиг файлов
- **HTTP флуд** - превышение лимитов запросов

## 📊 Полезные команды

```bash
# Статус сервисов
make status

# Просмотр логов
make logs

# Алерты CrowdSec
docker compose exec crowdsec cscli alerts list

# Метрики
docker compose exec crowdsec cscli metrics

# Остановка
docker compose down
```

## 🆘 Если что-то не работает

1. **Проверьте логи**:
   ```bash
   docker compose logs
   ```

2. **Перезапустите сервисы**:
   ```bash
   docker compose restart
   ```

3. **Проверьте порты**:
   ```bash
   netstat -tlnp | grep -E "(54104|3000)"
   ```

4. **Очистите и пересоздайте**:
   ```bash
   docker compose down -v
   docker compose up -d
   ```

## 📚 Дополнительная документация

- `README.md` - подробная документация
- `DEPLOYMENT.md` - руководство по развертыванию
- `PROJECT_STRUCTURE.md` - структура проекта

---

**🎉 Готово!** Ваша система безопасности запущена и мониторит трафик.