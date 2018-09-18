Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/bionic64"

  config.vm.network "private_network", ip: "192.168.50.4"
  config.vm.network "forwarded_port", guest: 80, host: 8000

  config.vm.provider :virtualbox do |vb|
    vb.memory = "4096"
  end

  config.vm.provision "shell", path: "bootstrap/provision.sh", args: [`hostname -I | awk '{printf "%s", $1}'`]

  config.vm.synced_folder ".", "/var/www/#{File.basename(Dir.getwd)}"
end