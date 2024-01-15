# TP3 : Linux Hardening

**Dans ce TP, vous allez renforcer la sécurité d'un OS Linux.**

Le sujet du TP va être court car je ne vais pas réinventer la roue, et je vais vous renvoyer vers des ressources fiables.

![No basics](./img/nobasics.jpg)

## Sommaire

- [TP3 : Linux Hardening](#tp3--linux-hardening)
  - [Sommaire](#sommaire)
  - [0. Setup](#0-setup)
  - [1. Guides CIS](#1-guides-cis)
  - [2. Conf SSH](#2-conf-ssh)
  - [4. DoT](#4-dot)
  - [5. AIDE](#5-aide)

## 0. Setup

Vous utiliserez une VM Rocky Linux pour dérouler ce TP.

## 1. Guides CIS

CIS est une boîte qui notamment édite des guides de configuration

- assez réputés
- pour sécuriser les installations des OS courants
- notamment les OS Linux

🌞 **Suivre un guide CIS**

- téléchargez le guide CIS de Rocky 9 [ici](https://downloads.cisecurity.org/#/)
## 2.1
```
# rpm -q chrony
chrony-4.2-1.el8.rocky.1.0.x86_64

# grep -E "^(server|pool)" /etc/chrony.conf
pool 2.rocky.pool.ntp.org iburst

# grep ^OPTIONS /etc/sysconfig/chronyd
OPTIONS="-u chrony"
```
## 3.1 
```
# grep -Pqs '^\h*0\b' /sys/module/ipv6/parameters/disable && echo -e "\n -
> IPv6 is enabled\n" || echo -e "\n - IPv6 is not enabled\n"

 -
IPv6 is enabled


# bash wire.sh 

- Audit Result:
 ** PASS **

 - System has no wireless NICs installed


 # bash tipc.sh 
- Audit Result:
 ** PASS **

 - Module "tipc" doesn't exist on the
system
```
## 3.2
```
# bash ipforward.sh 
- Audit Result:
 ** FAIL **
 - Reason(s) for audit
failure:

 - "net.ipv4.ip_forward = 0" is not set
in a kernel parameter configuration file
 - "net.ipv6.conf.all.forwarding = 0" is not set
in a kernel parameter configuration file

- Correctly set:

 - "net.ipv4.ip_forward" is set to
"0" in the running configuration
 - "net.ipv4.ip_forward" is not set incorectly in
a kernel parameter configuration file
 - "net.ipv6.conf.all.forwarding" is set to
"0" in the running configuration
 - "net.ipv6.conf.all.forwarding" is not set incorectly in
a kernel parameter configuration file

$printf "
net.ipv4.ip_forward = 0
" >> /etc/sysctl.d/60-netipv4_sysctl.conf


# {
> sysctl -w net.ipv4.ip_forward=0
> sysctl -w net.ipv4.route.flush=1
> }
net.ipv4.ip_forward = 0
net.ipv4.route.flush = 1

printf "
net.ipv6.conf.all.forwarding = 0
" >> /etc/sysctl.d/60-netipv6_sysctl.conf

{
> sysctl -w net.ipv6.conf.all.forwarding=0
> sysctl -w net.ipv6.route.flush=1
> }
net.ipv6.conf.all.forwarding = 0
net.ipv6.route.flush = 1

# bash ipforward.sh 
- Audit Result:
 ** PASS **

 - "net.ipv4.ip_forward" is set to
"0" in the running configuration
 - "net.ipv4.ip_forward" is set to "0"
in "/etc/sysctl.d/60-netipv4_sysctl.conf"
 - "net.ipv4.ip_forward" is not set incorectly in
a kernel parameter configuration file
 - "net.ipv6.conf.all.forwarding" is set to
"0" in the running configuration
 - "net.ipv6.conf.all.forwarding" is set to "0"
in "/etc/sysctl.d/60-netipv6_sysctl.conf"
 - "net.ipv6.conf.all.forwarding" is not set incorectly in
a kernel parameter configuration file

# cat /etc/sysctl.conf 

# printf "
> net.ipv4.conf.all.send_redirects = 0
> net.ipv4.conf.default.send_redirects = 0
> " >> /etc/sysctl.d/60-netipv4_sysctl.conf

# {
> sysctl -w net.ipv4.conf.all.send_redirects=0
> sysctl -w net.ipv4.conf.default.send_redirects=0
> sysctl -w net.ipv4.route.flush=1
> }
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.route.flush = 1
```  
## 3.3
```
# cat /etc/sysctl.d/60-netipv4_sysctl.conf 

net.ipv4.ip_forward = 0

net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

printf "
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
" >> /etc/sysctl.d/60-netipv4_sysctl.conf

# {
> sysctl -w net.ipv4.conf.all.accept_source_route=0
> sysctl -w net.ipv4.conf.default.accept_source_route=0
> sysctl -w net.ipv4.route.flush=1
> }
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.route.flush = 1


# cat /etc/sysctl.d/60-netipv6_sysctl.conf 

net.ipv6.conf.all.forwarding = 0


# printf "
> net.ipv6.conf.all.accept_source_route = 0
> net.ipv6.conf.default.accept_source_route = 0
> " >> /etc/sysctl.d/60-netipv6_sysctl.conf
# {
> sysctl -w net.ipv6.conf.all.accept_source_route=0
> sysctl -w net.ipv6.conf.default.accept_source_route=0
> sysctl -w net.ipv6.route.flush=1
> }
net.ipv6.conf.all.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0
net.ipv6.route.flush = 1



# cat /etc/sysctl.d/60-netipv4_sysctl.conf 

net.ipv4.ip_forward = 0

net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
# printf "
> net.ipv4.conf.all.accept_redirects = 0
> net.ipv4.conf.default.accept_redirects = 0
> " >> /etc/sysctl.d/60-netipv4_sysctl.conf
# {
> sysctl -w net.ipv4.conf.all.accept_redirects=0
> sysctl -w net.ipv4.conf.default.accept_redirects=0
> sysctl -w net.ipv4.route.flush=1
> }
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.route.flush = 1
# cat /etc/sysctl.d/60-netipv6_sysctl.conf                                       

net.ipv6.conf.all.forwarding = 0

net.ipv6.conf.all.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0
# printf "
> net.ipv6.conf.all.accept_redirects = 0
> net.ipv6.conf.default.accept_redirects = 0
> " >> /etc/sysctl.d/60-netipv6_sysctl.conf
# {
> sysctl -w net.ipv6.conf.all.accept_redirects=0
> sysctl -w net.ipv6.conf.default.accept_redirects=0
> sysctl -w net.ipv6.route.flush=1
> }
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv6.route.flush = 1

3.3.3

# cat /etc/sysctl.d/60-netipv4_sysctl.conf 

net.ipv4.ip_forward = 0

net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
# printf "
> net.ipv4.conf.all.secure_redirects = 0
> net.ipv4.conf.default.secure_redirects = 0
> " >> /etc/sysctl.d/60-netipv4_sysctl.conf
# {
> sysctl -w net.ipv4.conf.all.secure_redirects=0
> sysctl -w net.ipv4.conf.default.secure_redirects=0
> sysctl -w net.ipv4.route.flush=1
> }
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.route.flush = 1

3.3.4


# cat /etc/sysctl.d/60-netipv4_sysctl.conf

net.ipv4.ip_forward = 0

net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0

net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
# printf "
> net.ipv4.conf.all.log_martians = 1
> net.ipv4.conf.default.log_martians = 1
> " >> /etc/sysctl.d/60-netipv4_sysctl.conf
# {
> sysctl -w net.ipv4.conf.all.log_martians=1
> sysctl -w net.ipv4.conf.default.log_martians=1
> sysctl -w net.ipv4.route.flush=1
> }
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
net.ipv4.route.flush = 1


3.3.5

# cat /etc/sysctl.d/60-netipv4_sysctl.conf

net.ipv4.ip_forward = 0

net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0

net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0

net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
# printf "
> net.ipv4.icmp_echo_ignore_broadcasts = 1
> " >> /etc/sysctl.d/60-netipv4_sysctl.conf
# {
> sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1
> sysctl -w net.ipv4.route.flush=1
> }
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.route.flush = 1


3.3.6

# cat /etc/sysctl.d/60-netipv4_sysctl.conf

net.ipv4.ip_forward = 0

net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0

net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0

net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

net.ipv4.icmp_echo_ignore_broadcasts = 1
# printf "
> net.ipv4.icmp_ignore_bogus_error_responses = 1
> " >> /etc/sysctl.d/60-netipv4_sysctl.conf
# {
> sysctl -w net.ipv4.icmp_ignore_bogus_error_responses=1
> sysctl -w net.ipv4.route.flush=1
> }
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.route.flush = 1

3.3.7

# cat /etc/sysctl.d/60-netipv4_sysctl.conf                                           
net.ipv4.ip_forward = 0

net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0

net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0

net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

net.ipv4.icmp_echo_ignore_broadcasts = 1

net.ipv4.icmp_ignore_bogus_error_responses = 1
# printf "
> net.ipv4.conf.all.rp_filter = 1
> net.ipv4.conf.default.rp_filter = 1
> " >> /etc/sysctl.d/60-netipv4_sysctl.conf
# {
> sysctl -w net.ipv4.conf.all.rp_filter=1
> sysctl -w net.ipv4.conf.default.rp_filter=1
> sysctl -w net.ipv4.route.flush=1
> }
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.route.flush = 1

3.3.8

# cat /etc/sysctl.d/60-netipv4_sysctl.conf

net.ipv4.ip_forward = 0

net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0

net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0

net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

net.ipv4.icmp_echo_ignore_broadcasts = 1

net.ipv4.icmp_ignore_bogus_error_responses = 1

net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
# printf "
> net.ipv4.tcp_syncookies = 1
> " >> /etc/sysctl.d/60-netipv4_sysctl.conf
# {
> sysctl -w net.ipv4.tcp_syncookies=1
> sysctl -w net.ipv4.route.flush=1
> }
net.ipv4.tcp_syncookies = 1
net.ipv4.route.flush = 1


3.3.9

# cat /etc/sysctl.d/60-netipv6_sysctl.conf

net.ipv6.conf.all.forwarding = 0

net.ipv6.conf.all.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0

net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
# printf "
> net.ipv6.conf.all.accept_ra = 0
> net.ipv6.conf.default.accept_ra = 0
> " >> /etc/sysctl.d/60-netipv6_sysctl.conf
# {
> sysctl -w net.ipv6.conf.all.accept_ra=0
> sysctl -w net.ipv6.conf.default.accept_ra=0
> sysctl -w net.ipv6.route.flush=1
> }
net.ipv6.conf.all.accept_ra = 0
net.ipv6.conf.default.accept_ra = 0
net.ipv6.route.flush = 1

```
## 5.2
```
5.2.1
# stat -Lc "%n %a %u/%U %g/%G" /etc/ssh/sshd_config
/etc/ssh/sshd_config 600 0/root 0/root


5.2.2

# chmod 0600 /etc/ssh/ssh_host_ecdsa_key
# chmod 0600 /etc/ssh/ssh_host_ed25519_key
# chmod 0600 /etc/ssh/ssh_host_rsa_key

5.2.3

# bash ssh.sh 

- Audit Result:
 - Correctly
set:

 - Public key file: "/etc/ssh/ssh_host_ed25519_key.pub" is mode
"0644" should be mode: "644" or more restrictive
 - Public key file: "/etc/ssh/ssh_host_ecdsa_key.pub" is mode
"0644" should be mode: "644" or more restrictive
 - Public key file: "/etc/ssh/ssh_host_rsa_key.pub" is mode
"0644" should be mode: "644" or more restrictive

# ls -al /etc/ssh/
total 616
drwxr-xr-x.  3 root root       4096  6 janv. 09:14 .
drwxr-xr-x. 87 root root       8192 12 janv. 03:06 ..
-rw-r--r--.  1 root root     577388  1 août  12:35 moduli
-rw-r--r--.  1 root root       1770  1 août  12:35 ssh_config
drwxr-xr-x.  2 root root         28 21 déc.  03:04 ssh_config.d
-rw-------.  1 root root       4267  6 janv. 09:14 sshd_config
-rw-------.  1 root ssh_keys    480 21 déc.  04:07 ssh_host_ecdsa_key
-rw-r--r--.  1 root root        162 21 déc.  04:07 ssh_host_ecdsa_key.pub
-rw-------.  1 root ssh_keys    387 21 déc.  04:07 ssh_host_ed25519_key
-rw-r--r--.  1 root root         82 21 déc.  04:07 ssh_host_ed25519_key.pub
-rw-------.  1 root ssh_keys   2578 21 déc.  04:07 ssh_host_rsa_key
-rw-r--r--.  1 root root        554 21 déc.  04:07 ssh_host_rsa_key.pub

5.2.4

# cat /etc/ssh/sshd_config | grep AllowUsers
AllowUsers user

5.2.5

# cat /etc/ssh/sshd_config | grep LogLevel
LogLevel INFO

5.2.6

# cat /etc/ssh/sshd_config | grep UsePAM
UsePAM yes

5.2.7

# cat /etc/ssh/sshd_config | grep PermitRootLogin
PermitRootLogin no

5.2.8

# cat /etc/ssh/sshd_config | grep Hostbased
HostbasedAuthentication no

5.2.9

# cat /etc/ssh/sshd_config | grep PermitEmpty
PermitEmptyPasswords no


5.2.10

# cat /etc/ssh/sshd_config | grep PermitUser
PermitUserEnvironment no

5.2.11

# cat /etc/ssh/sshd_config | grep IgnoreR
IgnoreRhosts yes

5.2.12

# cat /etc/ssh/sshd_config | grep X11For
X11Forwarding no

5.2.13

# cat /etc/ssh/sshd_config | grep AllowT
AllowTcpForwarding no

5.2.14

# grep -i '^\s*CRYPTO_POLICY=' /etc/sysconfig/sshd

5.2.15

# cat /etc/ssh/sshd_config | grep Banner
Banner /etc/issue.net

5.2.16

# cat /etc/ssh/sshd_config | grep MaxAuth
MaxAuthTries 4

5.2.17

# cat /etc/ssh/sshd_config | grep MaxStart
MaxStartups 10:30:60

5.2.18

# cat /etc/ssh/sshd_config | grep MaxSes
MaxSessions 10

5.2.19

# cat /etc/ssh/sshd_config | grep LoginGrace
LoginGraceTime 60

5.2.20

# cat /etc/ssh/sshd_config | grep Client
ClientAliveInterval 15
ClientAliveCountMax 3

```
  - au moins 10 points dans la section 6.1 System File Permissions

```
6.1.1

# stat -Lc "%n %a %u/%U %g/%G" /etc/passwd
/etc/passwd 644 0/root 0/root

6.1.2

# stat -Lc "%n %a %u/%U %g/%G" /etc/passwd-
/etc/passwd- 644 0/root 0/root

6.1.3

# stat -Lc "%n %a %u/%U %g/%G" /etc/group
/etc/group 644 0/root 0/root

6.1.4

# stat -Lc "%n %a %u/%U %g/%G" /etc/group-
/etc/group- 644 0/root 0/root

6.1.5

# stat -Lc "%n %a %u/%U %g/%G" /etc/shadow
/etc/shadow 0 0/root 0/root

6.1.6

# stat -Lc "%n %a %u/%U %g/%G" /etc/shadow-
/etc/shadow- 0 0/root 0/root

6.1.7

# stat -Lc "%n %a %u/%U %g/%G" /etc/gshadow
/etc/gshadow 0 0/root 0/root

6.1.8

# stat -Lc "%n %a %u/%U %g/%G" /etc/gshadow-
/etc/gshadow- 0 0/root 0/root

6.1.9

# df --local -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' find '{}' -xdev -type f -perm -0002

6.1.10

# df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -nouser

6.1.11

# df --local -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' find '{}' -xdev -nogroup

```
  - au moins 10 points ailleur sur un truc que vous trouvez utile

```
5.3.3

# cat /etc/sudoers | grep logfile
Defaults logfile="/var/log/sudo.log"

5.3.4

# grep -r "^[^#].*NOPASSWD" /etc/sudoers*

5.3.5

# grep -r "^[^#].*\!authenticate" /etc/sudoers*

5.3.6

# cat /etc/sudoers | grep time
Defaults    timestamp_timeout=5

1.5.1

# cat /etc/systemd/coredump.conf | grep Storage
Storage=none

2.3.1

# rpm -q telnet
package telnet is not installed

2.3.2

# rpm -q openldap-clients
package openldap-clients is not installed

2.3.3

# rpm -q tftp
package tftp is not installed

2.3.4

# rpm -q ftp
package ftp is not installed

5.6.1.1

# grep PASS_MAX_DAYS /etc/login.defs
PASS_MAX_DAYS	365

```

## 2. Conf SSH

![SSH](./img/ssh.jpg)

🌞 **Chiffrement fort côté serveur**

- trouver une ressource de confiance (je veux le lien en compte-rendu)
- configurer le serveur SSH pour qu'il utilise des paramètres forts en terme de chiffrement (je veux le fichier de conf dans le compte-rendu)
  - conf dans le fichier de conf
  - regénérer des clés pour le serveur ?
  - regénérer les paramètres Diffie-Hellman ? (se renseigner sur Diffie-Hellman ?)

🌞 **Clés de chiffrement fortes pour le client**

- trouver une ressource de confiance (je veux le lien en compte-rendu)
- générez-vous une paire de clés qui utilise un chiffrement fort et une passphrase
- ne soyez pas non plus absurdes dans le choix du chiffrement quand je dis "fort" (genre pas de RSA avec une clé de taile 98789080932083209 bytes)

🌞 **Connectez-vous en SSH à votre VM avec cette paire de clés**

- prouvez en ajoutant `-vvvv` sur la commande `ssh` de connexion que vous utilisez bien cette clé là

## 4. DoT

Ca commence à faire quelques années maintenant que plusieurs acteurs poussent pour qu'on fasse du DNS chiffré, et qu'on arrête d'envoyer des requêtes DNS en clair dans tous les sens.

Le Dot est une techno qui va dans ce sens : DoT pour DNS over TLS. On fait nos requêtes DNS dans des tunnels chiffrés avec le protocole TLS.

🌞 **Configurer la machine pour qu'elle fasse du DoT**

- installez `systemd-networkd` sur la machine pour ça
- activez aussi DNSSEC tant qu'on y est
- référez-vous à cette doc qui est cool par exemple
- utilisez le serveur public de CloudFlare : 1.1.1.1 (il supporte le DoT)

🌞 **Prouvez que les requêtes DNS effectuées par la machine...**

- ont une réponse qui provient du serveur que vous avez conf (normalement c'est `127.0.0.1` avec `systemd-networkd` qui tourne)
  - quand on fait un `dig ynov.com` on voit en bas quel serveur a répondu
- mais qu'en réalité, la requête a été forward vers 1.1.1.1 avec du TLS
  - je veux une capture Wireshark à l'appui !

## 5. AIDE

Un truc demandé au point 1.3.1 du guide CIS c'est d'installer AIDE.

AIDE est un IDS ou *Intrusion Detection System*. Les IDS c'est un type de programme dont les fonctions peuvent être multiples.

Dans notre cas, AIDE, il surveille que certains fichiers du disque n'ont pas été modifiés. Des fichiers comme `/etc/shadow` par exemple.

🌞 **Installer et configurer AIDE**

- et bah incroyable mais [une très bonne ressource ici](https://www.it-connect.fr/aide-utilisation-et-configuration-dune-solution-de-controle-dintegrite-sous-linux/)
- configurez AIDE pour qu'il surveille (fichier de conf en compte-rendu)
  - le fichier de conf du serveur SSH
  - le fichier de conf du client chrony (le service qui gère le temps)
  - le fichier de conf de `systemd-networkd`

🌞 **Scénario de modification**

- introduisez une modification dans le fichier de conf du serveur SSH
- montrez que AIDE peut la détecter

🌞 **Timer et service systemd**

- créez un service systemd qui exécute un check AIDE
  - il faut créer un fichier `.service` dans le dossier `/etc/systemd/system/`
  - contenu du fichier à montrer dans le compte rendu
- créez un timer systemd qui exécute un check AIDE toutes les 10 minutes
  - il faut créer un fichier `.timer` dans le dossier `/etc/systemd/system/`
  - il doit porter le même nom que le service, genre `aide.service` et `aide.timer`
  - c'est complètement irréaliste 10 minutes, mais ça vous permettra de faire des tests (vous pouvez même raccourcir encore)
