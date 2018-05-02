
[La version française suit.](#---------------------------------------------------------------------)

[![CircleCI](https://circleci.com/gh/cds-snc/nrcan-infra.svg?style=svg)](https://circleci.com/gh/cds-snc/nrcan-infra)

NRCAN
------

Deployment documentation for the NRCan API, Endpoint and Extractor.

Configuration
=============


Azure Setup
-----------


Use the appropriate subscription id 

```
az account set -s "my subscription name"
```

Create a Resource Group:

```
az group create --name MyGroup -l canadaeast
```

Set the application name
```
appName="nrcanapi"
```

Create an Azure AD app

```
az ad app create \
    --display-name $appName \
    --homepage "https://energuideapi.ca" \
    --identifier-uris [https://energuideapi.ca](https://energuideapi.ca)
```

Get the appID

```
appId=$(az ad app list --display-name $appName --query [].appId -o tsv)
```

Set a password

```
spPassword="SecurePassword123"
```

Now create the service principal and restrict it to the ResourceGroup you created above.


```
az ad sp create-for-rbac --name $appId --password $spPassword \
                --role contributor \
                --scopes /subscriptions/$subscriptionId/resourceGroups/MyGroup
```

Create a Service Plan

```
az appservice plan create -g NRCanGroup -n webapplinux --is-linux -l canadaeast
```

Azure Web App for Containers
----------------------------

Log in to the Service Principal

```
az login --service-principal -u sp-id --tenant tenant-id
```

The Azure Web App for Containers is created using an ARM template called deploy_api.json. The template should be executed as follows:
```
az group deployment create -n AppName --resource-group MyGroup --template-file deploy_api.json
```
The template will ask for `App Service Plan ID`, `App Name`, `Docker Image`, `Collection Name`, `Connection String`, `DB Name`, and `API Key`

* Enabling Continuous Deployment

`az webapp deployment container config -n AppName -g ResourceGroupName -e true`

```
{
  "CI_CD_URL": "https://$nrcan123252637:PASSWORDHERE@nrcan123252637.scm.azurewebsites.net/docker/hook",
  "DOCKER_ENABLE_CI": true
}
```


Azure Function App
------------------

The Endpoint Extractor runs as an Azure Function App. There's an ARM template called `deploy_etl.json` that will set up the function service for you. You need to specify the the app name, docker image, and the storage connection string.

The ETL also runs as an Azure Function App. There's an ARM template called `deploy_etl.json` that will set up the function app.  You need to specify the app name and docker image.


CircleCI
--------
We're using Circle CI to run continuous integration and continuous deployment of the NRCAN API repository. There's a job called `deploy` in `.circle/config.yml` that controls the build and deploy of the Docker image.  For each commit to master, the `deploy_api` and `deploy_etl` jobs will build a docker image and push it to Docker Hub with tag "latest" as well as the SHA from the last commit.  

Docker Hub
----------
When a new image arrives at Docker Hub, a webhook is sent to Azure and the Azure App Service for Containers will download and deploy the "latest" image.

Get the webhook ID:

`az webapp deployment container show-cd-url -n appName -g MyGroup`

```
{
  "CI_CD_URL": "https://$appName:PASSWORDHERE@appName.scm.azurewebsites.net/docker/hook",
  "DOCKER_ENABLE_CI": true
}
```

Add the CI_CD_URL to your Docker repository: Click Webhooks, and add your Webhook URL.


When a new image arrives at Docker Hub, Docker will send a webhook to the appropriate NRCan Azure resources.



DNS
===
Configure a custom DNS name: In the Azure portal, open the App Resource, click "Custom domains", click "+ Add hostname", enter your custom hostname. You must create a CNAME or A record prior prior adding the custom domain.
(this should be added to the ARM template....)

Troubleshooting
===============

Download all logs as a zip:
`az webapp log download --resource-group MyGroup --name AppName`

## ---------------------------------------------------------------------

[![CircleCI](https://circleci.com/gh/cds-snc/nrcan-infra.svg?style=svg)](https://circleci.com/gh/cds-snc/nrcan-infra)

# RNCan

La documentation de déploiement pour l’API de RNCan, le point d'extrémité et l’extracteur.

## Configuration

### Configuration d'Azure 

Utilisez l’identifiant d’inscription approprié 
```
az account set -s "my subscription name"
```
Créez un groupe de ressources :
```
az group create --name MyGroup -l canadaeast
```
Établissez le nom d’application 
```
appName="nrcanapi"
```
Créez une application du domaine administratif (AD) d’Azure 
```
az ad app create \
    --display-name $appName \
    --homepage "https://energuideapi.ca" \
    --identifier-uris [https://energuideapi.ca](https://energuideapi.ca)
```
Obtenez l’identifiant (ID) de l’application 
```
appId=$(az ad app list --display-name $appName --query [].appId -o tsv)
```
Définissez un mot de passe 
```
spPassword="SecurePassword123"
```

Maintenant créez le principal du service et limitez-le au groupe de ressources que vous avez créé ci-dessus. 

```
az ad sp create-for-rbac --name $appId --password $spPassword \
                --role contributor \
                --scopes /subscriptions/$subscriptionId/resourceGroups/MyGroup
```

Créez un plan de services 

```
az appservice plan create -g NRCanGroup -n webapplinux --is-linux -l canadaeast
```

## Application Web Azure pour les conteneurs 

Connectez-vous au principal du service

```
az login --service-principal -u sp-id --tenant tenant-id
```

L’application Web Azure pour les conteneurs est créée en utilisant un modèle de gestionnaire de ressource d’Azure (ARM) appelé deploy_api.json. Le modèle devrait être exécuté comme ceci :
```
az group deployment create -n AppName --resource-group MyGroup --template-file deploy_api.json
```
Le modèle demandera ceci : identifiant du plan de service pour l’application, nom de l’application, l’image du menu fixe, le nom de la collection, chaîne de connexion, nom de bases de données, et une clé de l’API. 

* Permettre le déploiement continu 

az webapp deployment container config -n AppName -g ResourceGroupName -e true
```
{
  "CI_CD_URL": "https://$nrcan123252637:PASSWORDHERE@nrcan123252637.scm.azurewebsites.net/docker/hook",
  "DOCKER_ENABLE_CI": true
}
```

## Fonction de l’application d’Azure 

L’extracteur du point d’extrémité fonctionne comme une fonction de l’application Azure. Il existe un modèle de gestionnaire de ressource d’Azure (ARM) appelé deploy_etl.json qui installera la fonction de service pour vous. Vous devrez spécifier le nom de l’application, l’image du menu fixe, et la chaîne de connexion du stockage.
L’ETC fonctionne aussi comme une fonction de l’application Azure. Il existe un modèle ARM appelé deploy_etl.json qui installera la fonction de l’application. Vous devrez spécifier le nom de l’application et l’image du menu fixe.

## CircleCI
Nous utilisons le CircleCI pour exécuter l’intégration continue et le déploiement continu de la logithèque de référence de l’API du RNCan. Il y a un travail appelé deploy en .circle/config.yml qui contrôle le programme de construction et de déploiement de l’image Docker. Pour chaque sauvegarde à la branche maîtresse (master), les travaux de deploy_api et de deploy_etl construiront une image Docker et le pousseront au Docker Hub avec l’étiquette « latest » ainsi que l’algorithme de hachage sécurisé du dernier « commit ».

## Hub de Docker

Lorsqu’une nouvelle image arrive au hub de Docker, un rappel Web est envoyé à Azure et le service d’application d’Azure (App Service) pour les conteneurs téléchargeront et déploieront la « dernière » image.

Pour obtenir l'identifiant du rappel Web :

az webapp deployment container show-cd-url -n appName -g MyGroup
```
{
  "CI_CD_URL": "https://$appName:PASSWORDHERE@appName.scm.azurewebsites.net/docker/hook",
  "DOCKER_ENABLE_CI": true
}
```

Pour ajouter le CI_CD_URL à votre logithèque de référence du menu fixe : Cliquez sur rappels Web (WebHooks), et ajoutez votre URL au rappel Web.

Lorsqu’une nouvelle image arrive au hub de Docker, le menu fixe envoie un rappel Web aux ressources d’Azure de RNCan appropriées.

## Système de nom de domaine (DNS)

Configurez un nom du DNS personnalisé : dans le portail, ouvrez la ressource de l’application, cliquez sur « domaines personnalisés », cliquez « + Ajouter le nom de l’hôte », entrez votre nom de l’hôte personnalisé. Vous devez créer un enregistrement CNAME ou A avant d’ajouter le domaine personnalisé. (Cela devrait être ajouté au modèle ARM)

## Résolution des problèmes 
Téléchargez tous les journaux sous forme d’un zip : az webapp log download --resource-group MyGroup --name AppName


