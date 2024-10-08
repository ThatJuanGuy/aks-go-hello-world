# aks-go-hello-world
Contains an example/barebones starter code for setting up and running a basic Go app for AKS clusters.

## Introduction
- Our simple Go app is one that loops forever, printing "Hello, World!" to stdout and sleeping for 10 seconds.
- We'll compile it statically, so that it has no dependencies on any other files in the container image (CGO_ENABLED=0).
  This enables us to use the `scratch` (empty) Docker base image in order to minimize our image size.
- One detail of using the `scratch` image is that it doesn't include a CA bundle, which is needed if your application connects to other services using TLS.
  In Golang, this can be resolved by importing the `golang.org/x/crypto/x509roots/fallback` package to include a recent CA bundle inside the application binary.
- We'll use Azure Container Registry (ACR) to store our container image.  For simplicity, we'll enable anonymous pull so that our AKS cluster doesn't need to authenticate to ACR.
- We'll use `kubectl create deployment` to easily create a Kubernetes deployment for our app.

## Prequisites
1) Create an Azure account and subscription
2) Install [Go](https://go.dev/dl/)
3) Install [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
4) Install kubectl (run `az aks install-cli`)

## Write some application code
This refers to the code you want to run on the Kubernetes cluster. In this case, see the main.go example file.

If writing a Go app that uses TLS/https and is based on the "scratch" base image in docker, include the following as an import in the application code to make sure you have the required certificates.

```go
import (
    _ "golang.org/x/crypto/x509roots/fallback"
)
```

## Create a Dockerfile to build the image
See the Dockerfile example file.

## Create an Azure resource group
``` bash
# You can pick any name you want to use for this. For the sake of the demo, use only alphanumeric characters
RESOURCE_GROUP="${USER}-demo"
# Pick an azure region. ex) eastus
LOCATION="eastus"

az login
az group create --name "${RESOURCE_GROUP}" --location "${LOCATION}"
```

## Create an Azure Container Registry (ACR)
ACR will host the image of your app. Enabling anonymous pull simplifies the setup but means that anyone with the url will be able to pull your image. 

``` bash
export ACR_NAME="${USER}"demoacr
az acr create -n "${ACR_NAME}" -g "${RESOURCE_GROUP}" --sku standard
az acr update --name "${ACR_NAME}" --anonymous-pull-enabled
```

## Build your image and push it to ACR
This is done by the Makefile.

``` bash
make
```

You can validate that the compiled Go binary has no library dependencies by using `ldd`:

``` bash
ldd myapp # prints "not a dynamic executable"
```

## Create an AKS Cluster
``` bash
CLUSTER_NAME="${RESOURCE_GROUP}"-cluster
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

You can the run `kubectl get pods` to find the pod whose name has the prefix "mydeployment". Then run `kubectl logs -l app=mydeployment`. The logs should contain "Hello, World!".

## References

- https://docs.docker.com/guides/language/golang/build-images/