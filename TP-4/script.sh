#!/bin/bash

ssh_config="
Protocol 2
StrictModes yes
Port 7372
AuthenticationMethods publickey
PubkeyAuthentication yes
HostKey /etc/ssh/ssh_host_ed25519_key
HostKeyAlgorithms ssh-ed25519-cert-v01@openssh.com,ssh-ed25519
KexAlgorithms curve25519-sha256
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
MACs hmac-sha2-512-etm@openssh.com
HostbasedAcceptedKeyTypes ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,ecdsa-sha2-nistp521,ssh-ed25519
PermitRootLogin no
MaxAuthTries 4
MaxSessions 2
PasswordAuthentication no
PermitEmptyPasswords no
IgnoreRhosts yes
HostbasedAuthentication no
ChallengeResponseAuthentication no
X11Forwarding no
LogLevel INFO
SyslogFacility AUTH
UseDNS no
PermitTunnel no
AllowTcpForwarding no
AllowUsers $ssh_name
AllowStreamLocalForwarding no
GatewayPorts no
AllowAgentForwarding no
Banner /etc/issue.net
PrintLastLog yes
ClientAliveInterval 15
ClientAliveCountMax 3
LoginGraceTime 30
MaxStartups 10:30:60
UsePAM yes
PermitUserEnvironment no
TCPKeepAlive yes
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/ssh/sftp-server -f AUTHPRIV -l INFO"


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
    echo $pub | sudo tee /home/$USER/.ssh/authorized_keys
    ssh-keygen -o -a 256 -t ed25519 -N "" -f /etc/ssh/ssh_host_ed25519_key
    systemctl sshd restart
    stat -Lc "%n %a %u/%U %g/%G" /etc/ssh/sshd_config | grep -q '/etc/ssh/sshd_config 600 0/root 0/root' && chown root:root /etc/ssh/sshd_config ; chmod u-x,go-rwx /etc/ssh/sshd_config
    chmod 0600 /etc/ssh/ssh_host_ed25519_key
    echo "$ssh_config" | tee /etc/ssh/sshd_config
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
    rev_path_filter
    ssh
}


while true; do
    who
    read -p "Is this machine the server? (y/n) " yn
    case $yn in
        [Yy]* ) read -p "Please enter your clients public key, then press enter: " pub; read -p "Please enter the username of the account you would like to use to connect via ssh, then press enter: " ssh_name;  main; break;;
        [Nn]* ) echo "Sorry, this script only works if the machine is your server"; break;;
        * ) echo "Please answer yes or no.";;
    esac
done
