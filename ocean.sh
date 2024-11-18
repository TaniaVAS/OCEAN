#!/bin/bash

# Определения цветов и форматирования
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

# Иконки для пунктов меню
ICON_TELEGRAM="🚀"
ICON_INSTALL="🛠️"
ICON_LOGS="📄"
ICON_STOP="⏹️"
ICON_START="▶️"
ICON_WALLET="💰"
ICON_EXIT="❌"
ICON_CHANGE_RPC="🔄"
ICON_DELETE="🗑️"

# Функции для рисования границ
draw_top_border() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════╗${RESET}"
}

draw_middle_border() {
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════════╣${RESET}"
}

draw_bottom_border() {
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════╝${RESET}"
}

# Логотип и информация
display_ascii() {
    echo -e "${CYAN}   ____   _  __   ___    ____ _   __   ____ ______   ____   ___    ____${RESET}"
    echo -e "${CYAN}  /  _/  / |/ /  / _ \  /  _/| | / /  /  _//_  __/  /  _/  / _ |  / __/${RESET}"
    echo -e "${CYAN} _/ /   /    /  / // / _/ /  | |/ /  _/ /   / /    _/ /   / __ | _\ \  ${RESET}"
    echo -e "${CYAN}/___/  /_/|_/  /____/ /___/  |___/  /___/  /_/    /___/  /_/ |_|/___/  ${RESET}"
    echo -e ""
    echo -e "${YELLOW}Подписывайтесь на Telegram: https://t.me/CryptalikBTC${RESET}"
    echo -e "${YELLOW}Подписывайтесь на YouTube: https://www.youtube.com/@Cryptalik${RESET}"
    echo -e "${YELLOW}Здесь про аирдропы и ноды: https://t.me/indivitias${RESET}"
    echo -e "${YELLOW}Купи мне бутылочку кефира %)${RESET}"
    echo -e "${GREEN}0x8a3476d7cd2bf198b2f4dc492d9726e1d1fb25fb${RESET}"
    echo -e ""
    echo -e "${CYAN}Полезные команды:${RESET}"
    echo -e "  - ${YELLOW}Просмотр файлов директории:${RESET} ls"
    echo -e "  - ${YELLOW}Вход в директорию:${RESET} cd docker-browser"
    echo -e "  - ${YELLOW}Выход из директории:${RESET} cd .."
    echo -e ""
}

 # Отображение текущей директории и IP-адреса
    current_dir=$(pwd)
    ip_address=$(get_ip_address)
    echo -e "    ${GREEN}Текущая директория:${RESET} ${current_dir}"
    echo -e "    ${GREEN}IP-адрес:${RESET} ${ip_address}"
    draw_middle_border

    echo -e "    ${YELLOW}Выберите пункт меню:${RESET}"
    echo
    echo -e "    ${CYAN}1.${RESET} ${ICON_INSTALL} Установить ноду"
    echo -e "    ${CYAN}2.${RESET} ${ICON_LOGS} Просмотр логов Typesense"
    echo -e "    ${CYAN}3.${RESET} ${ICON_LOGS} Просмотр логов Ocean Node"
    echo -e "    ${CYAN}4.${RESET} ${ICON_STOP} Остановить ноду"
    echo -e "    ${CYAN}5.${RESET} ${ICON_START} Запустить ноду"
    echo -e "    ${CYAN}6.${RESET} ${ICON_WALLET} Просмотреть созданные кошельки"
    echo -e "    ${CYAN}7.${RESET} ${ICON_CHANGE_RPC} Изменить RPC"  # Новый пункт меню
    echo -e "    ${CYAN}0.${RESET} ${ICON_EXIT} Выход"
    echo
    draw_bottom_border
    echo -ne "    ${YELLOW}Введите ваш выбор [0-7]:${RESET} "
    read choice
}

