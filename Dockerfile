# This will create a minimal image
FROM scratch
# Copy your binary to the image. Assumes the binary has already been compiled to "myapp"
COPY myapp myapp
# Specifies the container image will run the following executable
ENTRYPOINT [ "/myapp" ]
