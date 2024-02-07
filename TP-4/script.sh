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


main () {
    dnf update -y
    dnf upgrade -y
    chrony
    ip_forward
    packet_redirect
    icmp_redirect
    secure_icmp_redirect
    sus_packet_log
    icmp_broadcast
}


while true; do
    who
    read -p "Is this machine the server? (y/n) " yn
    case $yn in
        [Yy]* ) read -p "Please enter your clients public key, then press enter: " pub; main; break;;
        [Nn]* ) echo "Sorry, this script only works if the machine is your server"; break;;
        * ) echo "Please answer yes or no.";;
    esac
done
