# aks-go-hello-world
Contains an example/barebones starter code for setting up and running a basic golang app for AKS clusters.

## Prequisites
1) Install go
2) Create an azure account and subscription
2) Install azure cli
3) Install kubectl

## Write some application code
This refers to the code you want to run on the kubernetes cluster. In this case it is main.go

## Create a dockerfile to build the image
If writing a go app that uses https and using the "SCRATCH" base image in docker, include the following as an import in the application code to make sure you have the required certificates. 

```go
_ "golang.org/x/crypto/x509roots/fallback"
```

## Create an azure resource group
``` bash
# You can pick any name you want to use for this. For the sake of the demo, use only alphanumeric characters
export RESOURCE_GROUP="TODO"
# Pick an azure region. ex) eastus
export LOCATION="TODO"
# Use your azure subscription id
export SUBSCRIPTION="TODO"

az account set --subscription "${SUBSCRIPTION}"
az group create --name "${RESOURCE_GROUP}" --location "${LOCATION}"
```

## Create an azure container registry (ACR)
ACR will host the image of your app. Enabling anonymous pull simplifies the setup but means that anyone with the url will be able to pull your image. 

``` bash
export ACR_NAME="${RESOURCE_GROUP}"acr
az acr create -n "${ACR_NAME}" -g "${RESOURCE_GROUP}" --sku standard
az acr update --name "${ACR_NAME}" --anonymous-pull-enabled
```

## Build your image and push it to azure container registry
This is done by the Makefile. Replace the "TODO"s with the name of your acr and then run `make` from the project root directory.

## Create an AKS Cluster
``` bash
export CLUSTER_NAME="${RESOURCE_GROUP}"-cluster
az aks create -g "${RESOURCE_GROUP}" -n "${CLUSTER_NAME}"
```

## Deploy your app
Run the following command to get the kubeconfig to connect to your cluster with kubectl.
``` bash
az aks get-credentials -g "${RESOURCE_GROUP}" -n "${CLUSTER_NAME}"
```

Run the following to create a deployment using the image containing your app
``` bash
kubectl create deployment mydeployment --image="${ACR_NAME}".azurecr.io/myapp:latest
```

You can the run `kubectl get pods` to find the pod whose name has the prefix "mydeployment". Then run `kubectl logs TODO_name_of_the_pod`. The logs should contain "Hello, World!".