# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
    # Every Vagrant development environment requires a box. You can search for
    # boxes at https://atlas.hashicorp.com/search.
    config.vm.box = "openindiana/hipster"

    # Disable automatic box update checking. If you disable this, then
    # boxes will only be checked for updates when the user runs
    # `vagrant box outdated`. This is not recommended.
    config.vm.box_check_update = true

    # Autoconfigure resources for development VM. The snippet is taken from
    # https://stefanwrobel.com/how-to-make-vagrant-performance-not-suck.
    # We allocate 1/4 of available system memory and CPU core count of the host
    # to the VM, so performance does not suck.
    host = RbConfig::CONFIG['host_os']

    # Get memory size and CPU cores amount
    if host =~ /solaris/
        mem = `/usr/sbin/prtconf|grep Memory|cut -f3 -d' '`.to_i * 1024 * 1024
        cpus = `/usr/sbin/psrinfo|wc -l`.to_i
    elsif host =~ /darwin/
        # sysctl returns Bytes
        mem = `sysctl -n hw.memsize`.to_i
        cpus = `sysctl -n hw.ncpu`.to_i
    elsif host =~ /linux/
        # meminfo shows size in kB; convert to Bytes
        mem = `awk '/MemTotal/ {print $2}' /proc/meminfo`.to_i * 1024
        cpus = `getconf _NPROCESSORS_ONLN`.to_i
    elsif host =~ /mswin|mingw|cygwin/
        # Windows code via https://github.com/rdsubhas/vagrant-faster
        mem = `wmic computersystem Get TotalPhysicalMemory`.split[1].to_i
        cpus = `echo %NUMBER_OF_PROCESSORS%`.to_i
    else
        puts "Unsupported operating system"
        exit
    end

    # Give VM 1/4 system memory as well as CPU core count
    mem /= 1024 ** 2 * 4
    cpus /= 4

    config.vm.provider "virtualbox" do |v|
        v.customize ["modifyvm", :id, "--memory", mem]
        v.customize ["modifyvm", :id, "--cpus", cpus]

        v.customize ["storagectl", :id, "--name", "SATA Controller", "--hostiocache", "on"]
        # Enable following line, if oi-userland directory is on non-rotational
        # drive (e.g. SSD). (This could be automated, but with all those storage
        # technologies (LVM, partitions, ...) on all three operationg systems,
        # it's actually error prone to detect it automatically.) macOS has it
        # enabled by default as recent Macs have SSD anyway.
        if host =~ /darwin/
            v.customize ["storageattach", :id, "--storagectl", "SATA Controller", "--port", 0, "--nonrotational", "on"]
        else
            v.customize ["storageattach", :id, "--storagectl", "SATA Controller", "--port", 0, "--nonrotational", "on"]
        end
    end

    config.vm.provider :libvirt do |libvirt|
        libvirt.memory = mem
        libvirt.cpus = cpus
        libvirt.storage :file, :size => '50G'
    end

    # Once vagrant is able to chown files on OpenIndiana, chown line should be
    # removed from this part.
    config.vm.provision "shell", inline: <<-SHELL
        pfexec chown -R vagrant:vagrant /vagrant
        pfexec pkg install security/sudo \
            media/cdrtools \
            network/rsync \
            file/gnu-coreutils \
            developer/gcc-10 \
            system/library/gcc-10-compat-links \
            jq
        zfs create -o mountpoint=/img rpool/images
    SHELL

  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    set -ex
    chmod 664 $HOME/.bashrc
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- --profile complete -y
    mkdir -p /export/home/vagrant/.cargo/
    cat<<EOF > /export/home/vagrant/.cargo/config.toml
[build]
target-dir = "/export/home/vagrant/.cargo/target"
EOF

    source ~/.cargo/env

    (cd /vagrant/image-builder && cargo install --path .)

    (cd /vagrant/metadata-agent && cargo build --release)

    cp ~/.cargo/target/release/metadata /vagrant/templates/files/
    cp ~/.cargo/target/release/useragent /vagrant/templates/files/
  SHELL

end

