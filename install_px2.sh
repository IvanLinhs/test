#!/bin/bash
if [ $# != 6 ]; then
  echo "Usage: "
  echo "./install_px2.sh [a|b] [sources|no_sources] [install|no|no_update_install] [host|no_host] [ssh|no_ssh] [bash|no_bash]"
fi

#edit sources.list 
function edit_sources_list(){
  if [ "$1" == "backup" ]; then
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup
  fi

  sudo rm /etc/apt/sources.list

  sudo echo "deb http://mirrors.ustc.edu.cn/ubuntu-ports/ xenial main restricted universe multiverse" >> /etc/apt/sources.list
  sudo echo "deb http://mirrors.ustc.edu.cn/ubuntu-ports/ xenial-updates main restricted universe multiverse" >> /etc/apt/sources.list
  sudo echo "deb http://mirrors.ustc.edu.cn/ubuntu-ports/ xenial-backports main restricted universe multiverse" >> /etc/apt/sources.list
  sudo echo "deb http://mirrors.ustc.edu.cn/ubuntu-ports/ xenial-security main restricted universe multiverse" >> /etc/apt/sources.list

  sudo sh -c '. /etc/lsb-release && echo "deb http://mirrors.ustc.edu.cn/ros/ubuntu/ $DISTRIB_CODENAME main" > /etc/apt/sources.list.d/ros-latest.list'
}

# install all package
function install_all(){
  if [ "$1" == "install" ]; then 
    sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
    sudo apt-get update
  fi

  sudo apt-get -y install libssl1.0.0/xenial libssl-doc/xenial libssl-dev/xenial
  sudo apt-get -y install ros-kinetic-desktop-full

  sudo apt-get -y install git ros-kinetic-joy ros-kinetic-robot-localization ros-kinetic-geodesy  python-skimage ros-kinetic-robot-localization ros-kinetic-geodesy libopencv-dev ros-kinetic-ompl ros-kinetic-base-local-planner ros-kinetic-costmap-converter ros-kinetic-teb-local-planner  libgoogle-glog-dev libgflags-dev ros-kinetic-driver-base ros-kinetic-can-msgs
  sudo apt-get -y install openssh-server

  init_ros
}

# init ros
function init_ros(){
  sudo rosdep init
  rosdep update
  echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc
}

# add hosts
function add_hosts(){
  sudo echo "10.42.0.28 tegra-a" >> /etc/hosts
  sudo echo "10.42.0.29 tegra-b" >> /etc/hosts
  cat /etc/hosts
}

# edit hostname
function edit_hostname(){
  if [ "$1" == "a" ]; then
    sudo echo "tegra-a" >> /etc/hostname
    echo 'hostname:'
    cat /etc/hostname

  elif [ "$1" == "b" ]; then
    sudo echo "tegra-b" >> /etc/hostname
    echo 'hostname:'
    cat /etc/hostname
  fi
}


# edit bashrc
function edit_bash(){
  
  echo "source ~/nullmax_pilot/devel/setup.bash" >> ~/.bashrc
  echo "export DW_MAJOR_VERSION=1" >> ~/.bashrc
  echo "export DW_MINOR_VERSION=2" >> ~/.bashrc

  if [ "$1" == "a" ] ; then
    #tegra-a
    echo "export ROS_MASTER_URI=http://tegra-b:11311" >> ~/.bashrc
    echo "export ROS_IP=10.42.0.28" >> ~/.bashrc
  elif [ "$1" == "b" ]; then
    #tegra-b
    echo "export ROS_MASTER_URI=http://tegra-b:11311" >> ~/.bashrc
    echo "export ROS_IP=10.42.0.29" >> ~/.bashrc
    echo "cd ~/nullmax_pilot" >> ~/.bashrc
    echo "bash ./scripts/setup_canbus.sh 1" >> ~/.bashrc
    echo "roslaunch esr_mobileye_node esr_mobileye_node.launch " >> ~/.bashrc
  fi
}

# edit bashrc

# generate ssh key to tegra-b
function gen_sshkey(){
  ssh-keygen -t rsa

  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
  scp ~/.ssh/authorized_keys ubuntu@tegra-b:~/.ssh
}

if [ "$2" == "sources" ]; then
  edit_sources_list
fi

if [ "$3" == "install" ] || [ "$3" == "no_update_install" ]; then
  install_all "$3"
fi

if [ "$4" == "host" ]; then
  add_hosts
  edit_hostname "$1"
fi

if [ "$1" == "a" ] && [ "$5" == "ssh" ]; then
  gen_sshkey
fi

if [ "$6" == "bash" ]; then
  edit_bash "$1"
fi
