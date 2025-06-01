# Makefile dla projektu Spylog z Poetry

.PHONY: help install install-dev test test-cov clean build publish publish-test lint format check docs dev-setup

# Domyślny cel
help:
	@echo "🔍 Spylog - Python Validator Proxy"
	@echo "=================================="
	@echo ""
	@echo "Dostępne komendy Poetry:"
	@echo "  install      - poetry install"
	@echo "  install-dev  - poetry install z dev dependencies"
	@echo "  shell        - poetry shell (aktywuj środowisko)"
	@echo "  test         - poetry run pytest"
	@echo "  test-cov     - poetry run pytest z pokryciem"
	@echo "  lint         - flake8 + mypy"
	@echo "  format       - black"
	@echo "  check        - format + lint + test"
	@echo "  clean        - wyczyść pliki tymczasowe"
	@echo "  build        - poetry build"
	@echo "  publish-test - poetry publish do TestPyPI"
	@echo "  publish      - poetry publish do PyPI"
	@echo "  dev-setup    - kompletna konfiguracja deweloperska"
	@echo ""
	@echo "Pomocnicze:"
	@echo "  info         - informacje o projekcie"
	@echo "  deps         - pokaż drzewo zależności"
	@echo "  update       - poetry update"

# Sprawdź czy Poetry jest dostępne
check-poetry:
	@which poetry > /dev/null || (echo "❌ Poetry nie jest zainstalowane. Zainstaluj z: https://python-poetry.org/docs/#installation" && exit 1)

# Instalacja
install: check-poetry
	@echo "📦 Instalowanie Spylog..."
	poetry install --only main

install-dev: check-poetry
	@echo "🔧 Instalowanie w trybie deweloperskim..."
	poetry install

# Aktywacja środowiska
shell: check-poetry
	@echo "🐚 Aktywacja środowiska Poetry..."
	poetry shell

# Testy
test: check-poetry
	@echo "🧪 Uruchamianie testów..."
	poetry run pytest tests/ -v

test-cov: check-poetry
	@echo "🧪 Uruchamianie testów z pokryciem kodu..."
	poetry run pytest tests/ -v --cov=spylog --cov-report=html --cov-report=term-missing

# Jakość kodu
lint: check-poetry
	@echo "🔍 Sprawdzanie jakości kodu..."
	@echo "→ flake8..."
	poetry run flake8 spylog tests
	@echo "→ mypy..."
	poetry run mypy spylog

format: check-poetry
	@echo "✨ Formatowanie kodu..."
	poetry run black spylog tests

check: format lint test
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
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete

# Budowanie i publikacja
build: check-poetry clean
	@echo "🏗️  Budowanie paczki..."
	poetry build

publish-test: check-poetry build
	@echo "📤 Publikacja na TestPyPI..."
	poetry config repositories.testpypi https://test.pypi.org/legacy/
	poetry publish -r testpypi

publish: check-poetry build
	@echo "📤 Publikacja na PyPI..."
	poetry publish

# Zarządzanie zależnościami
deps: check-poetry
	@echo "📊 Drzewo zależności:"
	poetry show --tree

update: check-poetry
	@echo "🔄 Aktualizacja zależności..."
	poetry update

# Dodawanie zależności
add-dep: check-poetry
	@echo "➕ Dodaj zależność (użyj: make add-dep DEP=nazwa-paczki)"
	poetry add $(DEP)

add-dev-dep: check-poetry
	@echo "➕ Dodaj zależność deweloperską"
	poetry add --group dev $(DEP)

# Konfiguracja deweloperska
dev-setup: check-poetry
	@echo "🚀 Konfiguracja środowiska deweloperskiego..."
	poetry install
	poetry run pre-commit install 2>/dev/null || echo "⚠️  pre-commit nie jest zainstalowane"
	@echo ""
	@echo "✅ Środowisko deweloperskie gotowe!"
	@echo ""
	@echo "Następne kroki:"
	@echo "1. poetry shell       # Aktywuj środowisko"
	@echo "2. make test          # Uruchom testy"
	@echo "3. make format        # Sformatuj kod"
	@echo "4. make check         # Sprawdź wszystko"

# Pre-commit hook
pre-commit: format lint test
	@echo "✅ Pre-commit sprawdzenia zakończone!"

# Uruchamianie Spylog
run: check-poetry
	@echo "🚀 Uruchamianie Spylog..."
	poetry run spylog $(ARGS)

