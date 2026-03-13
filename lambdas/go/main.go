package main

import (
	"context"
	"github.com/aws/aws-lambda-go/lambda"
)

type Response struct {
	Runtime string `json:"runtime"`
	Status  string `json:"status"`
	Version string `json:"version"`
}

func handler(ctx context.Context) (Response, error) {
	_ = ctx
	return Response{Runtime: "go", Status: "ok", Version: "1.0.0"}, nil
}

func main() {
	lambda.Start(handler)
}
