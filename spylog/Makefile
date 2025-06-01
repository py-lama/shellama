# Makefile dla projektu Spyq

.PHONY: help install install-dev test test-cov clean build upload upload-test lint format check docs

# Domyślny cel
help:
	@echo "🔧 Spyq - Python Validator Proxy"
	@echo "================================="
	@echo ""
	@echo "Dostępne komendy:"
	@echo "  install      - Instalacja paczki"
	@echo "  install-dev  - Instalacja w trybie deweloperskim"
	@echo "  test         - Uruchom testy"
	@echo "  test-cov     - Uruchom testy z pokryciem kodu"
	@echo "  lint         - Sprawdź jakość kodu (flake8, mypy)"
	@echo "  format       - Formatuj kod (black)"
	@echo "  check        - Sprawdź wszystko (lint + test)"
	@echo "  clean        - Wyczyść pliki tymczasowe"
	@echo "  build        - Zbuduj paczkę"
	@echo "  upload-test  - Wyślij na TestPyPI"
	@echo "  upload       - Wyślij na PyPI"
	@echo "  docs         - Generuj dokumentację"

# Instalacja
install:
	@echo "📦 Instalowanie Spyq..."
	pip install .

install-dev:
	@echo "🔧 Instalowanie w trybie deweloperskim..."
	pip install -e ".[dev]"

# Testy
test:
	@echo "🧪 Uruchamianie testów..."
	python -m pytest tests/ -v

test-cov:
	@echo "🧪 Uruchamianie testów z pokryciem kodu..."
	python -m pytest tests/ -v --cov=spyq --cov-report=html --cov-report=term

# Jakość kodu
lint:
	@echo "🔍 Sprawdzanie jakości kodu..."
	@echo "→ flake8..."
	python -m flake8 spyq tests
	@echo "→ mypy..."
	python -m mypy spyq

format:
	@echo "✨ Formatowanie kodu..."
	python -m black spyq tests

check: lint test
	@echo "✅ Wszystkie sprawdzenia zakończone pomyślnie!"

# Czyszczenie
clean:
	@echo "🧹 Czyszczenie plików tymczasowych..."
	rm -rf build/
	rm -rf dist/
	rm -rf *.egg-info/
	rm -rf htmlcov/
	rm -rf .pytest_cache/
	rm -rf .mypy_cache/
	rm -rf .coverage
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete

# Budowanie
build: clean
	@echo "🏗️  Budowanie paczki..."
	python -m pip install --upgrade build
	python -m build

# Upload
upload-test: build
	@echo "📤 Wysyłanie na TestPyPI..."
	python -m pip install --upgrade twine
	python -m twine upload --repository testpypi dist/*

upload: build
	@echo "📤 Wysyłanie na PyPI..."
	python -m pip install --upgrade twine
	python -m twine upload dist/*

# Dokumentacja
docs:
	@echo "📚 Generowanie dokumentacji..."
	@echo "README.md jest główną dokumentacją"
	@echo "Dodatkowa dokumentacja może być dodana w przyszłości"

# Sprawdzenie środowiska
env-check:
	@echo "🔍 Sprawdzanie środowiska..."
	@echo "Python: $(shell python --version)"
	@echo "Pip: $(shell pip --version)"
	@echo "Lokalizacja Python: $(shell which python)"
	@echo "Lokalizacja Pip: $(shell which pip)"

# Instalacja z aliasem
install-with-alias: install
	@echo "🔗 Konfigurowanie aliasu..."
	@bash install.sh

# Quick start dla deweloperów
dev-setup: install-dev
	@echo "🚀 Konfiguracja środowiska deweloperskiego zakończona!"
	@echo ""
	@echo "Następne kroki:"
	@echo "1. make test      # Uruchom testy"
	@echo "2. make format    # Sformatuj kod"
	@echo "3. make check     # Sprawdź wszystko"

# Pre-commit hook
pre-commit: format lint test
	@echo "✅ Pre-commit sprawdzenia zakończone pomyślnie!"

# Informacje o projekcie
info:
	@echo "📊 Informacje o projekcie Spyq"
	@echo "=============================="
	@echo "Wersja: $(shell python -c "import spyq; print(spyq.__version__)" 2>/dev/null || echo 'Nie zainstalowane')"
	@echo "Lokalizacja: $(shell python -c "import spyq; print(spyq.__file__)" 2>/dev/null || echo 'Nie zainstalowane')"
	@echo "Python: $(shell python --version)"
	@echo "Pliki projektu:"
	@find . -name "*.py" | head -10
	@echo "Linie kodu:"
	@find . -name "*.py" -not -path "./build/*" -not -path "./dist/*" | xargs wc -l | tail -1