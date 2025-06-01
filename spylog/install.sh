#!/bin/bash
# Skrypt instalacyjny Spylog z Poetry i automatyczną konfiguracją aliasu

set -e

# Kolory dla output'u
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${PURPLE}🔍 Instalator Spylog - Python Validator Proxy${NC}"
echo "=================================================="

# Sprawdź czy Python jest dostępny
if ! command -v python3 &> /dev/null && ! command -v python &> /dev/null; then
    echo -e "${RED}❌ Błąd: Python nie jest zainstalowany lub niedostępny w PATH${NC}"
    exit 1
fi

# Znajdź interpreter Pythona
if command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
elif command -v python &> /dev/null; then
    PYTHON_CMD="python"
else
    echo -e "${RED}❌ Nie można znaleźć interpretera Python${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Znaleziono Python: ${PYTHON_CMD}${NC}"

# Sprawdź wersję Python
PYTHON_VERSION=$($PYTHON_CMD -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
REQUIRED_VERSION="3.8"

if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$PYTHON_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
    echo -e "${RED}❌ Błąd: Wymagany Python $REQUIRED_VERSION+, znaleziono $PYTHON_VERSION${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Wersja Python OK: $PYTHON_VERSION${NC}"

# Sprawdź czy Poetry jest zainstalowane
INSTALL_METHOD=""
if command -v poetry &> /dev/null; then
    echo -e "${GREEN}✅ Poetry jest dostępne${NC}"
    INSTALL_METHOD="poetry"
else
    echo -e "${YELLOW}⚠️  Poetry nie jest zainstalowane${NC}"
    echo -e "${BLUE}💡 Można zainstalować Poetry: https://python-poetry.org/docs/#installation${NC}"

    # Sprawdź pip jako fallback
    if $PYTHON_CMD -m pip --version &> /dev/null; then
        echo -e "${GREEN}✅ Pip jest dostępny - używam pip zamiast Poetry${NC}"
        INSTALL_METHOD="pip"
    else
        echo -e "${RED}❌ Błąd: Ani Poetry ani pip nie są dostępne${NC}"
        exit 1
    fi
fi

# Zapisz oryginalną ścieżkę Python przed instalacją
ORIGINAL_PYTHON=$(which $PYTHON_CMD)
echo -e "${BLUE}📍 Oryginalny Python: ${ORIGINAL_PYTHON}${NC}"

# Funkcja instalacji z Poetry
install_with_poetry() {
    echo -e "${YELLOW}📦 Instalowanie Spylog z Poetry...${NC}"

    # Sprawdź czy jesteśmy w katalogu z pyproject.toml
    if [ ! -f "pyproject.toml" ]; then
        echo -e "${RED}❌ Błąd: Nie znaleziono pyproject.toml w bieżącym katalogu${NC}"
        echo -e "${BLUE}💡 Uruchom skrypt z katalogu głównego projektu Spylog${NC}"
        exit 1
    fi

    # Instaluj zależności i paczkę
    poetry install

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Spylog zainstalowany z Poetry${NC}"

        # Sprawdź czy spylog jest dostępny
        if poetry run spylog --help &> /dev/null; then
            echo -e "${GREEN}✅ Komenda spylog działa poprawnie${NC}"
        else
            echo -e "${YELLOW}⚠️  Ostrzeżenie: Komenda spylog może wymagać aktywacji środowiska Poetry${NC}"
            echo -e "${BLUE}💡 Użyj: poetry shell${NC}"
        fi

        return 0
    else
        echo -e "${RED}❌ Błąd instalacji z Poetry${NC}"
        return 1
    fi
}

# Funkcja instalacji z pip
install_with_pip() {
    echo -e "${YELLOW}📦 Instalowanie Spylog z pip...${NC}"

    $PYTHON_CMD -m pip install .

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Spylog zainstalowany z pip${NC}"
        return 0
    else
        echo -e "${RED}❌ Błąd instalacji z pip${NC}"
        return 1
    fi
}

# Instaluj według dostępnej metody
case $INSTALL_METHOD in
    "poetry")
        install_with_poetry
        ;;
    "pip")
        install_with_pip
        ;;
    *)
        echo -e "${RED}❌ Nieznana metoda instalacji${NC}"
        exit 1
        ;;
