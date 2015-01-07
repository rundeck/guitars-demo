
Vagrant.configure("2") do |config|
  PROJECT="guitars"
  RDIP="192.168.50.3"

  RUNDECK_YUM_REPO="https://bintray.com/rundeck/rundeck-rpm/rpm"
  #RUNDECK_YUM_REPO="https://bintray.com/rundeck/ci-staging-rpm/rpm"



  config.vm.box = "CentOS-6.3-x86_64-minimal"
  config.vm.box_url = "https://dl.dropbox.com/u/7225008/Vagrant/CentOS-6.3-x86_64-minimal.box"


  config.vm.define :rundeck do |rundeck|
    rundeck.vm.hostname = "rundeck.local"
    rundeck.vm.network :private_network, ip: "#{RDIP}"
    rundeck.vm.provision :shell, :path => "provisioning/rundeck/install.sh", :args => "#{RDIP} #{RUNDECK_YUM_REPO}"
    rundeck.vm.provision :shell, :path => "provisioning/rundeck/install-plugins.sh", :args => "#{PROJECT}-stage #{PROJECT}-production"
    rundeck.vm.provision :shell, :path => "provisioning/install-httpd.sh", :args=> "#{PROJECT}"
    rundeck.vm.provision :shell, :path => "provisioning/rundeck/install-rundeck-admin.sh", :args => "https://bintray.com/rerun/rerun-rpm/rpm http://#{RDIP}:4440"
    rundeck.vm.provision :shell, :path => "provisioning/rundeck/add-project.sh", :args => "#{PROJECT}-stage 192.168.50.21 #{RDIP}"
    rundeck.vm.provision :shell, :path => "provisioning/rundeck/add-project.sh", :args => "#{PROJECT}-production 192.168.50.22 #{RDIP}"
  end


  config.vm.define :prd1 do |prd1|
    prd1.vm.hostname = "prd1"
    prd1.vm.network :private_network, ip: "192.168.50.22"
    prd1.vm.provision :shell, :path => "provisioning/rundeck/install-rundeck-admin.sh", :args => "https://bintray.com/rerun/rerun-rpm/rpm http://#{RDIP}:4440"    
    prd1.vm.provision :shell, :path => "provisioning/bootstrap-node.sh", 
      :args => "192.168.50.22 http://#{RDIP}:4440 #{PROJECT}-production"
  end

  config.vm.define :stg1 do |stg1|
    stg1.vm.hostname = "stg1"
    stg1.vm.network :private_network, ip: "192.168.50.21"
    stg1.vm.provision :shell, :path => "provisioning/rundeck/install-rundeck-admin.sh", :args => "https://bintray.com/rerun/rerun-rpm/rpm http://#{RDIP}:4440"
    stg1.vm.provision :shell, :path => "provisioning/bootstrap-node.sh", 
      :args => "192.168.50.21 http://#{RDIP}:4440 #{PROJECT}-stage"
  end
end
