#!/bin/bash
# Skrypt instalacyjny Spyq z automatyczną konfiguracją aliasu

set -e

# Kolory dla output'u
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Instalator Spyq - Python Validator Proxy${NC}"
echo "================================================"

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

# Sprawdź czy pip jest dostępny
if ! $PYTHON_CMD -m pip --version &> /dev/null; then
    echo -e "${RED}❌ Błąd: pip nie jest dostępny${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Pip jest dostępny${NC}"

# Zapisz oryginalną ścieżkę Python przed instalacją
ORIGINAL_PYTHON=$(which $PYTHON_CMD)
echo -e "${BLUE}📍 Oryginalny Python: ${ORIGINAL_PYTHON}${NC}"

# Instaluj Spyq
echo -e "${YELLOW}📦 Instalowanie Spyq...${NC}"
$PYTHON_CMD -m pip install .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Spyq zainstalowany pomyślnie${NC}"
else
    echo -e "${RED}❌ Błąd instalacji Spyq${NC}"
    exit 1
fi

# Ustaw zmienną środowiskową z oryginalnym Python
export SPYQ_ORIGINAL_PYTHON="$ORIGINAL_PYTHON"

# Funkcja dodawania aliasu do pliku shell'a
add_alias_to_file() {
    local file=$1
    local shell_name=$2

    if [ -f "$file" ]; then
        # Sprawdź czy alias już istnieje
        if grep -q "alias python.*spyq" "$file"; then
            echo -e "${YELLOW}⚠️  Alias już istnieje w $file${NC}"
            return 0
        fi

        echo "" >> "$file"
        echo "# Spyq - Python Validator Proxy" >> "$file"
        echo "export SPYQ_ORIGINAL_PYTHON=\"$ORIGINAL_PYTHON\"" >> "$file"
        echo "alias python='spyq'" >> "$file"
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
            if ! grep -q "alias python.*spyq" "$FISH_CONFIG"; then
                echo "" >> "$FISH_CONFIG"
                echo "# Spyq - Python Validator Proxy" >> "$FISH_CONFIG"
                echo "set -gx SPYQ_ORIGINAL_PYTHON \"$ORIGINAL_PYTHON\"" >> "$FISH_CONFIG"
                echo "alias python='spyq'" >> "$FISH_CONFIG"
                echo "" >> "$FISH_CONFIG"
                echo -e "${GREEN}✅ Alias skonfigurowany dla Fish${NC}"
                echo -e "${YELLOW}💡 Zrestartuj terminal lub uruchom nową sesję${NC}"
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
        echo "export SPYQ_ORIGINAL_PYTHON=\"$ORIGINAL_PYTHON\""
        echo "alias python='spyq'"
        ;;
esac

# Test instalacji
echo ""
echo -e "${BLUE}🧪 Test instalacji...${NC}"

if command -v spyq &> /dev/null; then
    echo -e "${GREEN}✅ Komenda 'spyq' jest dostępna${NC}"

    # Stwórz testowy plik
    TEST_FILE="/tmp/spyq_test.py"
    cat > "$TEST_FILE" << 'EOF'
#!/usr/bin/env python3
print("Spyq test - OK!")
EOF

    # Test walidacji
    echo -e "${BLUE}🔍 Test walidacji...${NC}"
    if spyq "$TEST_FILE" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Walidacja działa poprawnie${NC}"
    else
        echo -e "${YELLOW}⚠️  Test walidacji zwrócił błąd (może to być normalne)${NC}"
    fi

    # Usuń plik testowy
    rm -f "$TEST_FILE"
else
    echo -e "${RED}❌ Komenda 'spyq' nie jest dostępna${NC}"
    echo -e "${YELLOW}💡 Sprawdź czy $HOME/.local/bin jest w PATH${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Instalacja zakończona!${NC}"
echo ""
echo -e "${BLUE}📋 Następne kroki:${NC}"
echo "1. Zrestartuj terminal lub uruchom: source ~/.bashrc (lub odpowiedni plik)"
echo "2. Sprawdź czy alias działa: python --version"
echo "3. Przetestuj walidację: python twoj_skrypt.py"
echo ""
echo -e "${BLUE}🔧 Konfiguracja:${NC}"
echo "- Alias: python -> spyq"
echo "- Oryginalny Python: $ORIGINAL_PYTHON"
echo "- Konfiguracja: ~/.spyq/config.json"
echo ""
echo -e "${BLUE}📖 Więcej informacji:${NC}"
echo "- Dokumentacja: README.md"
echo "- Konfiguracja: spyq --help"
echo ""
echo -e "${GREEN}Miłego używania Spyq! 🐍✨${NC}"