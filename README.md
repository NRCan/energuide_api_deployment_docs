## ROUGH documentation.
### CircleCI -> Docker
On commit to master, Circle CI will build a docker image and tag it with $VERSION (defined by VERSION in CircleCI's config.yml) as well as 'latest'. After the image is built, Circle CI will push the image to Docker Hub.

### Docker Hub <-> Azure
When a new image arrives at Docker Hub, a webhook is sent to Azure and the Azure App Server for Containers will download the "latest" image. 

### Creating the Azure Web App for Containers

The Azure Web App for Containers is created using an ARM template called template.json. The template should be executed as follows:
```
az group deployment create -n ContainerName --resource-group ResourceGoupName --template-file template.json
```
The template will ask for several parameters. 

### Enabling Continuous Deployment
```az webapp deployment container config -n nrcan123252637 -g templatenrcan -e true
{
  "CI_CD_URL": "https://$nrcan123252637:PASSWORDHERE@nrcan123252637.scm.azurewebsites.net/docker/hook",
  "DOCKER_ENABLE_CI": true
}```

# Show the continuous delivery url

```az webapp deployment container show-cd-url -n nrcan123252637 -g templatenrcan
{
  "CI_CD_URL": "https://$nrcan123252637:PASSWORDHERE@nrcan123252637.scm.azurewebsites.net/docker/hook",
  "DOCKER_ENABLE_CI": true
}
```

### Add the URL to docker hub (to come)
