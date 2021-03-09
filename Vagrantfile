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

  config.vm.define "s1" do |s1|
    s1.vm.box = "generic/centos8"
    s1.vm.hostname = "s1"
    s1.vm.network :private_network, ip: "10.0.0.11"
  end

  config.vm.define "s2" do |s2|
    s2.vm.box = "generic/centos8"
    s2.vm.hostname = "s2"
    s2.vm.network :private_network, ip: "10.0.0.12"
  end

  config.vm.define "s3" do |s3|
    s3.vm.box = "generic/centos8"
    s3.vm.hostname = "s3"
    s3.vm.network :private_network, ip: "10.0.0.13"
  end

  ## If proxy environment variables are set, pass them in
  if Vagrant.has_plugin?("vagrant-proxyconf")
    config.proxy.http     = ENV["http_proxy"]
    config.proxy.https    = ENV["https_proxy"]
    config.proxy.no_proxy = ENV["no_proxy"]
  end

end