esac

# Ustaw zmienną środowiskową z oryginalnym Python
export SPYLOG_ORIGINAL_PYTHON="$ORIGINAL_PYTHON"

# Funkcja dodawania aliasu do pliku shell'a
add_alias_to_file() {
    local file=$1
    local shell_name=$2

    if [ -f "$file" ]; then
        # Sprawdź czy alias już istnieje
        if grep -q "alias python.*spylog" "$file"; then
            echo -e "${YELLOW}⚠️  Alias już istnieje w $file${NC}"
            return 0
        fi

        echo "" >> "$file"
        echo "# Spylog - Python Validator Proxy" >> "$file"
        echo "export SPYLOG_ORIGINAL_PYTHON=\"$ORIGINAL_PYTHON\"" >> "$file"

        if [ "$INSTALL_METHOD" = "poetry" ]; then
            echo "alias python='poetry run spylog'" >> "$file"
            echo -e "${BLUE}💡 Uwaga: Alias używa 'poetry run spylog'${NC}"
            echo -e "${BLUE}💡 Alternatywnie aktywuj środowisko: poetry shell${NC}"
        else
            echo "alias python='spylog'" >> "$file"
        fi

        echo "" >> "$file"

        echo -e "${GREEN}✅ Alias dodany do $file${NC}"
        return 0
    fi
    return 1
}

# Wykryj shell i dodaj alias
SHELL_NAME=$(basename "$SHELL")
echo -e "${BLUE}🐚 Wykryty shell: $SHELL_NAME${NC}"

case $SHELL_NAME in
    "bash")
        if add_alias_to_file "$HOME/.bashrc" "bash"; then
            echo -e "${GREEN}✅ Alias skonfigurowany dla Bash${NC}"
            echo -e "${YELLOW}💡 Uruchom: source ~/.bashrc lub zrestartuj terminal${NC}"
        else
            echo -e "${YELLOW}⚠️  Nie znaleziono ~/.bashrc${NC}"
        fi
        ;;
    "zsh")
        if add_alias_to_file "$HOME/.zshrc" "zsh"; then
            echo -e "${GREEN}✅ Alias skonfigurowany dla Zsh${NC}"
            echo -e "${YELLOW}💡 Uruchom: source ~/.zshrc lub zrestartuj terminal${NC}"
        else
            echo -e "${YELLOW}⚠️  Nie znaleziono ~/.zshrc${NC}"
        fi
        ;;
    "fish")
        FISH_CONFIG="$HOME/.config/fish/config.fish"
        if [ -f "$FISH_CONFIG" ]; then
            if ! grep -q "alias python.*spylog" "$FISH_CONFIG"; then
                echo "" >> "$FISH_CONFIG"
                echo "# Spylog - Python Validator Proxy" >> "$FISH_CONFIG"
                echo "set -gx SPYLOG_ORIGINAL_PYTHON \"$ORIGINAL_PYTHON\"" >> "$FISH_CONFIG"

                if [ "$INSTALL_METHOD" = "poetry" ]; then
                    echo "alias python='poetry run spylog'" >> "$FISH_CONFIG"
                else
                    echo "alias python='spylog'" >> "$FISH_CONFIG"
                fi

                echo "" >> "$FISH_CONFIG"
                echo -e "${GREEN}✅ Alias skonfigurowany dla Fish${NC}"
                echo -e "${YELLOW}💡 Zrestartuj terminal${NC}"
            else
                echo -e "${YELLOW}⚠️  Alias już istnieje w $FISH_CONFIG${NC}"
            fi
        else
            echo -e "${YELLOW}⚠️  Nie znaleziono $FISH_CONFIG${NC}"
        fi
        ;;
    *)
        echo -e "${YELLOW}⚠️  Nieznany shell: $SHELL_NAME${NC}"
        echo -e "${BLUE}💡 Dodaj ręcznie do pliku konfiguracyjnego shell'a:${NC}"
        echo "export SPYLOG_ORIGINAL_PYTHON=\"$ORIGINAL_PYTHON\""
        if [ "$INSTALL_METHOD" = "poetry" ]; then
            echo "alias python='poetry run spylog'"
        else
            echo "alias python='spylog'"
        fi
        ;;
