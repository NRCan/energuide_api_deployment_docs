#!/bin/sh

APPS="deploy_etl deploy_endpoint" 
RESOURCE_GROUP="NRCanGroup"


az login --service-principal -u ${AZURE_SERVICE_PRINCIPAL} --tenant ${AZURE_TENANT_ID} -p ${AZURE_SERVICE_PRINCIPAL_PASSWORD}

for i in $APPS; do
  az group deployment validate --template-file ${i}.json --resource-group ${RESOURCE_GROUP} --parameters ${i}-params.json 
done

