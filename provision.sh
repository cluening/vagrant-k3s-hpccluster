yum install -y http://repos.openhpc.community/OpenHPC/2/CentOS_8/x86_64/ohpc-release-2-1.el8.x86_64.rpm
yum install -y ansible buildah jq
yum install -y munge slurm-ohpc

# Put the local registry config in place
mkdir -p /etc/rancher/k3s
cp /home/vagrant/vagrant-k3s-hpccluster/kubeconfig/configfiles/etc/rancher/k3s/registries.yaml /etc/rancher/k3s/ 

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

# Enable and start munge
systemctl enable munge
systemctl start munge

# Create the slurmctld container and service
/usr/local/bin/kubectl apply -f /home/vagrant/vagrant-k3s-hpccluster/kubeconfig/defs/slurmctld-deployment.yaml
/usr/local/bin/kubectl apply -f /home/vagrant/vagrant-k3s-hpccluster/kubeconfig/defs/slurmctld-service.yaml

# Set up slurm locally
mkdir -p /etc/slurm
cp /home/vagrant/vagrant-k3s-hpccluster/kubeconfig/slurmconfig/slurm.conf /etc/slurm/
echo "192.168.100.2 slurm" >> /etc/hosts