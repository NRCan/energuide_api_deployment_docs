#!/bin/sh

APPS="deploy_etl deploy_endpoint deploy_api" 
RESOURCE_GROUP="NRCanGroup"


az login --service-principal -u ${AZURE_SERVICE_PRINCIPAL} --tenant ${AZURE_TENANT_ID} -p ${AZURE_SERVICE_PRINCIPAL_PASSWORD}

if [ $? -eq 1 ]; then
  exit 1
fi

for i in $APPS; do
  echo "Validating ${i}......"
  az group deployment validate --template-file ${i}.json --resource-group ${RESOURCE_GROUP} --parameters ${i}-params.json 
done

