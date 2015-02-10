# -*- mode: ruby -*-
# vi: set ft=ruby :


### configs ###

# Vagrantfile API/syntax version.
VAGRANTFILE_API_VERSION = "2"

### end configs ###

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    # box config
    config.vm.box = "ubuntu/trusty64"

    # provisioning
    config.vm.provision :shell, path: "bootstrap.sh"

    # Set IP
    # Postresql IP:5432
    config.vm.network "private_network", ip: "192.168.50.4"

end