# Informacje o projekcie
info: check-poetry
	@echo "📊 Informacje o projekcie Spylog"
	@echo "================================"
	@echo "Wersja Poetry: $(shell poetry --version 2>/dev/null || echo 'Nie zainstalowane')"
	@echo "Wersja Python: $(shell poetry run python --version 2>/dev/null || echo 'Środowisko nieaktywne')"
	@echo "Lokalizacja środowiska: $(shell poetry env info --path 2>/dev/null || echo 'Brak')"
	@echo "Wersja Spylog: $(shell poetry run python -c "import spylog; print(spylog.__version__)" 2>/dev/null || echo 'Nie zainstalowane')"
	@echo ""
	@echo "Status projektu:"
	@find . -name "*.py" -not -path "./build/*" -not -path "./dist/*" -not -path "./.venv/*" | wc -l | sed 's/^/Pliki Python: /'
	@find . -name "*.py" -not -path "./build/*" -not -path "./dist/*" -not -path "./.venv/*" | xargs wc -l | tail -1 | sed 's/^/Łączne linie: /'

# Środowisko wirtualne
venv-info: check-poetry
	@echo "🔍 Informacje o środowisku wirtualnym:"
	poetry env info

venv-remove: check-poetry
	@echo "🗑️  Usuwanie środowiska wirtualnego..."
	poetry env remove --all

# Bezpieczeństwo
security-check: check-poetry
	@echo "🔒 Sprawdzanie bezpieczeństwa zależności..."
	poetry run pip list --format=freeze | poetry run safety check --stdin || echo "⚠️  safety nie jest zainstalowane"

# Dokumentacja
docs:
	@echo "📚 Generowanie dokumentacji..."
	@echo "README.md jest główną dokumentacją"
	@echo "Dodatkowa dokumentacja może być dodana w przyszłości"

# Instalacja z aliasem
install-with-alias: install-dev
	@echo "🔗 Uruchamianie skryptu instalacyjnego z aliasem..."
	@bash install.sh

# Testowanie pakietu
test-package: build
	@echo "🧪 Testowanie zbudowanej paczki..."
	poetry run pip install dist/*.whl --force-reinstall
	poetry run spylog --help

# Sprawdzenie środowiska
env-check: check-poetry
	@echo "🔍 Sprawdzanie środowiska..."
	@echo "Poetry: $(shell poetry --version)"
	@echo "Python w Poetry: $(shell poetry run python --version 2>/dev/null || echo 'Środowisko nieaktywne')"
	@echo "Pip w Poetry: $(shell poetry run pip --version 2>/dev/null || echo 'Środowisko nieaktywne')"
	@echo "Lokalizacja Poetry env: $(shell poetry env info --path 2>/dev/null || echo 'Brak')"

# Linting z różnymi narzędziami
lint-all: check-poetry
	@echo "🔍 Kompleksowe sprawdzanie kodu..."
	@echo "→ black --check..."
	poetry run black --check spylog tests || echo "❌ Kod wymaga formatowania"
	@echo "→ flake8..."
	poetry run flake8 spylog tests
	@echo "→ mypy..."
	poetry run mypy spylog
	@echo "→ pytest..."
	poetry run pytest tests/ --tb=short

# Aktualizacja wersji
bump-version:
	@echo "📈 Aktualizacja wersji..."
	@echo "Obecna wersja: $(shell poetry version -s)"
	poetry version patch
	@echo "Nowa wersja: $(shell poetry version -s)"
	@echo "💡 Nie zapomnij zaktualizować __init__.py!"

# CI/CD helpers
ci-install: check-poetry
	@echo "🔄 Instalacja dla CI/CD..."
	poetry install --no-interaction --no-ansi

ci-test: check-poetry
	@echo "🤖 Testy dla CI/CD..."
	poetry run pytest tests/ --tb=short --no-header -q

ci-build: check-poetry
	@echo "🏗️  Budowanie dla CI/CD..."
	poetry build --no-interaction --no-ansi

# Debugowanie
debug: check-poetry
	@echo "🐛 Tryb debugowania..."
	@echo "Zmienne środowiskowe:"
	@env | grep -E "(PYTHON|POETRY|SPYLOG)" || echo "Brak zmiennych PYTHON/POETRY/SPYLOG"
	@echo ""
	@echo "Zawartość dist/:"
	@ls -la dist/ 2>/dev/null || echo "Katalog dist/ nie istnieje"
	@echo ""
	@echo "Status git:"
	@git status --porcelain 2>/dev/null || echo "Nie jest repozytorium git"

# Kompletny reset
reset: clean venv-remove
	@echo "🔄 Kompletny reset projektu..."
	rm -rf poetry.lock
	@echo "✅ Reset zakończony. Uruchom 'make install-dev' aby reinstalować"

# Quick start dla nowych deweloperów
quickstart: check-poetry
	@echo "🚀 Quick start dla Spylog"
	@echo "========================"
	@echo ""
	@echo "1. Instalacja środowiska:"
	@echo "   make install-dev"
	@echo ""
	@echo "2. Aktywacja środowiska:"
	@echo "   poetry shell"
	@echo ""
	@echo "3. Uruchomienie testów:"
	@echo "   make test"
	@echo ""
	@echo "4. Formatowanie kodu:"
	@echo "   make format"
	@echo ""
	@echo "5. Kompleksowe sprawdzenie:"
	@echo "   make check"
	@echo ""
	@echo "6. Budowanie paczki:"
	@echo "   make build"