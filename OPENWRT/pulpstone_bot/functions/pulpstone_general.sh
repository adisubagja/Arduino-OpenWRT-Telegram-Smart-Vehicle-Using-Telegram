#!/bin/sh
pulpstone_general=17-03-2018

source /root/pulpstone_bot/variables

case $1 in  
"network_traffic")
  ipad=$(grep internet_source /root/pulpstone_bot/pulpstone_bot.conf |awk -F"=" '{print $2}')
  RX=$(ifconfig $ipad | awk -F[\(\)] '/bytes/ {printf "%s",$2}' |sed -e 's/[\t ]//g;s/i//g')
  TX=$(ifconfig $ipad | awk -F[\(\)] '/bytes/ {printf "%s",$4}' |sed -e 's/[\t ]//g;s/i//g')
  MACH=$(cat /tmp/sysinfo/model)
  U=$(cut -d. -f1 /proc/uptime)
  D=$(expr $U / 60 / 60 / 24)
  H=$(expr $U / 60 / 60 % 24)
  M=$(expr $U / 60 % 60)
  S=$(expr $U % 60)
  U=$(printf "%dd, %02d:%02d:%02d" $D $H $M $S)
  echo -e "$MACH \nUptime $U \nDownload $RX \nUpload $TX"
  ;;
"temp")
  degree=$(echo $'\xc2\xb0'C)
  mydevice=$(grep my_device /root/pulpstone_bot/pulpstone_bot.conf |awk -F"=" '{print $2}')
  if [ "$mydevice" == "raspi" ];then
    temp="$(cat /sys/devices/virtual/thermal/thermal_zone0/temp)"
    temp=$(($temp/1000))   #raspi
	echo -e "Raspberry Pi Temperature: $temp$degree"
  elif [ "$mydevice" == "orangepizero" ];then
    temp="$(cat /sys/devices/virtual/thermal/thermal_zone0/temp)" #chaoscalmer-opiz
	echo -e "OrangePi Zero Temperature: $temp$degree"
  elif [ "$mydevice" == "nonsbc" ];then
    echo -e "not support" #nonsbc
  fi
  ;;
"myip")
  myip=$(curl ipecho.net/plain 2> /dev/null)
  echo -e "$myip"
  ;;
"3g_info")
  u3gf=$(grep 3g_info /root/pulpstone_bot/pulpstone_bot.conf |awk -F"=" '{print $2}')
  if [ "$u3gf" == "yes" ];then
    3ginfo 2> /dev/null > /tmp/3ginfotmp
 modem=$(grep Device /tmp/3ginfotmp | cut -d':' -f 2 | sed -e 's/^[ \t]*//' 2> /dev/null)
 contim=$(grep Connection /tmp/3ginfotmp | awk '{print $3,$4}' | sed 's/ //g' 2> /dev/null)
 txx=$(grep Transmitted /tmp/3ginfotmp | cut -d':' -f 2 | sed -e 's/^[ \t]*//' 2> /dev/null)
 opsel=$(grep Operator /tmp/3ginfotmp | cut -d':' -f 2 | sed -e 's/^[ \t]*//' 2> /dev/null)
 mosel=$(grep Operating /tmp/3ginfotmp | cut -d':' -f 2 | sed -e 's/^[ \t]*//' 2> /dev/null)
 sgsel=$(grep strength /tmp/3ginfotmp | cut -d':' -f 2 | sed -e 's/^[ \t]*//' 2> /dev/null)
 echo -e "Modem: $modem \nConnection Time: $contim \nMobile Data: $txx \nOperator: $opsel \nCellular Network: $mosel \nSignal Strength: $sgsel"
  else
    echo -e "Not use 3G/4G Info"
  fi
  ;;
"restart_bot")
  echo -e "Pulpstone Telegram BOT Restart"
  killall pulpstone_telegram_bot && /etc/init.d/pulpstone_telegram_bot start
  ;;
"bot_go_private")
  cd /root/pulpstone_bot
  sed -i -e 's/#*my_chat_id/my_chat_id/' variables
  echo -e "Pulpstone Telegram BOT go Private!"
  ;;
"bot_go_public")
  cd /root/pulpstone_bot
  sed -i -e 's/my_chat_id/#my_chat_id/' variables
  echo -e "Pulpstone Telegram BOT go Public!"
  ;;
"bot_status")
  status=$(cat /root/pulpstone_bot/variables |grep chat_id |awk -F "=" '{print $1}')
  if [ "$status" == "my_chat_id" ];then
	echo -e "Pulpstone Telegram BOT Private Mode"
  else
    echo -e "Pulpstone Telegram BOT Public Mode"
  fi	
  ;;
"bot")
  echo -e "Available /bot: \n\n/bot_status \n/bot_go_public \n/bot_go_private \n\nBack: /router"
  ;;
"about")
  echo -e "Pulpstone Telegram Bot \n\nLede_Openwrt_Telegram_Bot by filirnd \nAll Pulpstone Script by fuadsalim \nAll Arduino Command by dhimazroby \n\nModified for Vehicle Security System based Arduino & OpenWRT Edited by Dhimas Roby Satrio Nugroho\nAmikom Yogyakarta University
\nPulpstone OpenWrt/LEDE \nWebsite: http://pulpstone.pw \nFacebook: fb.com/pulpstone"
  ;;
"router")
  echo -e "Router Controller:\n/reboot \n/shutdown \n/restart_bot \n/connected_clients \n/memory \n/temperature \n/network_traffic \n/my_ip \n/3g_info \n/bot \n/about\n\nBack: /list"
  ;;
"kontak_on")
  kontakon=$(echo 1 > /dev/ttyACM0 && head -1 /dev/ttyACM0)
  echo -e "$kontakon"  
  ;;
"kontak_off")
  kontakoff=$(echo 2 > /dev/ttyACM0 && head -1 /dev/ttyACM0)
  echo -e "$kontakoff"  
  ;;
"mesin_on")
  mesinon=$(echo 3 > /dev/ttyACM0 && head -1 /dev/ttyACM0)
  echo -e "$mesinon"  
  ;;
"mesin_off")
  mesinoff=$(echo 4 > /dev/ttyACM0 && head -1 /dev/ttyACM0)
  echo -e "$mesinoff"  
  ;;
"getlokasi")
  lat=$(echo 5 > /dev/ttyACM0 && head -1 /dev/ttyACM0)
  long=$(echo 7 > /dev/ttyACM0 && head -1 /dev/ttyACM0)
  cal=$(echo Mengirim Lokasi Kendaraan)
  echo -e "$cal"
  curl -k -s -X POST $api/sendlocation -d chat_id=$my_chat_id -d latitude=$lat -d longitude=$long &> $telegram_log_file
  ;;
"answer_back")
  abs=$(echo 6 > /dev/ttyACM0 && head -1 /dev/ttyACM0)
  echo -e "$abs"  
  ;;
"kalibrasi")
  kalibrasi=$(echo 1 > /dev/ttyACM0 && head -1 /dev/ttyACM0)
  echo -e "$kalibrasi"  
  ;;
"list")
  echo -e "Vehicle Control:\nKontak On : /kontak_on\nKontak Off : /kontak_off\nMesin On : /mesin_on \nMesin Off : /mesin_off \nAnswer Back : /answer_back \nLokasi Kendaraan : /getlokasi \nKalibrasi Sensor : /kalibrasi\n\nRouter Control : /router\n\nBot Anti Maling Kendaraan\nby Dhimas Roby Satrio\nUniversitas Amikom Yogyakarta\nAbout Me : /about"
  ;;
  *)
    echo -e "List of Commands \n/list"
;;
esac



