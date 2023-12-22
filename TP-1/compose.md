# III. Docker compose

Pour la fin de ce TP on va manipuler un peu `docker compose`.

🌞 **Créez un fichier `docker-compose.yml`**

- dans un nouveau dossier dédié `/home/<USER>/compose_test`
- le contenu est le suivant :

```yml
version: "3"

services:
  conteneur_nul:
    image: debian
    cmd: sleep 9999
  conteneur_flopesque:
    image: debian
    cmd: sleep 9999
```


🌞 **Lancez les deux conteneurs** avec `docker compose`

```
$ docker compose up -d
[+] Running 3/3
 ✔ conteneur_flopesque Pulled                                                                   2.8s 
 ✔ conteneur_nul 1 layers [⣿]      0B/0B      Pulled                                            2.6s 
   ✔ bc0734b949dc Already exists                                                                0.0s 
[+] Running 3/3
 ✔ Network compose_test_default                  Created                                        0.1s 
 ✔ Container compose_test-conteneur_nul-1        St...                                          0.0s 
 ✔ Container compose_test-conteneur_flopesque-1  Started                                        0.0s 
```

🌞 **Vérifier que les deux conteneurs tournent**

```
$ docker ps
CONTAINER ID   IMAGE     COMMAND        CREATED              STATUS              PORTS     NAMES
256cded8b3cc   debian    "sleep 9999"   About a minute ago   Up About a minute             compose_test-conteneur_nul-1
bd97997dc7be   debian    "sleep 9999"   About a minute ago   Up About a minute             compose_test-conteneur_flopesque-1
```

🌞 **Pop un shell dans le conteneur `conteneur_nul`**
```
$ docker exec -it compose_test-conteneur_nul-1 bash
```
```
root@256cded8b3cc:/# apt update && apt install iputils-ping
```
```
root@256cded8b3cc:/# ping -c 1 compose_test-conteneur_flopesque-1
PING compose_test-conteneur_flopesque-1 (172.18.0.2) 56(84) bytes of data.
64 bytes from compose_test-conteneur_flopesque-1.compose_test_default (172.18.0.2): icmp_seq=1 ttl=64 time=0.075 ms

--- compose_test-conteneur_flopesque-1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.075/0.075/0.075/0.000 ms

```

![In the future](./img/in_the_future.jpg)