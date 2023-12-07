build:
	rm -r bin
	GOOS=linux GOARCH=amd64 go build -o bin/create-order lambda/create-order/main.go
	GOOS=linux GOARCH=amd64 go build -o bin/process-order lambda/process-order/main.go
	zip bin/create-order.zip bin/create-order
	zip bin/process-order.zip bin/process-order