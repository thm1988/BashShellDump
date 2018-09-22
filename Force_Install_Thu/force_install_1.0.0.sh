#!/bin/bash
#Author: TP
#Version: 1.0.0
__usage="# Force install WF apk build into device
#
# List brand that this script can cover:
#              mk = MichaelKors
#              ds = Diesel
#              ms = Misift
#              sk = Skagen
#              fs = Fossil
#              ea = Emporio Armani
#              ax = Armani Exchange
#              tb = Tory Burch
#
# how to use: ./force_install_1.0.0.sh <userDirectory> e.g ./force_install_1.0.0.sh ~/Download/APK/
"
# To select the user folder containing the apk file
if [ -n "$1" ]; then
  userDir=$1 ;
else
  userDir=$HOME/Downloads ;
fi

#localDir=$HOME/Downloads

firstFigletSetup(){
  str1=$(which figlet)
  if [ -z $str1 ]; then
    echo "Figlet is NOT installed yet, do it now..."
    brew install figlet
  fi
}

Setup(){
  echo "Root the device"
  adb root
  echo "Mount system"
  adb shell mount -o rw,remount /system
}

brandSearch() {
 #Quit the application
 echo "Which brand (mk/ds/ms/sk/fs/ea/ax/tb) do you want to put into your device? Input q to quit..."
 read input

 #Select the brand
 if [[ -z $(grep "$input" brandlist.csv) ]]; then
 #No brand found
   echo "No record found, program will now exit!!!"
   exit 1
 else
   echo "Brand found"
   brand=$(grep "$input" brandlist.csv | cut -c4-)
   # Check if apk file is OK
   if [ -e "${userDir}/${brand}.apk" ]; then
     echo $userDir/$brand.apk exist, continue...
   else
     echo $userDir/$brand.apk does NOT exist, exit now...
     exit 1
   fi
fi
}

pushApp() {
  brandSearch
  echo "Remove the old apk"
  adb shell rm -rf /system/priv-app/$brand/*
  echo "Remove apk completed, restart the device"
  adb reboot
  waitDeviceReady
  echo "Push the apk from Downloads to the system build"
  adb push $userDir/$brand.apk /system/priv-app/$brand/
  echo "Push completed...."
  sleep 3
  echo "Now reboot device again..."
  adb reboot
  waitDeviceReady
}

deviceReady(){
  bootOK=$(adb shell getprop sys.boot_completed | tr -d '\r')
  while [ "$bootOK" != "1" ]
  do
       sleep 2
       bootOK=$(adb shell getprop sys.boot_completed | tr -d '\r')
   done
}

waitDeviceReady(){
  echo "Waiting for device ready after booting"
  adb wait-for-device
  if [ -n $(deviceReady)]; then
    adb root
    echo "Root granted..."
    adb shell mount -o rw,remount /system
    echo "System mounted..."
    sleep 3
  fi
}

echo '          INSTRUCTION' | figlet
echo "$__usage"
echo
echo "Check figlet setup..."
firstFigletSetup
echo "Setup..." | figlet
Setup
echo "Push apk file..." | figlet
pushApp
