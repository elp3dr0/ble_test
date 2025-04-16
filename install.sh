#!/bin/bash
# https://stackoverflow.com/questions/9449417/how-do-i-assign-the-output-of-a-command-into-an-array

echo " "
echo " "
echo " "
echo " "
echo "  ble-test"
echo " "

set -e  # Exit the script if any command fails

echo " "
echo "-------------------------------------------------------------"
echo "updates the list of latest updates available for the packages"
echo "-------------------------------------------------------------"
echo " "

sudo apt-get update

echo " "
echo "----------------------------------------------"
echo "install needed packages for python          "
echo "----------------------------------------------"
echo " "

sudo apt-get install -y \
    python3 \
    python3-gi \
    python3-gi-cairo \
    gir1.2-gtk-3.0 \
    python3-pip \
    libatlas-base-dev \
    libglib2.0-dev \
    libgirepository1.0-dev \
    libcairo2-dev \
    zlib1g-dev \
    libfreetype6-dev \
    liblcms2-dev \
    libopenjp2-7 \
    libtiff6 \
    libdbus-1-dev

echo " "
echo "----------------------------------------------"
echo "set up virtual environment        "
echo "----------------------------------------------"
echo " "

python3 -m venv venv
source venv/bin/activate

echo " "
echo "----------------------------------------------"
echo "install needed python3 modules for the project        "
echo "----------------------------------------------"
echo " "

pip install --upgrade pip
pip install -r requirements.txt

echo "----------------------------------------------"
echo " Add current user to bluetooth and dialout groups"
echo " (pirowflo should be run by this user) "
echo "----------------------------------------------"

CURRENT_USER=$(whoami)
sudo usermod -a -G bluetooth "$CURRENT_USER"
sudo usermod -a -G dialout "$CURRENT_USER"

echo " "
echo "-----------------------------------------------"
echo " Change bluetooth name of the pi to PiRowFlo"
echo "-----------------------------------------------"
echo " "

echo "PRETTY_HOSTNAME=ble_test" | sudo tee -a /etc/machine-info > /dev/null
#echo "PRETTY_HOSTNAME=S4 Comms PI" | sudo tee -a /etc/machine-info > /dev/null



export repo_dir=$(cd $(dirname $0) > /dev/null 2>&1; pwd -P)
export python3_path=$(which python3)
export supervisord_path=$(which supervisord)
export supervisorctl_path=$(which supervisorctl)


sudo rm -f /tmp/pirowflo*
sudo rm -f /tmp/supervisord.log

#echo " "
#echo "------------------------------------------------------------"
#echo " Update bluetooth settings according to Apple specifications"
#echo "------------------------------------------------------------"
#echo " "
# update bluetooth configuration and start supervisord from rc.local
#
#cp services/update-bt-cfg.service services/update-bt-cfg.service.tmp
#sed -i 's@#REPO_DIR#@'"$repo_dir"'@g' services/update-bt-cfg.service.tmp
#sudo mv services/update-bt-cfg.service.tmp /etc/systemd/system/update-bt-cfg.service
#sudo chown root:root /etc/systemd/system/update-bt-cfg.service
#sudo chmod 655 /etc/systemd/system/update-bt-cfg.service
#sudo systemctl enable update-bt-cfg


#echo " "
#echo "-----------------------------------------------"
#echo " update bluart file as it prevents the start of"
#echo " internal bluetooth if usb bluetooth dongle is "
#echo " present                                       "
#echo "-----------------------------------------------"
#echo " "

#sudo sed -i 's/hci0/hci2/g' /usr/bin/btuart

echo " "
echo "----------------------------------------------"
echo " Add absolut path to the logging.conf file    "
echo "----------------------------------------------"
echo " "

cp src/logging.conf.orig src/logging.conf
sed -i 's@#REPO_DIR#@'"$repo_dir"'@g' src/logging.conf

echo " "
echo "----------------------------------------------"
echo " installation done ! rebooting in 3, 2, 1 "
echo "----------------------------------------------"
sleep 3
sudo reboot
echo " "
exit 0
