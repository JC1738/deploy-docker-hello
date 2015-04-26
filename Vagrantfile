# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = '2'

Vagrant.require_version '>= 1.5.0'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  config.vm.hostname = 'dockerdeploy-berkshelf'

  # Set the version of chef to install using the vagrant-omnibus plugin
  # NOTE: You will need to install the vagrant-omnibus plugin:
  #
  #   $ vagrant plugin install vagrant-omnibus
  #
  if Vagrant.has_plugin?("vagrant-omnibus")
    config.omnibus.chef_version = '11.18.6'
  end

  # Every Vagrant virtual environment requires a box to build off of.
  # If this value is a shorthand to a box in Vagrant Cloud then
  # config.vm.box_url doesn't need to be specified.
  config.vm.box = 'chef/ubuntu-14.04'


  # Assign this VM to a host-only network IP, allowing you to access it
  # via the IP. Host-only networks can talk to the host machine as well as
  # any other machines on the same network, but cannot be accessed (through this
  # network interface) by any external networks.
  config.vm.network :forwarded_port, guest: 8080, host: 8080
  config.vm.network :forwarded_port, guest: 8081, host: 8081
  config.vm.network :forwarded_port, guest: 8082, host: 8082
  config.vm.network :forwarded_port, guest: 8083, host: 8083

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
   config.vm.provider :virtualbox do |vb|
  #   # Don't boot with headless mode
  #   vb.gui = true
  #
  #   # Use VBoxManage to customize the VM. For example to change memory:
  #   vb.customize ["modifyvm", :id, "--memory", "1024"]

      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--memory", "1024"]

   end
  #
  # View the documentation for the provider you're using for more
  # information on available options.

  # The path to the Berksfile to use with Vagrant Berkshelf
  config.berkshelf.berksfile_path = "./Berksfile"

  # Enabling the Berkshelf plugin. To enable this globally, add this configuration
  # option to your ~/.vagrant.d/Vagrantfile file
  config.berkshelf.enabled = true

  # An array of symbols representing groups of cookbook described in the Vagrantfile
  # to exclusively install and copy to Vagrant's shelf.
  # config.berkshelf.only = []

  # An array of symbols representing groups of cookbook described in the Vagrantfile
  # to skip installing and copying to Vagrant's shelf.
  # config.berkshelf.except = []

  config.vm.provision :chef_solo do |chef|
    chef.log_level = :info
    chef.json = {
      docker: {
        version: '1.5.0',
        storage_driver: 'aufs'
      },
      deploy: {
        set: 'all',
        docker:
        [
          {
          machineType: 'machine0',
          dockerImage: 'docker-test',
          dockerImageTag: 'build-5',
          dockerRegistry: 'jcastillo',
          dockerEnvironment: ['test=0'],
          dockerPort: '8080:8080',
          dockerCPUShares: '1024',
          dockerMemory: '512m',
          dockerVolumes: nil,
          dockerAdditionalCMDs: '',
          deployCheck: '',
          enabled: true
          },
          {
            machineType: 'machine1',
            dockerImage: 'docker-test',
            dockerImageTag: 'build-3',
            dockerRegistry: 'jcastillo',
            dockerEnvironment: ['test=1'],
            dockerPort: '8081:8080',
            dockerCPUShares: '1024',
            dockerMemory: '512m',
            dockerVolumes: nil,
            dockerAdditionalCMDs: '',
            deployCheck: '',
            enabled: true
        },
        {
          machineType: 'machine2',
          dockerImage: 'docker-test',
          dockerImageTag: 'build-2',
          dockerRegistry: 'jcastillo',
          dockerEnvironment: ['test=2'],
          dockerPort: '8082:8080',
          dockerCPUShares: '1024',
          dockerMemory: '512m',
          dockerVolumes: nil,
          dockerAdditionalCMDs: '',
          deployCheck: '',
          enabled: true
      },
      {
        machineType: 'cadvisor',
        dockerImage: 'cadvisor',
        dockerImageTag: 'latest',
        dockerRegistry: 'google',
        dockerEnvironment: ['test=2'],
        dockerPort: '8083:8080',
        dockerCPUShares: '1024',
        dockerMemory: '512m',
        dockerVolumes: ['/:/rootfs:ro', '/var/run:/var/run:rw', '/sys:/sys:ro', '/var/lib/docker/:/var/lib/docker:ro'],
        dockerAdditionalCMDs: '',
        deployCheck: '',
        enabled: true
     }
      ]
    },
      config: {
        qa_mode: '1'
      }
    }

    chef.run_list = [
      'recipe[dockerdeploy::default]'
    ]
  end
end
