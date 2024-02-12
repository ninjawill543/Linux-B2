#!/bin/bash

who () {
    if [ "$EUID" -ne 0 ]
        then echo "Please run as root"
        exit
    fi
}

chrony () {
  rpm -q chrony | grep -q 'package chrony is not installed' && echo 'Installing chrony' ; dnf install -y chrony
  systemctl start chronyd
  systemctl enable chronyd
}

permissions () {    
    df --local -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' find '{}' -xdev -type d \( -perm -0002 -a ! -perm -1000 \) 2>/dev/null | xargs -I '{}' chmod a+t '{}'
    chmod 644 /etc/passwd
	chmod 600 /etc/shadow
	chmod 644 /etc/group
	chmod 440 /etc/sudoers
	chmod 600 /etc/ssh/sshd_config
	chmod 644 /etc/sysctl.conf
	chmod 644 /etc/fstab
	chmod 644 /etc/hosts.allow
	chmod 644 /etc/hosts.deny
	chmod 644 /etc/login.defs
	chmod 644 /etc/profile
	chmod 644 /etc/motd
	chmod 644 /etc/issue
	chmod 600 /etc/securetty
	chmod 644 /etc/shells
	chmod 644 /etc/aliases
	chmod 600 /etc/crontab
	chmod 644 /etc/hosts
    chown root:root /etc/passwd
	chown root:shadow /etc/shadow
	chown root:root /etc/group
	chown root:root /etc/sudoers
	chown root:root /etc/ssh/sshd_config
	chown root:root /etc/sysctl.conf
	chown root:root /etc/fstab
	chown root:root /etc/hosts.allow
	chown root:root /etc/hosts.deny
	chown root:root /etc/login.defs
	chown root:root /etc/profile
	chown root:root /etc/motd
	chown root:root /etc/issue
	chown root:root /etc/securetty
	chown root:root /etc/shells
	chown root:root /etc/aliases
	chown root:root /etc/crontab
	chown root:root /etc/hosts
}

ip_forward () {
    printf "net.ipv4.ip_forward = 0" >> /etc/sysctl.d/60-netipv4_sysctl.conf
    {
        sysctl -w net.ipv4.ip_forward=0
        sysctl -w net.ipv4.route.flush=1
    }
    printf "net.ipv6.conf.all.forwarding = 0" >> /etc/sysctl.d/60-netipv6_sysctl.conf
    {
        sysctl -w net.ipv6.conf.all.forwarding=0
        sysctl -w net.ipv6.route.flush=1
    }
}

packet_redirect () {
    printf "
            net.ipv4.conf.all.send_redirects = 0
            net.ipv4.conf.default.send_redirects = 0" >> /etc/sysctl.d/60-netipv4_sysctl.conf
    {
        sysctl -w net.ipv4.conf.all.send_redirects=0
        sysctl -w net.ipv4.conf.default.send_redirects=0
        sysctl -w net.ipv4.route.flush=1
    }
}

icmp_redirect () {
    printf "
        net.ipv4.conf.all.accept_redirects = 0
        net.ipv4.conf.default.accept_redirects = 0" >> /etc/sysctl.d/60-netipv4_sysctl.conf
    {
        sysctl -w net.ipv4.conf.all.accept_redirects=0
        sysctl -w net.ipv4.conf.default.accept_redirects=0
        sysctl -w net.ipv4.route.flush=1
    }
    printf "
        net.ipv6.conf.all.accept_redirects = 0
        net.ipv6.conf.default.accept_redirects = 0" >> /etc/sysctl.d/60-netipv6_sysctl.conf
    {
        sysctl -w net.ipv6.conf.all.accept_redirects=0
        sysctl -w net.ipv6.conf.default.accept_redirects=0
        sysctl -w net.ipv6.route.flush=1
    }
}

secure_icmp_redirect () {
    printf "
        net.ipv4.conf.all.secure_redirects = 0
        net.ipv4.conf.default.secure_redirects = 0" >> /etc/sysctl.d/60-netipv4_sysctl.conf
    {
        sysctl -w net.ipv4.conf.all.secure_redirects=0
        sysctl -w net.ipv4.conf.default.secure_redirects=0
        sysctl -w net.ipv4.route.flush=1
    }
}

sus_packet_log () {
    printf "
        net.ipv4.conf.all.log_martians = 1
        net.ipv4.conf.default.log_martians = 1" >> /etc/sysctl.d/60-netipv4_sysctl.conf
    {
        sysctl -w net.ipv4.conf.all.log_martians=1
        sysctl -w net.ipv4.conf.default.log_martians=1
        sysctl -w net.ipv4.route.flush=1
    }
}

