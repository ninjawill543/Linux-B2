# II. Images

- [II. Images](#ii-images)
  - [1. Images publiques](#1-images-publiques)
  - [2. Construire une image](#2-construire-une-image)

## 1. Images publiques

🌞 **Récupérez des images**

```
$ docker images
REPOSITORY           TAG       IMAGE ID       CREATED        SIZE
linuxserver/wikijs   latest    869729f6d3c5   5 days ago     441MB
mysql                5.7       5107333e08a8   8 days ago     501MB
python               latest    fc7a60e86bae   13 days ago    1.02GB
wordpress            latest    fd2f5a0c6fba   2 weeks ago    739MB
python               3.11      22140cbb3b0c   2 weeks ago    1.01GB
nginx                latest    d453dd892d93   8 weeks ago    187MB
hello-world          latest    d2c94e258dcb   7 months ago   13.3kB
```

🌞 **Lancez un conteneur à partir de l'image Python**

```
$ docker run -it python:3.11 bash
root@245920d8f8ba:/# python --version
Python 3.11.7
```
## 2. Construire une image

Pour construire une image il faut :

- créer un fichier `Dockerfile`
- exécuter une commande `docker build` pour produire une image à partir du `Dockerfile`

🌞 **Ecrire un Dockerfile pour une image qui héberge une application Python**
```
FROM debian

RUN apt-get update -y && apt install -y python3

RUN apt install -y python3-emoji

COPY app.py /home/app.py

ENTRYPOINT ["python3", "/home/app.py"]
```

🌞 **Build l'image**

```
$ docker build . -t python_app:1
```

🌞 **Lancer l'image**

```
$ docker run python_app:1
Cet exemple d'application est vraiment naze 👎
```
