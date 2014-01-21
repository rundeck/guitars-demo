
Vagrant.configure("2") do |config|
  PROJECT="guitars"
  RDIP="192.168.50.3"

  #RUNDECK_YUM_REPO="https://bintray.com/rundeck/ci-snapshot-rpm/rpm"
  RUNDECK_YUM_REPO="https://bintray.com/gschueler/ci-rundeck2-rpm/rpm"
  #RUNDECK_YUM_REPO="https://bintray.com/rundeck/candidate-rpm/rpm"


  config.vm.box = "CentOS-6.3-x86_64-minimal"
  config.vm.box_url = "https://dl.dropbox.com/u/7225008/Vagrant/CentOS-6.3-x86_64-minimal.box"


  config.vm.define :rundeck do |rundeck|
    rundeck.vm.hostname = "rundeck.local"
    rundeck.vm.network :private_network, ip: "#{RDIP}"
    rundeck.vm.provision :shell, :path => "provisioning/rundeck/install.sh", :args => "#{RDIP} #{RUNDECK_YUM_REPO}"
    rundeck.vm.provision :shell, :path => "provisioning/install-httpd.sh", :args=> "#{PROJECT}"
    rundeck.vm.provision :shell, :path => "provisioning/rundeck/add-project.sh", :args => "#{PROJECT} 192.168.50.21"
  end

  config.vm.define :app1 do |app1|
    app1.vm.hostname = "app1"
    app1.vm.network :private_network, ip: "192.168.50.21"
    app1.vm.provision :shell, :path => "provisioning/bootstrap-node.sh", :args => "192.168.50.21 http://#{RDIP}:4440 #{PROJECT}"
  end


end
