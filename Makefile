# Makefile для управления Nginx + CrowdSec

.PHONY: help start stop restart logs status test clean setup

help: ## Показать справку
	@echo "Доступные команды:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

setup: ## Первоначальная настройка (создание директорий)
	@echo "🔧 Настройка окружения..."
	@mkdir -p logs/nginx html crowdsec/notifications
	@echo "✅ Директории созданы"

start: ## Запустить все сервисы
	@echo "🚀 Запуск сервисов..."
	@docker-compose up -d
	@echo "✅ Сервисы запущены"
	@echo "🌐 Веб-сайт: http://localhost:54104"
	@echo "📊 Metabase: http://localhost:3000"

stop: ## Остановить все сервисы
	@echo "🛑 Остановка сервисов..."
	@docker-compose down
	@echo "✅ Сервисы остановлены"

restart: stop start ## Перезапустить все сервисы

logs: ## Показать логи всех сервисов
	@docker-compose logs -f

logs-nginx: ## Показать логи nginx
	@docker-compose logs -f nginx

logs-crowdsec: ## Показать логи CrowdSec
	@docker-compose logs -f crowdsec

status: ## Показать статус сервисов
	@echo "📊 Статус сервисов:"
	@docker-compose ps
	@echo ""
	@echo "📈 Метрики CrowdSec:"
	@docker-compose exec crowdsec cscli metrics 2>/dev/null || echo "CrowdSec не запущен"

alerts: ## Показать алерты CrowdSec
	@echo "🚨 Алерты CrowdSec:"
	@docker-compose exec crowdsec cscli alerts list

decisions: ## Показать решения CrowdSec
	@echo "⚖️ Решения CrowdSec:"
	@docker-compose exec crowdsec cscli decisions list

test: ## Запустить тесты безопасности
	@echo "🧪 Запуск тестов безопасности..."
	@./test-security.sh

clean: ## Очистить все данные (ОСТОРОЖНО!)
	@echo "🧹 Очистка данных..."
	@docker-compose down -v
	@docker system prune -f
	@rm -rf logs/nginx/*
	@echo "✅ Данные очищены"

install-collections: ## Установить дополнительные коллекции CrowdSec
	@echo "📦 Установка коллекций CrowdSec..."
	@docker-compose exec crowdsec cscli collections install crowdsecurity/nginx
	@docker-compose exec crowdsec cscli collections install crowdsecurity/base-http-scenarios
	@docker-compose exec crowdsec cscli collections install crowdsecurity/http-cve
	@echo "✅ Коллекции установлены"

update-hub: ## Обновить hub CrowdSec
	@echo "🔄 Обновление hub CrowdSec..."
	@docker-compose exec crowdsec cscli hub update
	@docker-compose exec crowdsec cscli hub upgrade
	@echo "✅ Hub обновлен"

shell-crowdsec: ## Открыть shell в контейнере CrowdSec
	@docker-compose exec crowdsec sh

shell-nginx: ## Открыть shell в контейнере Nginx
	@docker-compose exec nginx sh

backup: ## Создать бэкап конфигурации
	@echo "💾 Создание бэкапа..."
	@tar -czf backup-$(shell date +%Y%m%d-%H%M%S).tar.gz \
		docker-compose.yml nginx/ crowdsec/ html/ Makefile README.md test-security.sh
	@echo "✅ Бэкап создан"

monitor: ## Мониторинг в реальном времени
	@echo "👀 Мониторинг логов nginx и алертов CrowdSec..."
	@echo "Нажмите Ctrl+C для выхода"
	@(docker-compose logs -f nginx | grep -E "(GET|POST|PUT|DELETE)" &) && \
	 (docker-compose logs -f crowdsec | grep -E "(WARN|ERROR|alert)" &) && \
	 wait