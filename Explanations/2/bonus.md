# Bonus CI/CD

Ptit bonus pour mettre en place un peu de CI/CD.

On va juste survoler pour voir un peu les portes que ça ouvre.

## Sommaire

- [Bonus CI/CD](#bonus-cicd)
  - [Sommaire](#sommaire)
- [0. Setup](#0-setup)
- [I. Premiers pas CI](#i-premiers-pas-ci)
  - [1. Préparation runner](#1-préparation-runner)
  - [2. Une première pipeline](#2-une-première-pipeline)
  - [3. Quelques idées pour la pipeline](#3-quelques-idées-pour-la-pipeline)
- [II. Premier déploiement CD](#ii-premier-déploiement-cd)
  - [1. Préparation](#1-préparation)
    - [A. SSH](#a-ssh)
    - [B. Gitlab](#b-gitlab)
  - [2. Déploiement automatique : CD](#2-déploiement-automatique--cd)
- [III. Cas concret ?](#iii-cas-concret-)

# 0. Setup

Munissez-vous de :

- un nouveau dépot sur [l'instance publique de Gitlab](https://gitlab.com)
- une VM Linux dans VBox sur votre PC
  - Rocky Linux c'est très bien
  - on l'appellera `runner.bonus` dans ce TP
  - elle hébergera le Runner Gitlab
  - il faudra installer Docker sur cette machine
- une deuxième VM Linux, accessible depuis Internet
  - ce sera le "serveur de production"
  - on l'appellera `prod.bonus` dans ce TP
  - il faudra installer Docker sur cette machine

# I. Premiers pas CI

## 1. Préparation runner

➜ **A réaliser sur `runner.bonus`**

🌞 **Préparer un fichier de conf pour le Runner**

- créez un répertoire `runner/conf/` (dans votre homedir par exemple)
- créez un fichier `runner/conf/config.toml` avec le contenu suivant :

```toml
concurrent = 4
```

> *Juste une conf minimale pour que le Runner accepte de se lancer. Le fichier de conf va être rempli automatiquement par une commande qu'on lancera un plus plus tard.*

🌞 **Lancer le Runner**

- on va lancer le Runner avec un conteneur Docker, utilisez la commande suivante :

```bash
docker run -d --name gitlab-runner --restart always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /path/vers/runner/conf:/etc/gitlab-runner \
    gitlab/gitlab-runner:latest
```

➜ **Pour l'étape suivante il vous faut récupérer le *token* de votre dépôt Git**

- RDV sur la WebUI de Gitlab, sur votre dépôt
- onglet Settings > CI/CD > Runner et y'a un ptit bouton pour récup votre token

🌞 **Effectue un *register* depuis le Runner**

- utilisez `docker exec` pour récupérer un shell dans le conteneur
- une fois dans le conteneur, exécutez la commande suivante :

```bash
gitlab-runner register
```

➜ **Répondez correctement au prompt, en particulier :**

- on utilise https://gitlab.com
- saisissez votre token
- choisissez un nom cool (arbitraire)
- pour ce qui est du tag, c'est arbitraire, on va pas s'en servir nous
- quand on vous demande de choisir un "executor", on utilisera "docker"
- le reste on s'en fout
- ça génère automatiquement de la conf dans le fichier `config.toml`
  - on aurait pu l'écrire direct et ça aurait fonctionné
  - j'trouve ça cool de vous montrer ça

➜ **Ne passez à la suite que si vous voyez votre Runner remonter dans la WebUI de Gitlab (Settings > CI/CD > Runner)**

- doit y'avoir son ptit nom et un ptit rond vert
- une fois que c'est fait, allez dans la conf de votre runner (toujours sur la WebUI Gitlab)
  - cocher une case pour que le Runner accepte de prendre les jobs qui ne sont pas taggés

## 2. Une première pipeline

🌞 **Créer un fichier `.gitlab-ci.yml`**

- il décrit les étapes à réaliser automatiquement à chaque push
- utilisez le contenu simpliste suivant :

```yml
stages:
  - mon_premier_stage

prout:
  stage: mon_premier_stage
  image: python
  script:
    - cat /etc/os-release
    - python --version
    - ls -al
```

- effectuez un push qui ajoute ce fichier
- RDV sur la WebUI de Gitlab > CI/CD pour voir votre job `prout` s'exécuter

> Avec le `ls -al` vous devriez voir que tout le dépôt git est disponible. Autrement dit, si votre dépoôt Git contient du vrai code, on peut agir sur le code. C'est un peu le but en même temps :D

## 3. Quelques idées pour la pipeline

➜ **Check de syntaxe**

- genre on pourrait vérifier la conformité PEP8

➜ **Construction d'une image Docker**

- p'tit `docker build` dans un stage de build dédié
- chaque dépôt Gitlab est équipé d'un registre Docker
- vous pouvez donc `docker push` l'image dans le registre de votre dépôt
- Gitlab c'est public, donc n'importe qui peut `git pull` l'image ensuite (un serveur de prod par exemple ?)

# II. Premier déploiement CD

## 1. Préparation

### A. SSH

🌞 **Générez une nouvelle paire de clés SSH**

- cette paire de clés sera utilisée par la pipeline, pas par vous
- donc on crée une nouvelle paire

🌞 **Déposer la clé publique sur `prod.bonus`**

- peu importe sur quel user pour le moment, on fait un POC :)
- assurez-vous que vous pouvez vous y connecter

### B. Gitlab

🌞 **Créer une variable de CI qui contient la clé privée**

- WebUI Gitlab, sur votre projet > Settings > CI/CD > Variables
- créez une nouvelle variable que vous appelez `PRIVATE_KEY`
- le contenu doit être le résultat de la commande suivante :

```bash
cat /path/vers/la/clé/privée/id_rsa | base64 -w0
```

Ok, donc la clé publique est déposée sur `prod.bonus` et la on peut accéder à la clé privée dans la pipeline en utilisant la variable `PRIVATE_KEY`.

## 2. Déploiement automatique : CD

On va setup un déploiement automatisé : dès qu'on push sur le dépôt Git, une action est effectuée sur le serveur `prod.bonus` à travers une connexion SSH.

Le moyen recommandé pour faire ça c'est d'utiliser un agent SSH (`ssh-agent` et `ssh-add`).

🌞 **Adaptez votre `.gitlab-ci.yml`**

- avec le contenu suivant :

```yml
stages:
  - build
  - deploy

just_a_test:
  stage: build
  image: python
  script:
    - cat /etc/os-release
    - python --version

deploy_to_prod:
  stage: deploy
  image: debian
  before_script:
    - 'command -v ssh-agent >/dev/null || ( apt-get update -y && apt-get install openssh-client -y )'
    - eval $(ssh-agent -s)
    - mkdir ~/.ssh && chmod 700 ~/.ssh 
    - echo "$PRIVATE_KEY" | base64 -d | tr -d '\r' | ssh-add - 
    - ssh-keyscan prod.bonus > ~/.ssh/known_hosts
  script:
    - ssh <USER>@prod.bonus whoami
```

- confirmez la bonne exécution de votre pipeline depuis la WebUI de Gitlab

# III. Cas concret ?

Pour un cas concret, vous pouvez utilisez votre app Symfony :

- un dépôt git qui contient
  - votre code PHP
  - un `docker-compose.yml` qui lance la stack que vous avez fait au TP2 (3 conteneurs PHP/Apache, MySQL et PHPMyAdmin)
  - `Dockerfile` si besoin pour build votre image PHP avec votre code
  - un `.gitlab-ci.yml`
- le `.gitlab-ci.yml`
  - un stage `build`
    - un job `syntax`
      - vérifie la bonne syntaxe du `docker-compose.yml`
      - vérifie la conformité du code PHP avec un standard
    - un job `docker_build`
      - construit une image Docker
      - push l'image Docker dans le registre Gitlab
  - un stage `deploy`
    - un job `prod`
      - lance la stack `docker-compose.yml` sur `prod.bonus`
