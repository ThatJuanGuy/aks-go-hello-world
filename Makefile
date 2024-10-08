all:
	# statically compile the go binary executable
	CGO_ENABLED=0 go build ./
	# build the image
	docker build -t $(ACR_NAME).azurecr.io/myapp:latest .
	# login to the azure container registry and upload the image
	az acr login -n $(ACR_NAME)
	docker push $(ACR_NAME).azurecr.io/myapp:latest
