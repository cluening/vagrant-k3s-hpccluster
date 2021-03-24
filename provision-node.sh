#!/bin/bash

yum install -y http://repos.openhpc.community/OpenHPC/2/CentOS_8/x86_64/ohpc-release-2-1.el8.x86_64.rpm
yum install -y ansible
yum install -y munge slurm-ohpc slurm-slurmd-ohpc

# Disable and stop the firewall
systemctl disable firewalld
systemctl stop firewalld

# Put the munge key in place
mkdir -p /etc/munge
cp /home/vagrant/vagrant-k3s-hpccluster/configfiles/etc/munge/munge.key /etc/munge/
chown munge:munge /etc/munge/munge.key
chmod 0400 /etc/munge/munge.key

# Enable and start munge
systemctl enable munge
systemctl start munge

# Set up slurmd
mkdir -p /etc/slurm
cp /home/vagrant/vagrant-k3s-hpccluster/kubeconfig/slurmconfig/slurm.conf /etc/slurm/
echo "192.168.100.2 slurm" >> /etc/hosts

# Enable and start slurmd
systemctl enable slurmd
systemctl start slurmd
