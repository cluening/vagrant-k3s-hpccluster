#!/bin/bash

yum install -y ansible
ansible-galaxy collection install community.kubernetes

ansible-playbook -i /home/vagrant/vagrant-k3s-hpccluster/ansiblerepo/inventory -c local /home/vagrant/vagrant-k3s-hpccluster/ansiblerepo/site.yaml
