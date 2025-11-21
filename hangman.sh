#!/bin/bash

# Файл со словами
WORDS_FILE="words.txt"

# === ФУНКЦИИ МАРИИ ===
get_random_word() {
    local words=()
    
    if [ ! -f "$WORDS_FILE" ]; then
        echo "Ошибка: файл со словами $WORDS_FILE не найден!" >&2
        exit 1
    fi
    
    mapfile -t words < "$WORDS_FILE"
    
    if [ ${#words[@]} -eq 0 ]; then
        echo "Ошибка: файл со словами пуст!" >&2
        exit 1
    fi
    
    local num_words=${#words[@]}
    local index=$((RANDOM % num_words))
    
    echo "${words[$index]}"
}

init_guessed_word() {
    local word=$1
    guessed_word=()
    local length=${#word}
    local i
    for ((i=0; i<length; i++)); do
        guessed_word+=( "_" )
    done
}

display_guessed_word() {
    echo "Слово: ${guessed_word[@]}"
}

# === ФУНКЦИИ ЛЕОНИДА ===
draw_hangman() {
    local errors=$1
    case $errors in
        0) echo "
        ------
        |    |
        |
        |
        |
        |
        |
        |
        |
        ----------
        " ;;
        1) echo "
        ------
        |    |
        |    O
        |
        |
        |
        |
        |
        |
        ----------
        " ;;
        2) echo "
        ------
        |    |
        |    O
        |    |
        |    |
        |
        |
        |
        |
        ----------
        " ;;
        3) echo "
        ------
        |    |
        |    O
        |   /|
        |    |
        |
        |
        |
        |
        ----------
        " ;;
        4) echo "
        ------
        |    |
        |    O
        |   /|\\
        |    |
        |
        |
        |
        |
        ----------
        " ;;
        5) echo "
        ------
        |    |
        |    O
        |   /|\\
        |    |
        |   /
        |
        |
        |
        ----------
        " ;;
        6) echo "
        ------
        |    |
        |    O
        |   /|\\
        |    |
        |   / \\
        |
        |
        |
        ----------
        " ;;
    esac
}

get_user_guess() {
    local guess
    while true; do
        read -p "Введите букву: " guess
        guess=$(echo "$guess" | tr '[:lower:]' '[:upper:]')
        
        if [[ $guess =~ ^[А-ЯЁ]$ ]]; then
            break
        else
            echo "Ошибка: пожалуйста, введите одну букву русского алфавита."
        fi
    done
    echo "$guess"
}

print_welcome() {
    echo "=== Добро пожаловать в игру 'Виселица'! ==="
    echo "Я загадал слово. Попробуй угадать его по буквам."
    echo "У тебя есть 6 попыток."
    echo
}

print_win() {
    echo "Поздравляю! Ты угадал слово '$secret_word'!"
}

print_lose() {
    echo "К сожалению, ты проиграл. Было загадано слово: '$secret_word'."
}

# === ФУНКЦИИ УЛЬЯНЫ ===
main() {
    local secret_word
    local guessed_word=()
    local guessed_letters=""
    local errors=0
    local max_errors=6
    local guess
    local correct_guess
    
    secret_word=$(get_random_word)
    init_guessed_word "$secret_word"
    
    print_welcome
    
    while [ $errors -lt $max_errors ]; do
        echo "----------------------------------------"
        draw_hangman $errors
        echo
        display_guessed_word
        echo "Ошибок: $errors/$max_errors"
        if [ -n "$guessed_letters" ]; then
            echo "Использованные буквы: $guessed_letters"
        fi
        
        guess=$(get_user_guess)
        
        if [[ $guessed_letters == *"$guess"* ]]; then
            echo "Ты уже вводил эту букву. Попробуй другую."
            continue
        fi
        
        guessed_letters+=" $guess"
        correct_guess=0
        
        for ((i=0; i<${#secret_word}; i++)); do
            if [ "${secret_word:$i:1}" == "$guess" ]; then
                guessed_word[$i]="$guess"
                correct_guess=1
            fi
        done
        
        if [ $correct_guess -eq 0 ]; then
            echo "Нет такой буквы!"
            ((errors++))
        else
            echo "Есть такая буква!"
        fi
        
        local current_state=""
        for letter in "${guessed_word[@]}"; do
            current_state+="$letter"
        done
        
        if [ "$current_state" == "$secret_word" ]; then
            echo "----------------------------------------"
            display_guessed_word
            print_win
            break
        fi
    done
    
    if [ $errors -eq $max_errors ]; then
        echo "----------------------------------------"
        draw_hangman $errors
        print_lose
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
