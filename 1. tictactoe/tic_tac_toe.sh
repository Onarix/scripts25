#!/bin/bash

SAVE_FILE="tictactoe.save"
board="         "  # 9 spaces = empty board
current_player="X"
vs_computer=false

draw_board() {
    echo ""
    echo " ${board:0:1} | ${board:1:1} | ${board:2:1} "
    echo "---+---+---"
    echo " ${board:3:1} | ${board:4:1} | ${board:5:1} "
    echo "---+---+---"
    echo " ${board:6:1} | ${board:7:1} | ${board:8:1} "
    echo ""
}

check_winner() {
    for combo in 012 345 678 036 147 258 048 246; do
        a=${combo:0:1}
        b=${combo:1:1}
        c=${combo:2:1}
        if [[ "${board:$a:1}" != " " && "${board:$a:1}" == "${board:$b:1}" && "${board:$b:1}" == "${board:$c:1}" ]]; then
            echo "${board:$a:1}"
            return
        fi
    done
    if [[ "$board" != *" "* ]]; then
        echo "draw"
    fi
}

save_game() {
    printf "%s\n" "$board" > "$SAVE_FILE"
    echo "$current_player" >> "$SAVE_FILE"
    echo "$vs_computer" >> "$SAVE_FILE"
    echo "Game saved to $SAVE_FILE."
    main_menu
}

load_game() {
    if [[ -f "$SAVE_FILE" ]]; then
        IFS= read -r board < <(sed -n 1p "$SAVE_FILE")
        read -r current_player < <(sed -n 2p "$SAVE_FILE")
        read -r vs_computer < <(sed -n 3p "$SAVE_FILE")

        # Uzupełnij brakujące spacje, jeśli plansza ma < 9 znaków
        while [[ ${#board} -lt 9 ]]; do
            board+=" "
        done

        echo "Game loaded from $SAVE_FILE."
    else
        echo "No save file found."
        exit 1
    fi
}

player_move() {
    local move
    while true; do
        read -p "Player $current_player - choose position (1-9), S to save, Q to quit: " move
        if [[ "$move" =~ ^[1-9]$ ]]; then
            index=$((move - 1))
            if [[ "${board:$index:1}" == " " ]]; then
                board="${board:0:$index}$current_player${board:((index + 1))}"
                break
            else
                echo "That position is already taken."
            fi
        elif [[ "$move" =~ ^[Ss]$ ]]; then
            save_game
            exit
        elif [[ "$move" =~ ^[Qq]$ ]]; then
            echo "Game exited."
            exit
        else
            echo "Invalid input."
        fi
    done
}

computer_move() {
    echo "Computer is thinking..."
    sleep 1
    local i empty=()
    for ((i = 0; i < 9; i++)); do
        [[ "${board:$i:1}" == " " ]] && empty+=($i)
    done
    if [[ ${#empty[@]} -gt 0 ]]; then
        choice=${empty[$((RANDOM % ${#empty[@]}))]}
        board="${board:0:$choice}$current_player${board:((choice + 1))}"
    fi
}

main_loop() {
    while true; do
        draw_board
        if [[ "$vs_computer" == true && "$current_player" == "O" ]]; then
            computer_move
        else
            player_move
        fi

        result=$(check_winner)
        if [[ "$result" == "X" || "$result" == "O" ]]; then
            draw_board
            echo "Player $result wins!"
            main_menu
        elif [[ "$result" == "draw" ]]; then
            draw_board
            echo "It's a draw!"
            main_menu 
        fi

        [[ "$current_player" == "X" ]] && current_player="O" || current_player="X"
    done
}

main_menu() {
    echo "=== Tic Tac Toe ==="
    echo "1. New game (Player vs Player)"
    echo "2. New game (Player vs Computer)"
    echo "3. Load saved game"
    echo "4. Exit game"
    read -p "Select an option: " choice
    
    case "$choice" in
        1) vs_computer=false; main_loop ;;
        2) vs_computer=true; main_loop ;;
        3) load_game; main_loop ;;
        4) echo "Thanks for playing tictactoe..."; exit 1 ;;
        *) echo "Invalid option!"; main_menu ;;
    esac
}

main_menu