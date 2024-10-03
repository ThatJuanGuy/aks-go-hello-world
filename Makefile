all:
	# staticaly compile the go binary executable
	CGO_ENABLED=0 go build ./
	# build the imager
	docker build -t TODO.azurecr.io/myapp:latest .
	# login to the azure container registry and upload the image
	az acr login -n TODO
	docker push TODO.azurecr.io/myapp:latest
