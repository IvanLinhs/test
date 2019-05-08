#!/bin/bash

sudo echo "10.42.0.28 tegra-a" >> /etc/hosts
sudo echo "10.42.0.29 tegra-b" >> /etc/hosts

sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup
sudo apt-get update

