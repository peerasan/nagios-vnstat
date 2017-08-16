#!/bin/sh

# Check Bandwidth, with vnstat (by Nestor@Toronto)
# Credit by Nestor@Toronto (https://exchange.nagios.org/directory/Plugins/Network-and-Systems-Management/Check-Bandwidth,-with-vnstat-(by-Nestor@Toronto)/details)
# 
# Fork by Patrickz


# Version 2.2

if [ "$1" = "-w" ] && [ "$2" -gt "0" ] && [ "$3" = "-c" ] && [ "$4" -gt "0" ] && [ "$5" != "" ] ; then

	warn=$2
	crit=$4
	NIC=$5 
	vn_value=$(vnstat -tr 2 -i $NIC) || exit 3 # We collect bandwidth for 2 second
	rx_value=$(echo "$vn_value"|grep rx|awk {'print $2'}|cut -d. -f1) 
	rx_unit=$(echo "$vn_value"|grep rx|awk {'print $3'}|cut -d. -f1)
	tx_value=$(echo "$vn_value"|grep tx|awk {'print $2'}|cut -d. -f1) 
	tx_unit=$(echo "$vn_value"|grep tx|awk {'print $3'}|cut -d. -f1)

	# Exit if its using byte
	echo $vn_value|grep 'iB'&&echo "##### Please configure /etc/vnstat.conf to display in bit #####"&&exit 3

	#recalculate rx_value and tx_value, depending on the unit in rx_unit and tx_unit
	#first for rx
	if [ $rx_unit == "Mbit/s" ] 
		then rx_value_recal=$((rx_value*1024/8))
		else rx_value_recal=$((rx_value/8))
	fi	
	#...then also for tx
	if [ $tx_unit == "Mbit/s" ]
	then tx_value_recal=$((tx_value*1024/8)) 
	else tx_value_recal=$((tx_value/8)) 
	fi
	
	status="$rx_value_recal $tx_value_recal"
	if [ $warn -lt $rx_value_recal -o $warn -lt $tx_value_recal ];then
		if [ $crit -lt $rx_value_recal -o $crit -lt $tx_value_recal ]; then
		echo "NIC $NIC Status: CRITICAL - rx: $rx_value_recal KBps - tx: $tx_value_recal KBps|Rx(KBps)=$rx_value_recal;;;; Tx(KBps)=$tx_value_recal;;;;"
		exit 2
	else
		echo "NIC $NIC Status: WARNING - rx: $rx_value_recal KBps - tx: $tx_value_recal KBps|Rx(KBps)=$rx_value_recal;;;; Tx(KBps)=$tx_value_recal;;;;"
		exit 1
	fi

else
	echo "NIC $NIC Status: OK - rx: $rx_value_recal KBps - tx: $tx_value_recal KBps|Rx(KBps)=$rx_value_recal;;;; Tx(KBps)=$tx_value_recal;;;;"
	exit 0
fi
else
        echo "check_bandwidth.sh - Nagios Plugin for checking host bandwidth "
        echo ""
        echo "Usage:	check_bandwidth.sh -w <warnlevel> -c <critlevel> <NIC>"
        echo "	= warnlevel and critlevel is bandwidth in KBps"
        echo "
        echo "EXAMPLE:  /usr/lib64/nagios/plugins/check_bandwidth.sh -w 900 -c 950 eth1 
	echo "	= Send warning when more than 900 KBps, critical when more than 950 KBps"
        echo ""
        exit
fi
