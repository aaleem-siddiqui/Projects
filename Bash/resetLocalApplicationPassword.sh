#!/bin/bash
# JIRA-622 | Description: resets the password for local application user

# defining variables
RED='\033[1;31m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'; BLUE='\033[1;36m'; PINK='\033[1;35m'; PURPLE='\033[1;34m'; NC='\033[0m'
POSTGRES_PATH="/etc/opt/company/application"
DB_NAME="db_name"
DEFAULT_USERNAME="administrator"
PASSWORDS=(
    'PASSWORD1:AQAAAAEAACcQAAAAEF3HfeltexvdvqaH/GCAFyjO658A70OsdfWBGEioGXFCaCCnDUEP4Mue0YvgBpuFIzyrQ=='
    'PASSWORD2:AQAAAAEAACcQAAAAEH2BxJX+vZ8VasWC+jroMqmdfTg5HVgPhd8Sirn2gN7W1mpq25HStdH9gzeS2JaDsbrw=='
    'PASSWORD3:AQAAAAEAACcQAAAAEAwVbplxuNRxX35mCMs047+fkCSD/7L9TK63HXiqNFPxxIye2ZH6//4a7IPm30tx7ALlYw=='
)
LINE="----------------"
USER_COUNTER=0


# defining functions
RUN_QUERY() {
    local QUERY="$1"
    OUTPUT=$(PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$DB_NAME" -A -F ',' -t -c "$QUERY" 2>&1)
    echo "$OUTPUT"
}

REQUEST_USER_INPUT() {
    while true; do
        local PROMPT="$1"
        local PROMPT_TYPE="$2"
        read -p "$PROMPT" USER_INPUT
        case "$USER_INPUT" in
            [yY][eE][sS] | [yY] )
                PROCEED=true
                break
                ;;
            [nN][oO] | [nN] )
                PROCEED=false
                break
                ;;
            * )
                if [ "$PROMPT_TYPE" = "2" ]; then
                    echo -e "${RED}INVALID RESPONSE.$NC"
                else
                    if [[ "$USER_INPUT" =~ ^[0-9]+$ ]] && (( USER_INPUT >= MIN_RANGE && USER_INPUT <= MAX_RANGE )); then
                        PROCEED=false
                        USERNAME="${USER_ARRAY[$USER_INPUT]}"
                        break
                    elif [[ -z "$USER_INPUT" ]]; then
                        PROCEED=false
                        echo -e "${RED}WARNING:${NC} USERNAME FIELD LEFT NULL. SETTING USERNAME TO $YELLOW$DEFAULT_USERNAME$NC"
                        USERNAME="$DEFAULT_USERNAME"
                        break
                    else
                        echo -e "${RED}ENTER A VALID USERNAME CHOICE ($MIN_RANGE-$MAX_RANGE).$NC"
                    fi
                fi
                ;;
        esac
    done
}