esac

# Test instalacji
echo ""
echo -e "${BLUE}🧪 Test instalacji...${NC}"

# Test komendy spylog
if [ "$INSTALL_METHOD" = "poetry" ]; then
    if poetry run spylog --help &> /dev/null; then
        echo -e "${GREEN}✅ Komenda 'poetry run spylog' działa${NC}"
    else
        echo -e "${YELLOW}⚠️  Komenda 'poetry run spylog' nie działa${NC}"
    fi
else
    if command -v spylog &> /dev/null; then
        echo -e "${GREEN}✅ Komenda 'spylog' jest dostępna${NC}"
    else
        echo -e "${RED}❌ Komenda 'spylog' nie jest dostępna${NC}"
        echo -e "${YELLOW}💡 Sprawdź czy $HOME/.local/bin jest w PATH${NC}"
    fi
fi

# Stwórz testowy plik
TEST_FILE="/tmp/spylog_test.py"
cat > "$TEST_FILE" << 'EOF'
#!/usr/bin/env python3
print("Spylog test - OK!")
EOF

# Test walidacji
echo -e "${BLUE}🔍 Test walidacji...${NC}"
if [ "$INSTALL_METHOD" = "poetry" ]; then
    if poetry run spylog "$TEST_FILE" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Walidacja działa poprawnie${NC}"
    else
        echo -e "${YELLOW}⚠️  Test walidacji zwrócił błąd${NC}"
    fi
else
    if spylog "$TEST_FILE" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Walidacja działa poprawnie${NC}"
    else
        echo -e "${YELLOW}⚠️  Test walidacji zwrócił błąd${NC}"
    fi
fi

# Usuń plik testowy
rm -f "$TEST_FILE"

echo ""
echo -e "${GREEN}🎉 Instalacja Spylog zakończona pomyślnie!${NC}"
echo ""
echo -e "${BLUE}📋 Następne kroki:${NC}"

if [ "$INSTALL_METHOD" = "poetry" ]; then
    echo "1. Aktywuj środowisko Poetry: poetry shell"
    echo "2. LUB zrestartuj terminal dla aliasu"
    echo "3. Przetestuj: python twoj_skrypt.py"
    echo ""
    echo -e "${BLUE}🔧 Środowisko Poetry:${NC}"
    echo "- Instalacja: poetry install"
    echo "- Aktywacja: poetry shell"
    echo "- Testy: poetry run pytest"
    echo "- Budowanie: poetry build"
else
    echo "1. Zrestartuj terminal lub: source ~/.bashrc"
    echo "2. Przetestuj: python twoj_skrypt.py"
    echo ""
    echo -e "${BLUE}🔧 Zarządzanie z pip:${NC}"
    echo "- Aktualizacja: pip install --upgrade spylog"
    echo "- Usunięcie: pip uninstall spylog"
fi

echo ""
echo -e "${BLUE}⚙️ Konfiguracja:${NC}"
echo "- Alias: python -> spylog"
echo "- Oryginalny Python: $ORIGINAL_PYTHON"
echo "- Konfiguracja: ~/.spylog/config.json"
echo "- Metoda instalacji: $INSTALL_METHOD"
echo ""
echo -e "${GREEN}Miłego używania Spylog! 🐍✨${NC}"