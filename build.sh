#!/bin/sh

echo building..

# Add the commit ID and build number to the title of the UI
text="GIT_COMMIT is ${env.GIT_COMMIT} build ID: ${env.BUILD_ID}" 
sed -i "s/^TITLE.*/TITLE = ${text}/" ./azure-vote/azure-vote/config_file.cfg
 
# Build new image and push to ACR.
WEB_IMAGE_NAME="${ACR_LOGINSERVER}/azure-vote-front:kube${BUILD_NUMBER}"
docker build -t $WEB_IMAGE_NAME ./azure-vote
docker login ${ACR_LOGINSERVER} -u ${ACR_ID} -p ${ACR_PASSWORD}
docker push $WEB_IMAGE_NAME