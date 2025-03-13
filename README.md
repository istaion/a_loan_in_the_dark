# a_loan_in_the_dark

## Description

Ce projet consiste à déployer une application **Django** et une API **FastAPI** sur **Azure Container Instances (ACI)**. Les ressources Azure sont gérées à l'aide de **Terraform**. Ce README explique les étapes de déploiement et la configuration nécessaire pour faire fonctionner le projet.

## Prérequis

Avant de commencer, assure-toi d'avoir installé les outils suivants :

- **Terraform** : pour gérer l'infrastructure sur Azure.
  - Si ce n'est pas encore fait, tu peux installer Terraform en suivant [ces instructions](https://learn.hashicorp.com/tutorials/terraform/install-cli).
- **Azure CLI** : pour interagir avec Azure et déployer les conteneurs.
  - Installation de l'Azure CLI disponible [ici](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).
- **jq** : un utilitaire pour traiter le JSON (utilisé dans les scripts `.sh`).
  - Installation disponible [ici](https://stedolan.github.io/jq/download/).

## 0. Créer et Pousser les Images Docker sur Azure

##  0.1 Créer l'image Docker pour Django

1. Navigue vers le répertoire contenant le Dockerfile de Django :

   ```bash
   cd django_a_loan_in_the_dark
   ```

2. Construire l'image Docker pour Django : Utilise la commande suivante pour créer l'image Docker pour l'application Django.

   ```bash
   docker build -t vpoutotregistry.azurecr.io/djangoloan:v2 .
   ```

3. Se connecter à Azure Container Registry (ACR) : Avant de pousser l'image, tu dois te connecter à ton registre Azure Container Registry.

   ```bash
   az acr login --name vpoutotregistry
   ```
4. Pousser l'image Docker sur Azure Container Registry : Une fois l'image construite et que tu es connecté à ACR, tu peux pousser l'image Docker vers Azure.

   ```bash
   docker push vpoutotregistry.azurecr.io/djangoloan:v2
   ```

##  0.2 Créer l'image Docker pour FastAPI

1. Navigue vers le répertoire contenant le Dockerfile de FastAPI :

   ```bash
   cd ../fastAPI_django_a_loan_in_the_dark
   ```

2. Construire l'image Docker pour FastAPI : Utilise la commande suivante pour créer l'image Docker pour l'API FastAPI.

   ```bash
   docker build -t vpoutotregistry.azurecr.io/fastapiloan:latest .
   ```

3. Pousser l'image Docker sur Azure Container Registry : Une fois l'image construite, pousse-la sur Azure Container Registry avec la commande suivante :

   ```bash
   docker push vpoutotregistry.azurecr.io/fastapiloan:latest
   ```
4. Pousser l'image Docker sur Azure Container Registry : Une fois l'image construite et que tu es connecté à ACR, tu peux pousser l'image Docker vers Azure.

   ```bash
   docker push vpoutotregistry.azurecr.io/djangoloan:v2
   ```
## 1. Déployer l'infrastructure avec Terraform

### Étape 1 : Initialiser Terraform

1. Clone ce dépôt ou accède au répertoire contenant ton code Terraform.
2. Initialise Terraform avec la commande suivante :
   ```bash
   terraform init
   ```

### Étape 2 : Configurer les variables

Crée un fichier terraform.tfvars dans le même répertoire que ton fichier main.tf. Voici un exemple de contenu pour ce fichier terraform.tfvars (les valeurs doivent être modifiées pour ton propre environnement) :
```
secret_key = "votre_valeur_secret_key"
access_token_expire_minutes = 30
db_server = "vpoutotsqlserver.database.windows.net"
db_name_api = "DB_API_a_loan_in_the_dark"
db_name_django = "DB_django_a_loan_in_the_dark"
db_user = "ladysimplon"
db_password = "votre_mot_de_passe"
api_base_url = "http://98.66.197.221:80"
django_secret_key = "votre_django_secret_key"
debug = false
email_host_password1 = "motdepasse1"
email_host_password2 = "motdepasse2"
email_host_password3 = "motdepasse3"
email_host_password4 = "motdepasse4"
acr_username = "vpoutotRegistry"
acr_password = "votre_mot_de_passe_acr"
```

### Étape 3 : Appliquer la configuration Terraform

Une fois les variables configurées, applique la configuration Terraform pour créer les ressources dans Azure :
   ```bash
   terraform apply
   ```

Note : Si une ressource existe déjà, mais n'a pas été créée par Terraform, tu devras l'importer avec la commande terraform import.

##  2 Déployer les conteneurs avec les scripts deploy_django.sh et deploy_fastapi_aci.sh

### 2.1 Déployer l'API FastAPI
L'API FastAPI doit être déployée avant Django. Voici les étapes pour le faire via le script deploy_fastapi_aci.sh.

1. Crée un fichier .env dans le répertoire fastAPI_a_loan_in_the_dark/ avec le contenu suivant (ajuste les valeurs selon ton environnement) :
   ```.env
    SECRET_KEY=9Cxkw50nQotQVv1XnVwzA8jNfHPFkDMQ
    ACCESS_TOKEN_EXPIRE_MINUTES=30
    DB_SERVER=vpoutotsqlserver.database.windows.net
    DB_NAME=DB_API_a_loan_in_the_dark
    DB_USER=ladysimplon
    DB_PASSWORD=(great)lady12
   ```
2. Exécute le script deploy_fastapi_aci.sh pour déployer l'API FastAPI sur Azure Container Instances :
   ```bash
   ./deploy_fastapi_aci.sh
   ```

### 2.2 Déployer Django
Une fois l'API FastAPI déployée et en fonctionnement, tu peux déployer Django avec le script deploy_django.sh. Voici les étapes pour cela :
1. Crée un fichier .env dans le répertoire django_a_loan_in_the_dark/ avec le contenu suivant (ajuste les valeurs selon ton environnement) :
   ```.env
    API_BASE_URL=http://98.66.197.221:80
    DJANGO_SECRET_KEY=secretkey
    DEBUG=False
    EMAIL_HOST_PASSWORD1=pass1
    EMAIL_HOST_PASSWORD2=pass2
    EMAIL_HOST_PASSWORD3=pass3
    EMAIL_HOST_PASSWORD4=pass4
    DB_SERVER=serveradresse
    DB_NAME=DB_django_a_loan_in_the_dark
    DB_USER=username
    DB_PASSWORD=userpassword
   ```
2. Exécute le script deploy_django.sh pour déployer l'application Django sur Azure Container Instances :
   ```bash
   ./deploy_django.sh
   ```

### 2.3 Variables dans .env
Les deux scripts de déploiement (Django et FastAPI) dépendent de variables d'environnement définies dans leurs fichiers .env respectifs. Assure-toi que les fichiers .env contiennent toutes les variables nécessaires pour que les conteneurs puissent démarrer correctement.

## 3. Résumé des variables d'environnement

### 3.1 Variables dans terraform.tfvars
Ces variables sont utilisées pour configurer les ressources Azure via Terraform.

  *  secret_key: Clé secrète pour l'application FastAPI
  *  access_token_expire_minutes: Durée d'expiration du token pour FastAPI
  *  db_server: Serveur de base de données
  *  db_name_api: Nom de la base de données pour l'API FastAPI
  *  db_name_django: Nom de la base de données pour Django
  *  db_user: Utilisateur de la base de données
  *  db_password: Mot de passe pour la base de données
  *  api_base_url: URL de l'API FastAPI
  *  django_secret_key: Clé secrète pour Django
  *  debug: Valeur pour activer/désactiver le mode debug dans Django
  *  email_host_password1,2,3,4: Clé de mot de passe pour Gmail (divisée pour éviter des erreurs de format)
  *  acr_username: Nom d'utilisateur pour l'Azure Container Registry
  *  acr_password: Mot de passe pour l'Azure Container Registry

### 3.2 Variables dans .env
Dans fastAPI_a_loan_in_the_dark/.env :

 *   SECRET_KEY: Clé secrète pour FastAPI
 *   ACCESS_TOKEN_EXPIRE_MINUTES: Durée d'expiration du token pour FastAPI
 *   DB_SERVER: Serveur de base de données
 *   DB_NAME: Nom de la base de données pour FastAPI
 *   DB_USER: Utilisateur de la base de données
 *   DB_PASSWORD: Mot de passe pour la base de données

Dans django_a_loan_in_the_dark/.env :

  *  API_BASE_URL: URL de l'API FastAPI
  *  DJANGO_SECRET_KEY: Clé secrète pour Django
  *  DEBUG: Valeur pour activer/désactiver le mode debug dans Django
  *  EMAIL_HOST_PASSWORD1,2,3,4: Clé de mot de passe pour Gmail
  *  DB_SERVER: Serveur de base de données
  *  DB_NAME: Nom de la base de données pour Django
  *  DB_USER: Utilisateur de la base de données
  *  DB_PASSWORD: Mot de passe pour la base de données