install_node() {
    echo -e "${GREEN}🛠️  Установка ноды...${RESET}"
    sudo apt update && sudo apt upgrade -y

    if ! command -v docker &> /dev/null; then
        sudo apt install docker.io -y
        sudo systemctl start docker
        sudo systemctl enable docker
    fi

    if ! command -v docker-compose &> /dev/null; then
        sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" \
        -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    fi

    if ! command -v python3 &> /dev/null; then
        sudo apt install python3 -y
    fi
    if ! command -v pip3 &> /dev/null; then
        sudo apt install python3-pip -y
    fi

    if ! command -v crontab &> /dev/null; then
        sudo apt install cron -y
        sudo systemctl enable cron
        sudo systemctl start cron
    fi

    pip3 install eth_account requests

    echo -ne "${YELLOW}Введите количество нод:${RESET} "
    read num_nodes

    ip_address=$(hostname -I | awk '{print $1}')
    if [[ -z "$ip_address" ]]; then
        echo -ne "${YELLOW}Не удалось автоматически определить IP-адрес.${RESET}"
        echo -ne "${YELLOW} Пожалуйста, введите IP-адрес:${RESET} "
        read ip_address
    fi

    python3 script.py "$ip_address" "$num_nodes"
    docker network create ocean_network

    for ((i=1; i<=num_nodes+1; i++)); do
        docker-compose -f docker-compose$i.yaml up -d
    done

    current_dir=$(pwd)
    (crontab -l 2>/dev/null; echo "0 * * * * python3 $current_dir/req.py $ip_address $current_dir") | crontab -

    echo -e "${GREEN}✅ Нода успешно установлена.${RESET}"
    echo
    read -p "Нажмите Enter для возврата в главное меню..."
}

view_typesense_logs() {
    echo -e "${GREEN}📄 Просмотр логов Typesense...${RESET}"
    docker logs typesense
    echo
    read -p "Нажмите Enter для возврата в главное меню..."
}

view_ocean_node_logs() {
    echo -ne "${YELLOW}Введите количество нод:${RESET} "
    read num_nodes
    echo -ne "${YELLOW}Выберите номер ноды для просмотра логов (1-${num_nodes}):${RESET} "
    read node_number
    echo -e "${GREEN}📄 Просмотр логов ocean-node-${node_number}...${RESET}"
    docker logs ocean-node-$node_number
    echo
    read -p "Нажмите Enter для возврата в главное меню..."
}

stop_node() {
    echo -ne "${YELLOW}Введите количество нод:${RESET} "
    read num_nodes
    echo -e "${GREEN}⏹️  Остановка нод...${RESET}"
    for ((i=1; i<=num_nodes+1; i++)); do
        docker-compose -f docker-compose$i.yaml down
    done

    crontab -l | grep -v "req.py" | crontab -

    echo -e "${GREEN}✅ Ноды остановлены, задача в crontab удалена.${RESET}"
    echo
    read -p "Нажмите Enter для возврата в главное меню..."
}

start_node() {
    echo -ne "${YELLOW}Введите количество нод:${RESET} "
    read num_nodes

    ip_address=$(hostname -I | awk '{print $1}')
    if [[ -z "$ip_address" ]]; then
        echo -ne "${YELLOW}Не удалось автоматически определить IP-адрес.${RESET}"
        echo -ne "${YELLOW} Пожалуйста, введите IP-адрес:${RESET} "
        read ip_address
    fi

    echo -e "${GREEN}▶️  Запуск нод...${RESET}"
    for ((i=1; i<=num_nodes+1; i++)); do
        docker-compose -f docker-compose$i.yaml up -d
    done

    current_dir=$(pwd)
    (crontab -l 2>/dev/null; echo "0 * * * * python3 $current_dir/req.py $ip_address $current_dir") | crontab -

    echo -e "${GREEN}✅ Ноды запущены, задача в crontab добавлена.${RESET}"
    echo
    read -p "Нажмите Enter для возврата в главное меню..."
}

view_wallets() {
    echo -e "${GREEN}💰 Просмотр созданных кошельков...${RESET}"
    cat wallets.json
    echo
    read -p "Нажмите Enter для возврата в главное меню..."
}

change_rpc() {
    echo -ne "${YELLOW}Введите новый RPC URL:${RESET} "
    read new_rpc
    echo -e "${GREEN}🔄 Изменение RPC на ${new_rpc}...${RESET}"

    sed -i "s|https://.*|${new_rpc}|g" *.yaml

    echo -e "${GREEN}✅ RPC успешно обновлен.${RESET}"
    echo
    read -p "Нажмите Enter для возврата в главное меню..."
}

while true; do
    show_menu
    case $choice in
        1) install_node ;;
        2) view_typesense_logs ;;
        3) view_ocean_node_logs ;;
        4) stop_node ;;
        5) start_node ;;
        6) view_wallets ;;
        7) change_rpc ;;
        0) echo -e "${RED}Выход...${RESET}" && exit 0 ;;
        *) echo -e "${RED}❌ Неверный ввод. Попробуйте снова.${RESET}" && sleep 2 ;;
    esac
done