CHOOSE_PASSWORD() {
    echo -e "$PINK$LINE\n\n\t- AVAILABLE PASSWORDS -"
    for i in "${!PASSWORDS[@]}"; do
        VALUE_TO_DISPLAY="${PASSWORDS[$i]%%:*}"
        echo -e "$PINK$((i+1)).$NC $VALUE_TO_DISPLAY"
    done
    echo -e "\n$PINK$LINE$NC"
    while true; do
        read -p "ENTER PASSWORD CHOICE: " PASSWORD_CHOICE
        if [[ $PASSWORD_CHOICE -ge 1 && $PASSWORD_CHOICE -le ${#PASSWORDS[@]} ]]; then
            PASSWORD_HASH="${PASSWORDS[$((PASSWORD_CHOICE-1))]#*:}"
            PASSWORD_RAW="${PASSWORDS[$((PASSWORD_CHOICE-1))]%%:*}"
            break
        else
            echo -e "${RED}INVALID RESPONSE.$NC PLEASE ENTER A VALUE BETWEEN 1-${#PASSWORDS[@]}:"
        fi
    done
}

#--------------------------------------------------------------------------------------------------------------------------------
# check user permissions + source psql credentials

clear
echo -e "SCRIPT START."
if [ "$(id -u)" -eq 0 ]; then
    echo -e "NAVIGATING TO SOURCE PATH ($BLUE$POSTGRES_PATH$NC)..."
    cd "$POSTGRES_PATH"
    echo -e "SOURCING PSQL CREDENTIALS..."
    if [ -f postgres ]; then
        source postgres
        if [ -z "$POSTGRES_USER" ]; then
            echo -e "${RED}WARNING:$NC POSTGRES_USER IS EMPTY OR NOT SET!"
        elif [ -z "$POSTGRES_PASSWORD" ]; then
            echo -e "${RED}WARNING:$NC POSTGRES_PASSWORD IS EMPTY OR NOT SET!"
        elif [ -z "$POSTGRES_HOST" ]; then
            echo -e "${RED}WARNING:$NC POSTGRES_HOST IS EMPTY OR NOT SET!"
        elif [ -z "$POSTGRES_PORT" ]; then
            echo -e "${RED}WARNING:$NC POSTGRES_PORT IS EMPTY OR NOT SET!"
        fi
    else
        echo -e "${RED}FILE 'postgres' NOT FOUND IN $POSTGRES_PATH${NC}"
        exit 1 >&/dev/null
    fi

    #--------------------------------------------------------------------------------------------------------------------------------
    # define user

    LIST_USERS_QUERY="SELECT \"UserName\", \"PasswordHash\", \"LockoutEnd\", \"AccessFailedCount\" FROM \"AspNetUsers\";"
    LIST_USERS=$(RUN_QUERY "$LIST_USERS_QUERY")
    echo -e "LISTING USERS IN application...\n$PURPLE$LINE\n\n\t- AVAILABLE USERS -"
    declare -A USER_ARRAY
    while read -r CURRENT_USER; do
        (( USER_COUNTER++ ))
        USER=$(echo "$CURRENT_USER" | cut -d ',' -f1)
        echo -e "$PURPLE$USER_COUNTER.$NC $USER"
        USER_ARRAY["$USER_COUNTER"]="$USER"
    done <<< "$LIST_USERS"
    echo -e "\n$PURPLE$LINE$NC"
    MIN_RANGE=1
    MAX_RANGE=$USER_COUNTER

    while true; do
        REQUEST_USER_INPUT "ENTER USERNAME CHOICE (LEAVE BLANK FOR 'ADMINISTRATOR'): " "1"
        echo -e "SEARCHING FOR USER $YELLOW$USERNAME$NC IN PSQL..."
        FIND_USER_QUERY="SELECT \"UserName\", \"PasswordHash\", \"LockoutEnd\", \"AccessFailedCount\" FROM \"AspNetUsers\" WHERE \"UserName\" = '$USERNAME';"
        FIND_USER=$(RUN_QUERY "$FIND_USER_QUERY")
        USERNAME_IN_DB=$(echo $FIND_USER | cut -d ',' -f1)
        PASSWORD_HASH_IN_DB=$(echo $FIND_USER | cut -d ',' -f2)

        if [ -z "$FIND_USER" ]; then
            echo -e "${RED}UNABLE TO LOCATE USER IN PSQL.$NC"
        else
            echo -e "${GREEN}SUCCESS! USER LOCATED."
            echo -e "${NC}THE PASSWORD HASH FOR $YELLOW$USERNAME_IN_DB$NC IS $YELLOW$PASSWORD_HASH_IN_DB$NC"
            if [ -n "$(echo $FIND_USER | cut -d ',' -f3)" ]; then
                echo -e "${RED}LOCKOUT END:$NC $(echo $FIND_USER | cut -d ',' -f3 | awk -F'[ .+]' '{split($1, d, "-"); split($2, t, ":"); printf "%s-%s-%s at %s:%s:%s UTC\n", d[3], d[2], d[1], t[1], t[2], t[3]}')"
            fi
            echo -e "${RED}FAILED LOGIN COUNT:$NC $(echo $FIND_USER | cut -d ',' -f4)"
            break
        fi
    done

    #--------------------------------------------------------------------------------------------------------------------------------
    # update password

    CHOOSE_PASSWORD
    echo -e "THE PASSWORD FOR $YELLOW$USERNAME_IN_DB$NC WILL BE SET TO: $BLUE$PASSWORD_RAW$NC"

    REQUEST_USER_INPUT "WOULD YOU LIKE TO CONTINUE (Y/N)?      " "2"
    if [ "$PROCEED" = true ]; then
        echo -e "UPDATING PASSWORD..."
        UPDATE_PASSWORD_QUERY="UPDATE \"AspNetUsers\" SET \"AccessFailedCount\" = 0, \"LockoutEnd\" = NULL, \"PasswordHash\" = '$PASSWORD_HASH' WHERE \"UserName\" = '$USERNAME';"
        UPDATE_PASSWORD=$(RUN_QUERY "$UPDATE_PASSWORD_QUERY")
    else
        echo -e "${RED}OPERATION CANCELLED BY USER. PASSWORD WAS NOT CHANGED.$NC"
        exit 1 >&/dev/null
    fi

    echo -e "DONE. VERIFYING CHANGE..."
    sleep 2
    FIND_USER=$(RUN_QUERY "$FIND_USER_QUERY")
    PASSWORD_HASH_IN_DB=$(echo $FIND_USER | cut -d ',' -f2)

    if [[ "$PASSWORD_HASH_IN_DB" == "$PASSWORD_HASH" ]]; then
        echo -e "${GREEN}SUCCESS! PASSWORD UPDATED."
        echo -e "$NC"
    else
        echo -e "${RED}PASSWORD HASH FAILED TO UPDATE.$NC"
    fi
else
    echo -e "${RED}THIS SCRIPT MUST BE RUN AS ROOT.$NC MAKE SURE TO GO SUPERUSER (su) BEFORE RUNNING THIS SCRIPT."
fi

exit 1 >&/dev/null