#!/bin/bash
###########################################
# FILENAME: linuxDeviceStatus.sh
# CREATOR: AALEEM SIDDIQUI
# DESCRIPTION: Performs a status check for DEVICE gateways
###########################################

ORANGE='\033[0;33m';CYAN='\033[1;36m';RED='\033[1;31m';GREEN='\033[1;32m';YELLOW='\033[1;33m';BLUE='\033[1;34m';PURPLE='\033[1;35m';NC='\033[0m'
LINE='--------------------'
LONG_LINE="$BLUE$LINE$LINE$LINE$NC"
HEADER() {
  local HEADER_NAME=$1
  echo -e "\n\n\n$LONG_LINE\n\t\t$HEADER_NAME\n$LONG_LINE\n\n"
}

#--------------------------------------------------------------------------------------------------------------------------------
# variables

CURRENT_DATE_TIME=$(date +"%m-%d-%Y %I:%M:%S %p %Z")
BOOT_TIME=$(date -d "$(who -b | awk '{print $3 " " $4}')" +%s)
NOW=$(date +%s)
TIME_DIFF=$(( NOW - BOOT_TIME ))
UPTIME_HOURS=$(( TIME_DIFF / 3600 ))
UPTIME_MINUTES=$(( (TIME_DIFF % 3600) / 60 ))
SERIAL_NUMBER=$(grep -i "perseus" /var/cache/debconf/config.dat | cut -d '-' -f2)
CONFIG_JSON_PATH="/opt/company/i100/microservice_1/config.json"
REGION=$(sudo jq -r '.mqtt_payload.region' $CONFIG_JSON_PATH)
TENANT_NAME=$(sudo jq -r '.mqtt_payload.tenant_name' $CONFIG_JSON_PATH)
microservice_1_WIZARD_STATE=$(sudo jq -r '.wizard_state' $CONFIG_JSON_PATH)
VERSION_PATH="/var/lib/dpkg/status"
SOFTWARE_VERSION=$(cat $VERSION_PATH | grep -i -A10 "Package: company-software" | grep -i "version" | cut -d ' ' -f2)
microservice_1_VERSION=$(cat $VERSION_PATH | grep -i -A10 "Package: company-microservice_1" | grep -i "version" | cut -d ' ' -f2)
microservice_2_VERSION=$(cat $VERSION_PATH | grep -i -A10 "Package: company-microservice_2" | grep -i "version" | cut -d ' ' -f2)
microservice_3_VERSION=$(cat $VERSION_PATH | grep -i -A10 "Package: company-microservice_3" | grep -i "version" | cut -d ' ' -f2)
LICENSEGATEWAY_VERSION=$(cat $VERSION_PATH | grep -i -A10 "Package: companylicensegateway" | grep -i "version" | cut -d ' ' -f2)
OS_VERSION=$(cat /Version.txt)
ETHERNET_CONNECTIONS=$(nmcli | awk '/^eth[0-9]+: connected to/ {show=1; print; next} /^[a-z0-9\-]+: / {show=0} show {print}')
PING_ENDPOINTS=(
    "mqtt.e-us.software.cloud:INTERNET CONNECTIVITY"
    "yahoo.com:DNS"
)
FIREWALL_ENDPOINTS=(
    "mqtt.e-us.software.cloud:8883"
    "mqtt.w-eu.software.cloud:8883"
    "c-us-prod-iothub.azure-devices.net:8883"
)
TELNET_LOG="/tmp/telnet_output.txt"
INDEX=1
PASS_COUNT=0
TOTAL=${#FIREWALL_ENDPOINTS[@]}
RESOLVE_CONF="$(grep -v '^\s*#' /etc/resolv.conf)"
DEVICE_CERTIFICATES_PATH="/etc/ssl/certificates"
LIST_DEVICE_CERTIFICATE_DIR=$(ls -Al ${DEVICE_CERTIFICATES_PATH} | awk '{print $6, $7, $9}')
BIRTH_CERTIFICATES=(
    "birth-certificate.ca"
    "birth-certificate.key"
    "birth-certificate.pem"
    "software-instance.ca"
)
SOFTWARE_INSTANCE_CERTIFICATES=(
    "software-instance.ca"
    "software-instance.csr"
    "software-instance.key"
    "software-instance.pem"
)
CSR_FILE="$DEVICE_CERTIFICATES_PATH/software-instance.csr"
KEY_FILE="$DEVICE_CERTIFICATES_PATH/software-instance.key"
PEM_FILE="$DEVICE_CERTIFICATES_PATH/software-instance.pem"

#--------------------------------------------------------------------------------------------------------------------------------
# functions

PING_CHECK() {
    local HOST=$1
    local DESCRIPTION=$2
    
    echo -e "PINGING $ORANGE${HOST}$NC TO CHECK ${DESCRIPTION}...${NC}"
    ping -c 1 "$HOST" > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo -e "PING SUCCESSFUL.${NC}"
        if [ "$DESCRIPTION" == "INTERNET CONNECTIVITY" ]; then
            echo -e "${GREEN}THE DEVICE HAS INTERNET.\n${NC}"
        else
            echo -e "${GREEN}DNS LOOKUPS ARE RESOLVING NAMES CORRECTLY.${NC}"
        fi
    else
        echo -e "${RED}PING FAILED.${NC}"
        if [ "$DESCRIPTION" == "INTERNET CONNECTIVITY" ]; then
            echo -e "${RED}YOU DO NOT HAVE INTERNET ON YOUR DEVICE.${NC}"
            echo -e "${YELLOW}RESOLUTION STEPS:"
            echo -e "\t- CHECK ETH 1 GATEWAY IP (IF THERE IS ONE POPULATED THEN REMOVE IT.)"
            echo -e "\t- A GATEWAY IP POPULATED IN ETH 1 CAN PREVENT INTERNET FROM BEING CONNECTED ON THE DEVICE.\n\n${NC}"
        else
            echo -e "${YELLOW}RESOLUTION STEPS:"
            echo -e "\t- THERE SEEMS TO BE SOMETHING WRONG WITH YOUR DNS SETTINGS."
            echo -e "\t- PLEASE CHECK ETH 2 DNS."
            echo -e "DNS CONFIGURATION INSIDE /etc/resolv.conf:$NC\n${RESOLVE_CONF}${NC}"
        fi
    fi
}

#--------------------------------------------------------

TELNET_CHECK() {
    local HOST=$1
    local PORT=$2

    timeout 10 telnet "$HOST" "$PORT" <<EOF > "$TELNET_LOG" 2>&1
quit
EOF

    if grep -q "Connected to" "$TELNET_LOG"; then
        echo -e "${GREEN}TELNET SUCCESSFUL.${NC}"
        return 0
    else
        echo -e "${RED}TELNET FAILED.${NC}"
        echo -e "${YELLOW}RESOLUTION STEPS:"
        echo -e "\t- PLEASE CHECK IF THE $HOST ENDPOINT USING PORT $PORT ARE OPEN AND REACHABLE FROM THIS DEVICE.${NC}"
        return 1
    fi
}

#--------------------------------------------------------

CHECK_CERTIFICATES_EXIST() {
  local CERT_ARRAY_NAME="$1"
  local FOUND_VAR_NAME="$2"
  local ALL_CERTIFICATES_FOUND=true
  local CERTIFICATE_ARRAY_LENGTH
  eval "CERTIFICATE_ARRAY_LENGTH=\${#${CERT_ARRAY_NAME}[@]}"

  for (( i=0; i<CERTIFICATE_ARRAY_LENGTH; i++ )); do
    eval "CERTIFICATE=\${${CERT_ARRAY_NAME}[i]}"
    if [ ! -f "$DEVICE_CERTIFICATES_PATH/$CERTIFICATE" ]; then
      echo -e "$RED$CERTIFICATE MISSING!$NC"
      ALL_CERTIFICATES_FOUND=false
    fi
  done

  eval "$FOUND_VAR_NAME=$ALL_CERTIFICATES_FOUND"
}

#--------------------------------------------------------

CHECK_CERTIFICATE_CONTENT() {
  echo -e "\nVERIFYING SOFTWARECERTIFICATE CONTENTS MATCH..."
  CONTENT_CSR=$(openssl req -inform DER -noout -modulus -in "$CSR_FILE" 2>/dev/null | openssl md5)
  CONTENT_KEY=$(openssl rsa -noout -modulus -in "$KEY_FILE" 2>/dev/null | openssl md5)
  CONTENT_PEM=$(openssl x509 -noout -modulus -in "$PEM_FILE" 2>/dev/null | openssl md5)

  if [ "$CONTENT_CSR" = "$CONTENT_KEY" ] && [ "$CONTENT_KEY" = "$CONTENT_PEM" ]; then
    echo -e "${GREEN}SOFTWAREINSTANCE CSR, KEY, AND PEM CONTENTS MATCH.${NC}"
  else
    echo -e "${RED}SOFTWAREINSTANCE CERTIFICATE CONTENT MISMATCH DETECTED!${NC}"
    echo -e "CSR CONTENT: $CONTENT_CSR"
    echo -e "KEY CONTENT: $CONTENT_KEY"
    echo -e "PEM CONTENT: $CONTENT_PEM"
  fi
}

#--------------------------------------------------------

CHECK_BIRTH_CERTIFICATE_DATES() {
  echo -e "\nCHECKING FACTORY-INSTALLED CERTIFICATE DATES..."

  DEVICE_BIRTH_REFERENCE_DATE=$(stat -c %y "$DEVICE_CERTIFICATES_PATH/${BIRTH_CERTIFICATES[0]}" | cut -d' ' -f1)
  BIRTH_CERT_DATES_MATCH=true

  for CERTIFICATE in "${BIRTH_CERTIFICATES[@]}"; do
    DEVICE_BIRTH_MODIFIED_DATE=$(stat -c %y "$DEVICE_CERTIFICATES_PATH/$CERTIFICATE" | cut -d' ' -f1)
    if [ "$DEVICE_BIRTH_MODIFIED_DATE" != "$DEVICE_BIRTH_REFERENCE_DATE" ]; then
      echo -e "${YELLOW}WARNING (DATE MISMATCH):$NC $CERTIFICATE HAS DATE $YELLOW$DEVICE_BIRTH_MODIFIED_DATE$NC, EXPECTED $GREEN$DEVICE_BIRTH_REFERENCE_DATE$NC"
      BIRTH_CERT_DATES_MATCH=false
    fi
  done

  if [ "$BIRTH_CERT_DATES_MATCH" = true ]; then
    echo -e "${GREEN}ALL FACTORY-INSTALLED CERTIFICATE MODIFICATION DATES MATCH: $DEVICE_BIRTH_REFERENCE_DATE${NC}"
  fi
}

#--------------------------------------------------------------------------------------------------------------------------------
# SCRIPT START

clear
echo -e "\n\t$BLUE+$LINE+\n\t|$NC   GATEWAY STATUS   $BLUE|\n\t+$LINE+$NC\n\n"
echo -e "${PURPLE}CURRENT DATE AND TIME:$NC $CURRENT_DATE_TIME"
echo -e "${PURPLE}UPTIME:$NC $UPTIME_HOURS HOURS AND $UPTIME_MINUTES MINUTES"
echo -e "${PURPLE}SERIAL NUMBER:$NC $SERIAL_NUMBER"
if [[ "$TENANT_NAME" != "null" || "$REGION" != "null" ]]; then
  echo -e "${PURPLE}TENANT NAME:$NC $TENANT_NAME"
  echo -e "${PURPLE}REGION:$NC $REGION"
  IS_ONBOARDED="true"
fi
echo -e "${PURPLE}microservice_1 WIZARD STATE:$NC $microservice_1_WIZARD_STATE"
echo -e "\n${PURPLE}microservice_1 VERSION:$NC $microservice_1_VERSION"
echo -e "${PURPLE}SOFTWAREVERSION:$NC $SOFTWARE_VERSION"
echo -e "${PURPLE}microservice_2 VERSION:$NC $microservice_2_VERSION"
echo -e "${PURPLE}microservice_3 VERSION:$NC $microservice_3_VERSION"
echo -e "${PURPLE}microservice_4 VERSION:$NC $LICENSEGATEWAY_VERSION"
echo -e "${PURPLE}OS VERSION:$NC $OS_VERSION\n"
echo -e "${PURPLE}ETHERNET CONNECTIONS:$NC"
for ETH_PORT in eth{0..3}; do
    IS_DETECTED=$(sudo ethtool "$ETH_PORT" 2>/dev/null | grep -i 'link detected')
    if echo "$IS_DETECTED" | grep -qi 'yes'; then
        IP_NEIGHBOR=$(ip neighbor | grep -i "$ETH_PORT" | awk '{print $1, $5, $NF}')
        echo -e "\t$ETH_PORT: [ ${GREEN}LINK DETECTED$NC ]"
        echo "$IP_NEIGHBOR" | while IFS= read -r IP_NEIGHBOR_LINE; do
          echo -e "\t\t$IP_NEIGHBOR_LINE"
        done
    else
        echo -e "\t$ETH_PORT: [ ${RED}PORT EMPTY$NC ]"
    fi
done

if [[ -z $IS_ONBOARDED ]]; then
  echo -e "\n\n${RED}TENANT NAME AND REGION NOT FOUND IN CONFIG.JSON\n${YELLOW}WARNING: THIS DEVICE MAY NOT BE ONBOARDED TO THE CLOUD YET.${NC}"
else
  echo -e "\n$ETHERNET_CONNECTIONS"
fi

echo -e "\n${PURPLE}DISK SPACE:$NC"
df -h --output=source,pcent | grep '^/dev/' | while read -r line; do
    PARTITION=$(echo "$line" | awk '{print $1}')
    USAGE_PCENT=$(echo "$line" | awk '{print $2}' | tr -d '%')
    if [ "$USAGE_PCENT" -le 50 ]; then
        PCENT_COLOR=$GREEN
    elif [ "$USAGE_PCENT" -le 80 ]; then
        PCENT_COLOR=$YELLOW
    else
        PCENT_COLOR=$RED
    fi
    echo -e "$PARTITION: $PCENT_COLOR$USAGE_PCENT %$NC"
done

#--------------------------------------------------------------------------------------------------------------------------------
# CHECK INTERNET CONNECTIVITY + DNS

HEADER "INTERNET CONNECTIVITY"
for entry in "${PING_ENDPOINTS[@]}"; do
    IFS=":" read -r HOST DESCRIPTION <<< "$entry"
    PING_CHECK "$HOST" "$DESCRIPTION"
done

#--------------------------------------------------------------------------------------------------------------------------------
# CHECK FW

HEADER "      FIREWALL"
echo -e "TESTING LOCAL NETWORK FIREWALL RULES..."
for entry in "${FIREWALL_ENDPOINTS[@]}"; do
    IFS=":" read -r HOST PORT <<< "$entry"
    echo -e "[$INDEX/$TOTAL] - TELNETTING $ORANGE$HOST$NC ON PORT $ORANGE$PORT$NC..."
    if TELNET_CHECK "$HOST" "$PORT"; then
        ((PASS_COUNT++))
    fi
    ((INDEX++))
done

if [ "$PASS_COUNT" -eq "$TOTAL" ]; then
    echo -e "\n${GREEN}ALL $TOTAL FIREWALL CHECKS PASSED.${NC}"
else
    echo -e "\n${RED}$PASS_COUNT/$TOTAL CHECKS PASSED.\nNOT ALL ENDPOINTS ARE ACCESSIBLE.${NC}"
fi

rm -f "$TELNET_LOG"

#--------------------------------------------------------------------------------------------------------------------------------
# CHECK SSL CERTIFICATES

HEADER "SSL CERTIFICATES"
echo -e "CHECKING DEVICE SSL CERTIFICATES..."
echo -e "$LIST_DEVICE_CERTIFICATE_DIR\n"

ALL_BIRTH_CERTS_FOUND=true
ALL_SOFTWARE_CERTS_FOUND=true

CHECK_CERTIFICATES_EXIST "BIRTH_CERTIFICATES" "ALL_BIRTH_CERTS_FOUND"

if [ "${#SOFTWARE_INSTANCE_CERTIFICATES[@]}" -gt 0 ]; then
  CHECK_CERTIFICATES_EXIST "SOFTWARE_INSTANCE_CERTIFICATES" "ALL_SOFTWARE_CERTS_FOUND"
else
  ALL_SOFTWARE_CERTS_FOUND=false
fi

if [ "$ALL_BIRTH_CERTS_FOUND" = true ] && [ "$ALL_SOFTWARE_CERTS_FOUND" = true ]; then
  echo -e "${GREEN}ALL CERTIFICATES FOUND.${NC}"
elif [ "$ALL_BIRTH_CERTS_FOUND" = true ]; then
  echo -e "${YELLOW}\nONLY FACTORY-INSTALLED CERTIFICATES FOUND.\nWARNING: THIS DEVICE MAY NOT BE ONBOARDED TO THE CLOUD YET.${NC}"
else
  echo -e "${RED}THERE ARE MISSING FACTORY-INSTALLED CERTIFICATES. THESE NEED TO BE IN PLACE BEFORE THE DEVICE CAN BE ONBOARDED TO THE CLOUD.${NC}" 
fi

if [ "$ALL_BIRTH_CERTS_FOUND" = true ]; then
    CHECK_BIRTH_CERTIFICATE_DATES
fi

if [ "$ALL_SOFTWARE_CERTS_FOUND" = true ]; then
    CHECK_CERTIFICATE_CONTENT
fi

echo -e "${GREEN}\n\n\n\nSCRIPT COMPLETE.${NC}"
exit 1


#--------------------------------------------------------------------------------------------------------------------------------
# same code but in one line
ORANGE='\033[0;33m';CYAN='\033[1;36m';RED='\033[1;31m';GREEN='\033[1;32m';YELLOW='\033[1;33m';BLUE='\033[1;34m';PURPLE='\033[1;35m';NC='\033[0m';LINE='--------------------';LONG_LINE="$BLUE$LINE$LINE$LINE$NC";HEADER(){ local HEADER_NAME=$1; echo -e "\n\n\n$LONG_LINE\n\t\t$HEADER_NAME\n$LONG_LINE\n\n"; };CURRENT_DATE_TIME=$(date +"%m-%d-%Y %I:%M:%S %p %Z");BOOT_TIME=$(date -d "$(who -b | awk '{print $3 " " $4}')" +%s);NOW=$(date +%s);TIME_DIFF=$(( NOW - BOOT_TIME ));UPTIME_HOURS=$(( TIME_DIFF / 3600 ));UPTIME_MINUTES=$(( (TIME_DIFF % 3600) / 60 ));SERIAL_NUMBER=$(grep -i "perseus" /var/cache/debconf/config.dat | cut -d '-' -f2); CONFIG_JSON_PATH="/opt/company/i100/microservice_1/config.json"; REGION=$(sudo jq -r '.mqtt_payload.region' $CONFIG_JSON_PATH); TENANT_NAME=$(sudo jq -r '.mqtt_payload.tenant_name' $CONFIG_JSON_PATH); microservice_1_WIZARD_STATE=$(sudo jq -r '.wizard_state' $CONFIG_JSON_PATH); VERSION_PATH="/var/lib/dpkg/status"; SOFTWARE_VERSION=$(grep -i -A10 "Package: company-software" $VERSION_PATH | grep -i "version" | cut -d ' ' -f2); microservice_1_VERSION=$(grep -i -A10 "Package: company-microservice_1" $VERSION_PATH | grep -i "version" | cut -d ' ' -f2); microservice_2_VERSION=$(grep -i -A10 "Package: company-microservice_2" $VERSION_PATH | grep -i "version" | cut -d ' ' -f2); microservice_3_VERSION=$(grep -i -A10 "Package: company-microservice_3" $VERSION_PATH | grep -i "version" | cut -d ' ' -f2); LICENSEGATEWAY_VERSION=$(grep -i -A10 "Package: companylicensegateway" $VERSION_PATH | grep -i "version" | cut -d ' ' -f2); OS_VERSION=$(cat /Version.txt);ETHERNET_CONNECTIONS=$(nmcli | awk '/^eth[0-9]+: connected to/ {show=1; print; next} /^[a-z0-9\-]+: / {show=0} show {print}');PING_ENDPOINTS=("mqtt.e-us.software.cloud:INTERNET CONNECTIVITY" "yahoo.com:DNS");FIREWALL_ENDPOINTS=("mqtt.e-us.software.cloud:8883" "mqtt.moon-w-eu.software.cloud:8883" "rc-c-us-prod-iothub.azure-devices.net:8883");TELNET_LOG="/tmp/telnet_output.txt";INDEX=1;PASS_COUNT=0;TOTAL=${#FIREWALL_ENDPOINTS[@]};RESOLVE_CONF="$(grep -v '^\s*#' /etc/resolv.conf)";DEVICE_CERTIFICATES_PATH="/etc/ssl/certificates";LIST_DEVICE_CERTIFICATE_DIR=$(ls -Al ${DEVICE_CERTIFICATES_PATH} | awk '{print $6, $7, $9}');BIRTH_CERTIFICATES=("birth-certificate.ca" "birth-certificate.key" "birth-certificate.pem" "software-instance.ca");SOFTWARE_INSTANCE_CERTIFICATES=("software-instance.ca" "software-instance.csr" "software-instance.key" "software-instance.pem");CSR_FILE="$DEVICE_CERTIFICATES_PATH/software-instance.csr";KEY_FILE="$DEVICE_CERTIFICATES_PATH/software-instance.key";PEM_FILE="$DEVICE_CERTIFICATES_PATH/software-instance.pem";PING_CHECK(){ local HOST=$1; local DESCRIPTION=$2; echo -e "PINGING $ORANGE${HOST}$NC TO CHECK ${DESCRIPTION}...${NC}"; ping -c 1 "$HOST" > /dev/null 2>&1; if [ $? -eq 0 ]; then echo -e "PING SUCCESSFUL.${NC}"; if [ "$DESCRIPTION" == "INTERNET CONNECTIVITY" ]; then echo -e "${GREEN}THE DEVICE HAS INTERNET.\n${NC}"; else echo -e "${GREEN}DNS LOOKUPS ARE RESOLVING NAMES CORRECTLY.${NC}"; fi; else echo -e "${RED}PING FAILED.${NC}"; if [ "$DESCRIPTION" == "INTERNET CONNECTIVITY" ]; then echo -e "${RED}YOU DO NOT HAVE INTERNET ON YOUR DEVICE.${NC}"; echo -e "${YELLOW}RESOLUTION STEPS:"; echo -e "\t- CHECK ETH 1 GATEWAY IP (IF THERE IS ONE POPULATED THEN REMOVE IT.)"; echo -e "\t- A GATEWAY IP POPULATED IN ETH 1 CAN PREVENT INTERNET FROM BEING CONNECTED ON THE DEVICE.\n\n${NC}"; else echo -e "${YELLOW}RESOLUTION STEPS:"; echo -e "\t- THERE SEEMS TO BE SOMETHING WRONG WITH YOUR DNS SETTINGS."; echo -e "\t- PLEASE CHECK ETH 2 DNS."; echo -e "DNS CONFIGURATION INSIDE /etc/resolv.conf:$NC\n${RESOLVE_CONF}${NC}"; fi; fi; };TELNET_CHECK(){ local HOST=$1; local PORT=$2; if timeout 5 bash -c "echo > /dev/tcp/$HOST/$PORT" 2>/dev/null; then echo -e "${GREEN}TELNET SUCCESSFUL.${NC}"; return 0; else echo -e "${RED}TELNET FAILED.${NC}"; echo -e "${YELLOW}RESOLUTION STEPS:"; echo -e "\t- PLEASE CHECK IF THE $HOST ENDPOINT USING PORT $PORT IS OPEN AND REACHABLE FROM THIS DEVICE.${NC}"; return 1; fi; };CHECK_CERTIFICATES_EXIST(){ local CERT_ARRAY_NAME="$1"; local FOUND_VAR_NAME="$2"; local ALL_CERTIFICATES_FOUND=true; local CERTIFICATE_ARRAY_LENGTH; eval "CERTIFICATE_ARRAY_LENGTH=\${#${CERT_ARRAY_NAME}[@]}"; for (( i=0; i<CERTIFICATE_ARRAY_LENGTH; i++ )); do eval "CERTIFICATE=\${${CERT_ARRAY_NAME}[i]}"; if [ ! -f "$DEVICE_CERTIFICATES_PATH/$CERTIFICATE" ]; then echo -e "$RED$CERTIFICATE MISSING$NC"; ALL_CERTIFICATES_FOUND=false; fi; done; eval "$FOUND_VAR_NAME=$ALL_CERTIFICATES_FOUND"; };CHECK_CERTIFICATE_CONTENT(){ echo -e "\nVERIFYING SOFTWARECERTIFICATE CONTENTS MATCH..."; CONTENT_CSR=$(openssl req -inform DER -noout -modulus -in "$CSR_FILE" 2>/dev/null | openssl md5); CONTENT_KEY=$(openssl rsa -noout -modulus -in "$KEY_FILE" 2>/dev/null | openssl md5); CONTENT_PEM=$(openssl x509 -noout -modulus -in "$PEM_FILE" 2>/dev/null | openssl md5); if [ "$CONTENT_CSR" = "$CONTENT_KEY" ] && [ "$CONTENT_KEY" = "$CONTENT_PEM" ]; then echo -e "${GREEN}SOFTWAREINSTANCE CSR, KEY, AND PEM CONTENTS MATCH.${NC}"; else echo -e "${RED}SOFTWAREINSTANCE CERTIFICATE CONTENT MISMATCH DETECTED$NC"; echo -e "CSR CONTENT: $CONTENT_CSR"; echo -e "KEY CONTENT: $CONTENT_KEY"; echo -e "PEM CONTENT: $CONTENT_PEM"; fi; };CHECK_BIRTH_CERTIFICATE_DATES(){ echo -e "\nCHECKING FACTORY-INSTALLED CERTIFICATE DATES..."; DEVICE_BIRTH_REFERENCE_DATE=$(stat -c %y "$DEVICE_CERTIFICATES_PATH/${BIRTH_CERTIFICATES[0]}" | cut -d' ' -f1); BIRTH_CERT_DATES_MATCH=true; for CERTIFICATE in "${BIRTH_CERTIFICATES[@]}"; do DEVICE_BIRTH_MODIFIED_DATE=$(stat -c %y "$DEVICE_CERTIFICATES_PATH/$CERTIFICATE" | cut -d' ' -f1); if [ "$DEVICE_BIRTH_MODIFIED_DATE" != "$DEVICE_BIRTH_REFERENCE_DATE" ]; then echo -e "${YELLOW}WARNING (DATE MISMATCH):$NC $CERTIFICATE HAS DATE $YELLOW$DEVICE_BIRTH_MODIFIED_DATE$NC, EXPECTED $GREEN$DEVICE_BIRTH_REFERENCE_DATE$NC"; BIRTH_CERT_DATES_MATCH=false; fi; done; if [ "$BIRTH_CERT_DATES_MATCH" = true ]; then echo -e "${GREEN}ALL BIRTH CERTIFICATE MODIFICATION DATES MATCH: $DEVICE_BIRTH_REFERENCE_DATE${NC}"; fi; };clear;echo -e "\n\t$BLUE+$LINE+\n\t|$NC   GATEWAY STATUS   $BLUE|\n\t+$LINE+$NC\n\n"; echo -e "${PURPLE}CURRENT DATE AND TIME:$NC $CURRENT_DATE_TIME"; echo -e "${PURPLE}UPTIME:$NC $UPTIME_HOURS HOURS AND $UPTIME_MINUTES MINUTES"; echo -e "${PURPLE}SERIAL NUMBER:$NC $SERIAL_NUMBER"; [[ "$TENANT_NAME" != "null" || "$REGION" != "null" ]] && { echo -e "${PURPLE}TENANT NAME:$NC $TENANT_NAME"; echo -e "${PURPLE}REGION:$NC $REGION"; IS_ONBOARDED="true"; };echo -e "${PURPLE}microservice_1 WIZARD STATE:$NC $microservice_1_WIZARD_STATE"; echo -e "\n${PURPLE}microservice_1 VERSION:$NC $microservice_1_VERSION"; echo -e "${PURPLE}SOFTWAREVERSION:$NC $SOFTWARE_VERSION"; echo -e "${PURPLE}microservice_2 VERSION:$NC $microservice_2_VERSION"; echo -e "${PURPLE}microservice_3 VERSION:$NC $microservice_3_VERSION"; echo -e "${PURPLE}microservice_4 VERSION:$NC $LICENSEGATEWAY_VERSION"; echo -e "${PURPLE}OS VERSION:$NC $OS_VERSION\n\n${PURPLE}ETHERNET CONNECTIONS:$NC"; for ETH_PORT in eth{0..3}; do IS_DETECTED=$(sudo ethtool "$ETH_PORT" 2>/dev/null | grep -i 'link detected'); if echo "$IS_DETECTED" | grep -qi 'yes'; then IP_NEIGHBOR=$(ip neighbor | grep -i "$ETH_PORT" | awk '{print $1, $5, $NF}'); echo -e "\t$ETH_PORT: [ ${GREEN}LINK DETECTED$NC ]"; echo "$IP_NEIGHBOR" | while IFS= read -r IP_NEIGHBOR_LINE; do echo -e "\t\t$IP_NEIGHBOR_LINE"; done; else echo -e "\t$ETH_PORT: [ ${RED}PORT EMPTY$NC ]"; fi; done; [[ -z $IS_ONBOARDED ]] && echo -e "\n\n${RED}TENANT NAME AND REGION NOT FOUND IN CONFIG.JSON\n${YELLOW}WARNING: THIS DEVICE MAY NOT BE ONBOARDED TO THE CLOUD YET.${NC}" || echo -e "\n$ETHERNET_CONNECTIONS"; echo -e "\n${PURPLE}DISK SPACE:${NC}"; df -h --output=source,pcent | grep '^/dev/' | while read -r line; do PART=$(echo $line | awk '{print $1}'); USE=$(echo $line | awk '{print $2}' | tr -d '%'); [ "$USE" -le 50 ] && COLOR=$GREEN || ([ "$USE" -le 80 ] && COLOR=$YELLOW || COLOR=$RED); echo -e "$PART: ${COLOR}${USE} %${NC}"; done; HEADER "INTERNET CONNECTIVITY"; for entry in "${PING_ENDPOINTS[@]}"; do IFS=":" read -r HOST DESCRIPTION <<< "$entry"; PING_CHECK "$HOST" "$DESCRIPTION"; done; HEADER "      FIREWALL"; echo -e "TESTING LOCAL NETWORK FIREWALL RULES...\n"; for entry in "${FIREWALL_ENDPOINTS[@]}"; do IFS=":" read -r HOST PORT <<< "$entry"; echo -e "[$INDEX/$TOTAL] - TELNETTING $ORANGE$HOST$NC ON PORT $ORANGE$PORT$NC..."; if TELNET_CHECK "$HOST" "$PORT"; then ((PASS_COUNT++)); fi; ((INDEX++)); done; if [ "$PASS_COUNT" -eq "$TOTAL" ]; then echo -e "\n${GREEN}ALL $TOTAL FIREWALL CHECKS PASSED.${NC}"; else echo -e "\n${RED}$PASS_COUNT/$TOTAL CHECKS PASSED.\nNOT ALL ENDPOINTS ARE ACCESSIBLE.${NC}"; fi; rm -f "$TELNET_LOG"; HEADER "SSL CERTIFICATES"; echo -e "CHECKING DEVICE SSL CERTIFICATES..."; echo -e "$LIST_DEVICE_CERTIFICATE_DIR\n"; ALL_BIRTH_CERTS_FOUND=true; ALL_SOFTWARE_CERTS_FOUND=true; CHECK_CERTIFICATES_EXIST "BIRTH_CERTIFICATES" "ALL_BIRTH_CERTS_FOUND"; if [ "${#SOFTWARE_INSTANCE_CERTIFICATES[@]}" -gt 0 ]; then CHECK_CERTIFICATES_EXIST "SOFTWARE_INSTANCE_CERTIFICATES" "ALL_SOFTWARE_CERTS_FOUND"; else ALL_SOFTWARE_CERTS_FOUND=false; fi; if [ "$ALL_BIRTH_CERTS_FOUND" = true ] && [ "$ALL_SOFTWARE_CERTS_FOUND" = true ]; then echo -e "${GREEN}ALL CERTIFICATES FOUND.${NC}"; elif [ "$ALL_BIRTH_CERTS_FOUND" = true ]; then echo -e "${YELLOW}\nONLY FACTORY-INSTALLED CERTIFICATES FOUND.\nWARNING: THIS DEVICE MAY NOT BE ONBOARDED TO THE CLOUD YET.${NC}"; else echo -e "${RED}THERE ARE MISSING FACTORY-INSTALLED CERTIFICATES. THESE NEED TO BE IN PLACE BEFORE THE DEVICE CAN BE ONBOARDED TO THE CLOUD.${NC}"; fi; if [ "$ALL_BIRTH_CERTS_FOUND" = true ]; then CHECK_BIRTH_CERTIFICATE_DATES; fi; if [ "$ALL_SOFTWARE_CERTS_FOUND" = true ]; then CHECK_CERTIFICATE_CONTENT; fi;echo -e "$GREEN\n\n\n\nSCRIPT COMPLETE.$NC";
