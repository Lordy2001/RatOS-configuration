#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "ERROR: Please run as root"
  exit
fi

MCU=/dev/btt-octopus-pro-446
VENDORDEVICEID=0483:df11

pushd /home/pi/klipper
service klipper stop
if [ -h $MCU ]; then
    echo "Flashing Octopus via path"
    make flash FLASH_DEVICE=$MCU
else
    echo "Flashing Octopus via vendor and device ids - 1st pass"
    make flash FLASH_DEVICE=$VENDORDEVICEID
fi
sleep 5
if [ -h $MCU ]; then
    echo "Flashing Successful!"
else
    echo "Flashing Octopus via vendor and device ids - 2nd pass"
    make flash FLASH_DEVICE=$VENDORDEVICEID

    sleep 5
    if [ -h $MCU ]; then
        echo "Flashing Successful!"
    else
        echo "Flashing Octopus via vendor and device ids - 3rd pass"
        make flash FLASH_DEVICE=$VENDORDEVICEID
        if [ $? -e 0 ]; then
            echo "Flashing successful!"
        else
            echo "Flashing failed :("
            service klipper start
            popd
            # Reset ownership
            chown pi:pi -R /home/pi/klipper
            exit 1
        fi
    fi
fi
# Reset ownership
chown pi:pi -R /home/pi/klipper
service klipper start
popd