icmp_broadcast () {
    printf "net.ipv4.icmp_echo_ignore_broadcasts = 1" >> /etc/sysctl.d/60-netipv4_sysctl.conf
    {
        sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1
        sysctl -w net.ipv4.route.flush=1
    }
}

rev_path_filter () {
    printf "
        net.ipv4.conf.all.rp_filter = 1
        net.ipv4.conf.default.rp_filter = 1" >> /etc/sysctl.d/60-netipv4_sysctl.conf
    {
        sysctl -w net.ipv4.conf.all.rp_filter=1
        sysctl -w net.ipv4.conf.default.rp_filter=1
        sysctl -w net.ipv4.route.flush=1
    }
}

ssh () {
    rm /etc/ssh/ssh_host_*
    rm ~/.ssh/id_*
    mkdir /home/$ssh_name/.ssh/
    touch /home/$ssh_name/.ssh/authorized_keys
    echo $pub | sudo tee /home/$ssh_name/.ssh/authorized_keys
    ssh-keygen -o -a 256 -t ed25519 -N "" -f /etc/ssh/ssh_host_ed25519_key
    systemctl restart sshd
    stat -Lc "%n %a %u/%U %g/%G" /etc/ssh/sshd_config | grep -q '/etc/ssh/sshd_config 600 0/root 0/root' && chown root:root /etc/ssh/sshd_config ; chmod u-x,go-rwx /etc/ssh/sshd_config
    chmod 0600 /etc/ssh/ssh_host_ed25519_key
    cp ssh.txt /etc/ssh/sshd_config
    systemctl restart sshd
}

DOT () {
    dnf install epel-release -y
    dnf update -y
    dnf install systemd-resolved -y
    systemctl enable systemd-resolved
    systemctl start systemd-resolved
    echo "
            [Resolve]
            DNS=1.1.1.1
            Domains=~
            DNSSEC=yes
            DNSOverTLS=yes" | tee /etc/systemd/resolved.conf 

    systemctl restart systemd-resolved
    ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
}

firewall () {
    systemctl enable firewalld
    systemctl start firewalld
    firewall-cmd --permanent --add-port=7372/tcp
    firewall-cmd --permanent --add-port=22/tcp
    firewall-cmd --permanent --add-service=http
    firewall-cmd --permanent --add-service=https
    firewall-cmd --reload
}

AIDE () {
    dnf install aide -y 
    aide --init
    cp -p /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
    aide --update
}

fail2ban () {
    dnf install fail2ban -y
    systemctl enable fail2ban
    systemctl start fail2ban
    cp fail2ban.txt /etc/fail2ban/jail.local
    mv /etc/fail2ban/jail.d/00-firewalld.conf /etc/fail2ban/jail.d/00-firewalld.local
    systemctl restart fail2ban
    echo "
        [sshd]
        enabled = true

        # Override the default global configuration
        # for specific jail sshd
        bantime = 1d
        maxretry = 3" | tee /etc/fail2ban/jail.d/sshd.local
    systemctl restart fail2ban
}

Docker () {
    dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    dnf install docker-ce docker-ce-cli containerd.io -y 
    systemctl start docker
    systemctl enable docker
    usermod -aG docker $ssh_name       
    docker compose up -d
    
}

usb (){
    echo 'blacklist usb-storage' >> /etc/modprobe.d/blacklist.conf
    modprobe usb-storage
}

selinux () {
    dnf install selinux-policy-targeted selinux-policy-devel -y
    sed -i 's/^SELINUX=.*/SELINUX=enforcing/g' /etc/selinux/config

}

Client (){
    echo "You can use this command to reconnect to the server once it has been restarted: sudo ssh $ssh_name@server_ip -i your_key -p 7372"
}

main () {
    dnf update -y
    dnf upgrade -y
    chrony
    permissions
    ip_forward
    packet_redirect
    icmp_redirect
    secure_icmp_redirect
    sus_packet_log
    icmp_broadcast
    rev_path_filter
    ssh
    DOT
    firewall
    fail2ban
    Docker
    usb
    selinux
    AIDE
    Client
}


while true; do
    who
    read -p "Is this machine the server? (y/n) " yn
    case $yn in
        [Yy]* ) read -p "Please enter your clients public key, then press enter: " pub; printf "\n"; read -p "Please enter the username of the account you would like to use to connect via ssh, then press enter: " ssh_name;  main; break;;
        [Nn]* ) echo "Sorry, this script only works if the machine is your server"; break;;
        * ) echo "Please answer yes or no.";;
    esac
done
