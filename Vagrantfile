# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  config.vm.provider :virtualbox do |v|
    v.memory = 1024
    v.cpus = 1
  end

  config.vm.define "head" do |head|
    head.vm.box = "generic/centos8"
    head.vm.hostname = "head"
    head.vm.network :private_network, ip: "192.168.100.2"
    head.vm.synced_folder "./", "/home/vagrant/vagrant-k3s-hpccluster"
    head.vm.provision "shell", path: "provision-head.sh"
  end

  config.vm.define "fe1" do |fe1|
    fe1.vm.box = "generic/centos8"
    fe1.vm.hostname = "fe1"
    fe1.vm.network :private_network, ip: "192.168.100.20"
  end

  config.vm.define "node01" do |node01|
    node01.vm.box = "generic/centos8"
    node01.vm.hostname = "node01"
    node01.vm.network :private_network, ip: "192.168.100.101"
    node01.vm.synced_folder "./", "/home/vagrant/vagrant-k3s-hpccluster"
    node01.vm.provision "shell", path: "provision-node.sh"
  end

  ## If proxy environment variables are set, pass them in
  if Vagrant.has_plugin?("vagrant-proxyconf")
    config.proxy.http     = ENV["http_proxy"]
    config.proxy.https    = ENV["https_proxy"]
    config.proxy.no_proxy = ENV["no_proxy"]
  end

end
