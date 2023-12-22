# I. Init

- [I. Init](#i-init)
  - [1. Installation de Docker](#1-installation-de-docker)
  - [2. Vérifier que Docker est bien là](#2-vérifier-que-docker-est-bien-là)
  - [3. sudo c pa bo](#3-sudo-c-pa-bo)
  - [4. Un premier conteneur en vif](#4-un-premier-conteneur-en-vif)
  - [5. Un deuxième conteneur en vif](#5-un-deuxième-conteneur-en-vif)

## 1. Installation de Docker


## 2. Vérifier que Docker est bien là


## 3. sudo c pa bo


🌞 **Ajouter votre utilisateur au groupe `docker`**

```
$ sudo usermod -aG docker $USER
```

## 4. Un premier conteneur en vif


🌞 **Lancer un conteneur NGINX**

- avec la commande suivante :

```bash
docker run -d -p 9999:80 nginx
```
```
$ docker run -d -p 9999:80 nginx
Unable to find image 'nginx:latest' locally
latest: Pulling from library/nginx
af107e978371: Pull complete 
336ba1f05c3e: Pull complete 
8c37d2ff6efa: Pull complete 
51d6357098de: Pull complete 
782f1ecce57d: Pull complete 
5e99d351b073: Pull complete 
7b73345df136: Pull complete 
Digest: sha256:bd30b8d47b230de52431cc71c5cce149b8d5d4c87c204902acf2504435d4b4c9
Status: Downloaded newer image for nginx:latest
df3898bfdd9de4a48638d9a8d68a4ca1a7efdd79e2e08c9debe9e2e778f60650
```

🌞 **Visitons**

- vérifier que le conteneur est actif avec une commande qui liste les conteneurs en cours de fonctionnement
```
$ docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED              STATUS              PORTS                                   NAMES
df3898bfdd9d   nginx     "/docker-entrypoint.…"   About a minute ago   Up About a minute   0.0.0.0:9999->80/tcp, :::9999->80/tcp   quizzical_moore
```
- afficher les logs du conteneur
```
$ docker logs df
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2023/12/21 09:35:47 [notice] 1#1: using the "epoll" event method
2023/12/21 09:35:47 [notice] 1#1: nginx/1.25.3
2023/12/21 09:35:47 [notice] 1#1: built by gcc 12.2.0 (Debian 12.2.0-14) 
2023/12/21 09:35:47 [notice] 1#1: OS: Linux 6.2.0-39-generic
2023/12/21 09:35:47 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
2023/12/21 09:35:47 [notice] 1#1: start worker processes
2023/12/21 09:35:47 [notice] 1#1: start worker process 29
2023/12/21 09:35:47 [notice] 1#1: start worker process 30
2023/12/21 09:35:47 [notice] 1#1: start worker process 31
2023/12/21 09:35:47 [notice] 1#1: start worker process 32
2023/12/21 09:35:47 [notice] 1#1: start worker process 33
2023/12/21 09:35:47 [notice] 1#1: start worker process 34
2023/12/21 09:35:47 [notice] 1#1: start worker process 35
2023/12/21 09:35:47 [notice] 1#1: start worker process 36
```

- afficher toutes les informations relatives au conteneur avec une commande `docker inspect`
```
$ docker inspect df
```

- afficher le port en écoute sur la VM avec un `sudo ss -lnpt`
```
$ sudo ss -ltnp | grep docker
LISTEN 0      4096         0.0.0.0:9999      0.0.0.0:*    users:(("docker-proxy",pid=12200,fd=4))  
LISTEN 0      4096            [::]:9999         [::]:*    users:(("docker-proxy",pid=12206,fd=4))  
```
- ouvrir le port `9999/tcp` (vu dans le `ss` au dessus normalement) dans le firewall de la VM
```
$ sudo ufw allow 9999/tcp
```
- depuis le navigateur de votre PC, visiter le site web sur `http://IP_VM:9999`
```
$ curl localhost:9999
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

🌞 **On va ajouter un site Web au conteneur NGINX**


```html
<h1>MEOOOW</h1>
```

- config NGINX minimale pour servir un nouveau site web dans `site_nul.conf` :

```nginx
server {
    listen        8080;

    location / {
        root /var/www/html/index.html;
    }
}
```


```bash
$ docker run -d -p 9999:8080 -v /home/$USER/nginx/index.html:/var/www/html/index.html -v /home/$USER/nginx/site_nul.conf:/etc/nginx/conf.d/site_nul.conf nginx
```

🌞 **Visitons**

- vérifier que le conteneur est actif
```
$ docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS          PORTS                                               NAMES
a08426c617f1   nginx     "/docker-entrypoint.…"   12 minutes ago   Up 12 minutes   80/tcp, 0.0.0.0:9999->8080/tcp, :::9999->8080/tcp   kind_neumann
```
- aucun port firewall à ouvrir : on écoute toujours port 9999 sur la machine hôte (la VM)
- visiter le site web depuis votre PC

```
$ curl localhost:9999
<h1>bing bong</h1>
```

## 5. Un deuxième conteneur en vif



🌞 **Lance un conteneur Python, avec un shell**

```
$ docker run -it python bash
Unable to find image 'python:latest' locally
latest: Pulling from library/python
bc0734b949dc: Pull complete 
b5de22c0f5cd: Pull complete 
917ee5330e73: Pull complete 
b43bd898d5fb: Pull complete 
7fad4bffde24: Pull complete 
d685eb68699f: Pull complete 
107007f161d0: Pull complete 
02b85463d724: Pull complete 
Digest: sha256:3733015cdd1bd7d9a0b9fe21a925b608de82131aa4f3d397e465a1fcb545d36f
Status: Downloaded newer image for python:latest
root@c4e9a6dbb36b:/# 
```

🌞 **Installe des libs Python**

- une fois que vous avez lancé le conteneur, et que vous êtes dedans avec `bash`
- installez deux libs, elles ont été choisies complètement au hasard (avec la commande `pip install`):
- `aiohttp`
```
root@c4e9a6dbb36b:/# pip install aiohttp
```
  - `aioconsole`
```
root@c4e9a6dbb36b:/# pip install aioconsole
```
- tapez la commande `python` pour ouvrir un interpréteur Python
- taper la ligne `import aiohttp` pour vérifier que vous avez bien téléchargé la lib
```
root@c4e9a6dbb36b:/# python
Python 3.12.1 (main, Dec 19 2023, 20:14:15) [GCC 12.2.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import aiohttp
```

> *Notez que la commande `pip` est déjà présente. En effet, c'est un conteneur `python`, donc les mecs qui l'ont construit ont fourni la commande `pip` avec !*

➜ **Tant que t'as un shell dans un conteneur**, tu peux en profiter pour te balader. Tu peux notamment remarquer :

- si tu fais des `ls` un peu partout, que le conteneur a sa propre arborescence de fichiers
- si t'essaies d'utiliser des commandes usuelles un poil évoluées, elles sont pas là
  - genre t'as pas `ip a` ou ce genre de trucs
  - un conteneur on essaie de le rendre le plus léger possible
  - donc on enlève tout ce qui n'est pas nécessaire par rapport à un vrai OS
  - juste une application et ses dépendances
