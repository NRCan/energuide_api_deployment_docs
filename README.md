   * [NRCAN API, ETL and Endpoint](#nrcan)
   * [Configuration](#configuration)
      * [Azure Setup](#azure-setup)
      * [Azure Web App for Containers](#azure-web-app-for-containers)
      * [Azure Function App](#azure-function-app)
      * [CircleCI](#circleci)
      * [Docker Hub](#docker-hub)
      * [DNS](#dns)
   * [Troubleshooting](#troubleshooting)

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

