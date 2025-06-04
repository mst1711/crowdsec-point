# Makefile для управления Nginx + CrowdSec системой

.PHONY: help start stop restart logs status test clean build

# Цвета для вывода
GREEN=\033[0;32m
YELLOW=\033[1;33m
RED=\033[0;31m
NC=\033[0m # No Color

help: ## Показать справку
	@echo "$(GREEN)Nginx + CrowdSec Security System$(NC)"
	@echo "$(YELLOW)Доступные команды:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

start: ## Запустить все сервисы
	@echo "$(GREEN)Запуск Nginx + CrowdSec...$(NC)"
	docker compose up -d
	@echo "$(GREEN)Сервисы запущены!$(NC)"
	@echo "$(YELLOW)Nginx доступен на: http://localhost:54104$(NC)"
	@echo "$(YELLOW)Dashboard доступен на: http://localhost:3000$(NC)"

stop: ## Остановить все сервисы
	@echo "$(RED)Остановка сервисов...$(NC)"
	docker compose down

restart: ## Перезапустить все сервисы
	@echo "$(YELLOW)Перезапуск сервисов...$(NC)"
	docker compose restart

logs: ## Показать логи всех сервисов
	docker compose logs -f

logs-nginx: ## Показать логи только nginx
	docker compose logs -f nginx

logs-crowdsec: ## Показать логи только CrowdSec
	docker compose logs -f crowdsec

status: ## Показать статус сервисов
	@echo "$(GREEN)Статус сервисов:$(NC)"
	docker compose ps

test: ## Запустить тесты безопасности
	@echo "$(YELLOW)Запуск тестов безопасности...$(NC)"
	@if [ -f ./test-security.sh ]; then \
		chmod +x ./test-security.sh && ./test-security.sh; \
	else \
		echo "$(RED)Файл test-security.sh не найден!$(NC)"; \
	fi

alerts: ## Показать алерты CrowdSec
	@echo "$(GREEN)Алерты CrowdSec:$(NC)"
	docker compose exec crowdsec cscli alerts list

metrics: ## Показать метрики CrowdSec
	@echo "$(GREEN)Метрики CrowdSec:$(NC)"
	docker compose exec crowdsec cscli metrics

decisions: ## Показать решения CrowdSec
	@echo "$(GREEN)Решения CrowdSec:$(NC)"
	docker compose exec crowdsec cscli decisions list

hub-update: ## Обновить CrowdSec Hub
	@echo "$(YELLOW)Обновление CrowdSec Hub...$(NC)"
	docker compose exec crowdsec cscli hub update

collections: ## Показать установленные коллекции
	@echo "$(GREEN)Установленные коллекции:$(NC)"
	docker compose exec crowdsec cscli collections list

scenarios: ## Показать активные сценарии
	@echo "$(GREEN)Активные сценарии:$(NC)"
	docker compose exec crowdsec cscli scenarios list

parsers: ## Показать активные парсеры
	@echo "$(GREEN)Активные парсеры:$(NC)"
	docker compose exec crowdsec cscli parsers list

clean: ## Очистить все данные (ОСТОРОЖНО!)
	@echo "$(RED)ВНИМАНИЕ: Это удалит все данные!$(NC)"
	@read -p "Вы уверены? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker compose down -v; \
		docker system prune -f; \
		echo "$(GREEN)Очистка завершена$(NC)"; \
	else \
		echo "$(YELLOW)Отменено$(NC)"; \
	fi

build: ## Пересобрать и запустить сервисы
	@echo "$(YELLOW)Пересборка сервисов...$(NC)"
	docker compose down
	docker compose build --no-cache
	docker compose up -d

health: ## Проверить здоровье сервисов
	@echo "$(GREEN)Проверка здоровья сервисов:$(NC)"
	@echo "$(YELLOW)Nginx:$(NC)"
	@curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://localhost:54104 || echo "$(RED)Nginx недоступен$(NC)"
	@echo "$(YELLOW)CrowdSec API:$(NC)"
	@docker compose exec crowdsec cscli version || echo "$(RED)CrowdSec недоступен$(NC)"

install-deps: ## Установить зависимости (curl, docker)
	@echo "$(YELLOW)Проверка зависимостей...$(NC)"
	@which curl > /dev/null || (echo "$(RED)curl не установлен$(NC)" && exit 1)
	@which docker > /dev/null || (echo "$(RED)docker не установлен$(NC)" && exit 1)
	@docker compose version > /dev/null 2>&1 || (echo "$(RED)docker compose не доступен$(NC)" && exit 1)
	@echo "$(GREEN)Все зависимости установлены$(NC)"

backup: ## Создать бэкап конфигурации
	@echo "$(YELLOW)Создание бэкапа...$(NC)"
	@mkdir -p backups
	@tar -czf backups/crowdsec-backup-$(shell date +%Y%m%d-%H%M%S).tar.gz \
		docker-compose.yml nginx/ crowdsec/ html/ Makefile README.md
	@echo "$(GREEN)Бэкап создан в директории backups/$(NC)"

update: ## Обновить образы Docker
	@echo "$(YELLOW)Обновление образов...$(NC)"
	docker compose pull
	docker compose up -d
	@echo "$(GREEN)Образы обновлены$(NC)"

# Алиасы для удобства
up: start
down: stop
ps: status
exec-crowdsec: ## Войти в контейнер CrowdSec
	docker compose exec crowdsec /bin/bash

exec-nginx: ## Войти в контейнер Nginx
	docker compose exec nginx /bin/sh