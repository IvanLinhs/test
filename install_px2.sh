#!/bin/bash
if [ $# != 1 ]; then
  echo "Usage: "
  echo "./install_px2.sh [a|b]"
  exit 1;
fi
  
sudo echo "10.42.0.28 tegra-a" >> /etc/hosts
sudo echo "10.42.0.29 tegra-b" >> /etc/hosts

#sudo apt-get update
#sudo apt-get -y install apt-transport-https

sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup
sudo rm /etc/apt/sources.list

sudo echo "deb http://mirrors.ustc.edu.cn/ubuntu-ports/ xenial main restricted universe multiverse" >> /etc/apt/sources.list
sudo echo "deb http://mirrors.ustc.edu.cn/ubuntu-ports/ xenial-updates main restricted universe multiverse" >> /etc/apt/sources.list
sudo echo "deb http://mirrors.ustc.edu.cn/ubuntu-ports/ xenial-backports main restricted universe multiverse" >> /etc/apt/sources.list
sudo echo "deb http://mirrors.ustc.edu.cn/ubuntu-ports/ xenial-security main restricted universe multiverse" >> /etc/apt/sources.list

sudo sh -c '. /etc/lsb-release && echo "deb http://mirrors.ustc.edu.cn/ros/ubuntu/ $DISTRIB_CODENAME main" > /etc/apt/sources.list.d/ros-latest.list'

sudo apt-get update

sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116

sudo apt-get -y install libssl1.0.0/xenial libssl-doc/xenial libssl-dev/xenial
sudo apt-get -y install ros-kinetic-desktop-full

echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc
echo "source ~/nullmax_pilot/devel/setup.bash" >> ~/.bashrc
echo "export DW_MAJOR_VERSION=1" >> ~/.bashrc
echo "export DW_MINOR_VERSION=2" >> ~/.bashrc
echo "export ROS_MASTER_URI=http://tegra-b:11311" >> ~/.bashrc

if [ "$1" == "a" ]; then
  #tegra-a
  echo "export ROS_IP=10.42.0.28" >> ~/.bashrc
else
  #tegra-b
  echo "export ROS_IP=10.42.0.29" >> ~/.bashrc
  echo "cd ~/nullmax_pilot" >> ~/.bashrc
  echo "bash ./scripts/setup_canbus.sh 1" >> ~/.bashrc
  echo "roslaunch esr_mobileye_node esr_mobileye_node.launch " >> ~/.bashrc
fi


