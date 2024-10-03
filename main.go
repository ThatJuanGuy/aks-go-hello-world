package main

import (
	"fmt"
	"time"

	// This import includes some certificates that are needed for https to be used when the base image does not provide them.
	// An example of this is the scratch image in the Dockerfile.
	_ "golang.org/x/crypto/x509roots/fallback"
)

func main() {
	// The loop keeps the pod from exiting once it's done
	for {
		time.Sleep(10 * time.Second)
		fmt.Print("Hello, World!\n")
	}
}
