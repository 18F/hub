VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.network "forwarded_port", guest: 8080, host: 8080

  config.vm.provision :ansible do |ansible|
    ansible.playbook = 'deploy/ansible/playbook.yml'
  end
end
