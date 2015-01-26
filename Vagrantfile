# -*- mode: ruby -*-
# vi: set ft=ruby :


### configs ###

# Vagrantfile API/syntax version.
VAGRANTFILE_API_VERSION = "2"
#VAGRANTFILE_DATABASE_FOLDER = "config/database/"
#VAGRANTFILE_AVAILABLE_FOLDER = "config/apache/"
#VAGRANTFILE_APAChe_FOLDER = "../../"

### end configs ###

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    # box config
    config.vm.box = "hashicorp/precise32"

    # provisioning
    config.vm.provision :shell, path: "bootstrap.sh"

    # network
    config.vm.network :forwarded_port, host: 4567, guest: 80

    
    ### synced folders ###

    # synced database folder
    #config.vm.synced_folder VAGRANTFILE_DATABASE_FOLDER, "/home/vagrant/database"

    # synced sites available folder
    #config.vm.synced_folder "../../config/apache/", "/etc/apache2/sites-available"

    # synced weather tracker apache folder
    #config.vm.synced_folder "../../", "/var/www/weather-tracker.com"

end