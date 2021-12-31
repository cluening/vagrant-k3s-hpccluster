#!/bin/bash

python3 -m venv /root/ansible-venv
source /root/ansible-venv/bin/activate
pip install --upgrade pip
pip install ansible
ansible-galaxy collection install kubernetes.core

ansible-playbook \
  -e ansible_python_interpreter=$(which python) \
  -i /home/vagrant/vagrant-k3s-hpccluster/ansiblerepo/inventory \
  -c local \
  -l $(hostname) \
  /home/vagrant/vagrant-k3s-hpccluster/ansiblerepo/site.yaml
