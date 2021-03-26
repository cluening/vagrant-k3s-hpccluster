#!/bin/bash

yum install -y http://repos.openhpc.community/OpenHPC/2/CentOS_8/x86_64/ohpc-release-2-1.el8.x86_64.rpm
yum install -y ansible buildah jq
yum install -y munge slurm-ohpc

# Disable and stop the firewall
# FIXME: something in the default firewall config is blocking traffic from
# inside pods (slurmctld, for example) to things running on nodes (slurmd
# port 6818, for example).  This needs some debugging
systemctl disable firewalld
systemctl stop firewalld

# Put the local registry config in place
mkdir -p /etc/rancher/k3s
cp /home/vagrant/vagrant-k3s-hpccluster/configfiles/etc/rancher/k3s/registries.yaml /etc/rancher/k3s/ 

# Install k3s
curl -L https://get.k3s.io/ -o /root/k3sinstall.sh
chmod a+x /root/k3sinstall.sh
/root/k3sinstall.sh server \
  --bind-address 192.168.100.2 \
  --advertise-address 192.168.100.2 \
  --node-ip 192.168.100.2 \
  --flannel-iface eth1 \
  --token vagranthpc

# Bring up the local container registry
/usr/local/bin/kubectl apply -f /home/vagrant/vagrant-k3s-hpccluster/kubeconfig/defs/local-path-pvc.yaml
/usr/local/bin/kubectl apply -f /home/vagrant/vagrant-k3s-hpccluster/kubeconfig/defs/docker-registry-deployment.yaml
/usr/local/bin/kubectl apply -f /home/vagrant/vagrant-k3s-hpccluster/kubeconfig/defs/docker-registry-service.yaml

# Wait for the registry pod to be ready
STATE=$(/usr/local/bin/kubectl get pods -l app=docker-registry -o json | jq -r '.items[].status.phase // "NotCreated"')
echo "Waiting for registry to be ready"
while [ "$STATE" != "Running" ]
do
  echo "Waiting... ($STATE)"
  sleep 5
  STATE=$(/usr/local/bin/kubectl get pods -l app=docker-registry -o json | jq -r '.items[].status.phase // "NotCreated"')
done
echo "Registry is ready!"

# Build an sssd container and put it in the registry
buildah build-using-dockerfile -t sssd /home/vagrant/vagrant-k3s-hpccluster/kubeconfig/sssdcontainer
buildah push --tls-verify=false localhost/sssd 192.168.100.2:5000/sssd

# Create sssd configmaps for the configuration and the local account info
/usr/local/bin/kubectl create configmap sssd-conf --from-file /home/vagrant/vagrant-k3s-hpccluster/kubeconfig/sssdconfig/sssd.conf
/usr/local/bin/kubectl create configmap etc-passwd-d --from-file /home/vagrant/vagrant-k3s-hpccluster/kubeconfig/sssdconfig/local

# Build slurm and munge containers and put them in the registry
buildah build-using-dockerfile -t slurmctld /home/vagrant/vagrant-k3s-hpccluster/kubeconfig/slurmcontainer/
buildah push --tls-verify=false localhost/slurmctld 192.168.100.2:5000/slurmctld
buildah build-using-dockerfile -t munge /home/vagrant/vagrant-k3s-hpccluster/kubeconfig/mungecontainer/
buildah push --tls-verify=false localhost/munge 192.168.100.2:5000/munge

# Put the slurm config into a configmap
/usr/local/bin/kubectl create configmap slurm-conf --from-file /home/vagrant/vagrant-k3s-hpccluster/kubeconfig/slurmconfig/slurm.conf

# Create a munge key and put it into a secret
/usr/sbin/create-munge-key
/usr/local/bin/kubectl create secret generic munge-key --from-file=/etc/munge/munge.key

# Copy the munge key into the shared directory so we can use it later on the compute nodes
mkdir -p /home/vagrant/vagrant-k3s-hpccluster/configfiles/etc/munge
cp /etc/munge/munge.key /home/vagrant/vagrant-k3s-hpccluster/configfiles/etc/munge

# Enable and start munge
systemctl enable munge
systemctl start munge

# Create the slurmctld deployment and service
/usr/local/bin/kubectl apply -f /home/vagrant/vagrant-k3s-hpccluster/kubeconfig/defs/slurmctld-deployment.yaml
/usr/local/bin/kubectl apply -f /home/vagrant/vagrant-k3s-hpccluster/kubeconfig/defs/slurmctld-service.yaml

# Set up slurm locally
mkdir -p /etc/slurm
cp /home/vagrant/vagrant-k3s-hpccluster/kubeconfig/slurmconfig/slurm.conf /etc/slurm/
echo "192.168.100.2 slurm" >> /etc/hosts
echo "192.168.100.101	node01" >> /etc/hosts
echo "192.168.100.102	node02" >> /etc/hosts
echo "192.168.100.103	node03" >> /etc/hosts
echo "192.168.100.104	node04" >> /etc/hosts

# Build the chrony image
buildah build-using-dockerfile -t chrony /home/vagrant/vagrant-k3s-hpccluster/kubeconfig/chronycontainer/
buildah push --tls-verify=false localhost/chrony 192.168.100.2:5000/chrony

# Create the chrony.conf configmap
/usr/local/bin/kubectl create configmap chrony-conf --from-file /home/vagrant/vagrant-k3s-hpccluster/kubeconfig/chronyconfig/chrony.conf

# Create the chronyd deployment and service
/usr/local/bin/kubectl apply -f /home/vagrant/vagrant-k3s-hpccluster/kubeconfig/defs/chronyd-deployment.yaml
/usr/local/bin/kubectl apply -f /home/vagrant/vagrant-k3s-hpccluster/kubeconfig/defs/chronyd-service.yaml
