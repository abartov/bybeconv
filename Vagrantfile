# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "ubuntu/bionic64"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  config.vm.network "forwarded_port", guest: 3000, host: 3003

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  #config.vm.network "private_network", ip: "192.168.33.10"
  #config.vm.network "private_network", type: "dhcp"
  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  #config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
     vb.memory = "4096"
  end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y git curl wkhtmltopdf pandoc yaz libyaz-dev  libmagickwand-dev libpcap-dev memcached
    # MySQL
    apt-get install -y mysql-server mysql-client libmysqlclient-dev
    # TODO: configure database
    # TODO: import database
    # ElasticSearch
    apt-get install -y openjdk-8-jre
    if [ ! -f "elasticsearch-6.8.20.deb" ]; then
      wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.8.20.deb
    fi
    dpkg -i ./elasticsearch-6.8.20.deb
    update-rc.d elasticsearch defaults 95 10
  SHELL
  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    # Ruby
    curl -sSL https://get.rvm.io | bash
    source /home/vagrant/.rvm/scripts/rvm
    rvm requirements
    rvm install 2.6
    rvm use 2.6 --default
    ruby -v
    # Rails and app bundle
    gem install bundler mini_racer
    cd /vagrant
    bundle install
    # set up DB
    if [ ! -f "config/database.yml" ]; then
      cp config/database.yml.example config/database.yml
    fi
    #rake db:reset
  SHELL
  # run app on every vagrant 'up'
  config.vm.provision "shell", privileged: false, run: "always", inline: <<-SHELL
    source /home/vagrant/.rvm/scripts/rvm
    rvm use 2.6 --default
    cd /vagrant
    bundle install
    rails s -b=0.0.0.0 &
  SHELL

end
