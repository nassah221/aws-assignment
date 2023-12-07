package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/sqs"
)

type Request struct {
	FirstName string `json:"firstName"`
	LastName  string `json:"lastName"`
}

type ResponseBody struct {
	Message string `json:"message"`
}

func HandleRequest(ctx context.Context, event *events.APIGatewayV2HTTPRequest) (*events.APIGatewayV2HTTPResponse, error) {
	log.Println("event", event)

	log.Println("event route key", event.RouteKey)

	var req Request
	if err := json.Unmarshal([]byte(event.Body), &req); err != nil {
		return nil, err
	}

	resp := ResponseBody{
		Message: fmt.Sprintf("Hello %s %s. You are awesome", req.FirstName, req.LastName),
	}
	b, err := json.Marshal(resp)
	if err != nil {
		return nil, err
	}

	svc := sqs.New(queueSession)

	_, err = svc.SendMessage(&sqs.SendMessageInput{
		DelaySeconds: aws.Int64(10),
		MessageAttributes: map[string]*sqs.MessageAttributeValue{
			"Title": {
				DataType:    aws.String("String"),
				StringValue: aws.String("The Whistler"),
			},
			"Author": {
				DataType:    aws.String("String"),
				StringValue: aws.String("John Grisham"),
			},
			"WeeksOn": {
				DataType:    aws.String("Number"),
				StringValue: aws.String("6"),
			},
		},
		MessageBody: aws.String(string(b)),
		QueueUrl:    &queueURL,
	})

	return &events.APIGatewayV2HTTPResponse{
		StatusCode: 200,
		Body:       string(b),
		Headers: map[string]string{
			"Content-Type": "application/json",
		},
	}, nil
}

var (
	queueURL     string
	queueSession *session.Session
)

func main() {
	queueURL = os.Getenv("SQS_QUEUE_NAME")
	if queueURL == "" {
		panic("SQS_QUEUE_NAME is not set")
	}

	queueSession = session.Must(session.NewSessionWithOptions(session.Options{SharedConfigState: session.SharedConfigEnable}))

	lambda.Start(HandleRequest)
}
