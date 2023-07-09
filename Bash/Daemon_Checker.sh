#!/bin/bash
###########################################
# FILENAME: Daemon_Checker.sh
# CREATOR: AALEEM SIDDIQUI
# DESCRIPTION: Checks daemons and software version on a specific terminal
###########################################


echo -e "\n     \e[44;1mDaemon Checker\e[0m" 
echo -e "\n\e[43;1mSoftware Version:\e[0m \c"
cd /home/genericcompanyname/software
./software -v
echo -e "\n----------------------------------------------"
echo -e "\e[96m"
/etc/rc.d/init.d/crond status
echo -e "\e[0m \e[97m"
/etc/rc.d/init.d/dhcpd status
echo -e "\e[0m \e[91m"
/etc/rc.d/init.d/httpd status
echo -e "\e[0m \e[92m"
/etc/rc.d/init.d/mysqld status
echo -e "\e[0m \e[93m"
/etc/rc.d/init.d/generic_daemon_name_1 status
echo -e "\e[0m \e[94m"
/etc/rc.d/init.d/generic_daemon_name_2 status
echo -e "\e[0m \e[95m"
/etc/rc.d/init.d/generic_daemon_name_3 status
echo -e "\e[0m \e[96m"
/etc/rc.d/init.d/generic_daemon_name_4 status
echo -e "\e[0m \e[97m"
/etc/rc.d/init.d/generic_daemon_name_5 status
echo -e "\e[0m \e[91m"
/etc/rc.d/init.d/generic_daemon_name_6 status
echo -e "\e[0m \e[93m"
/etc/rc.d/init.d/syslog status
echo -e "\e[0m"
