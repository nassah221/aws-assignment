package main

import (
	"context"
	"fmt"
	"log"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/sqs"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

func getDBConn() (*gorm.DB, error) {
	username := os.Getenv("DB_USER")
	password := os.Getenv("DB_PASS")
	dbName := os.Getenv("DB_NAME")
	dbHost := os.Getenv("DB_HOST")
	dbURI := fmt.Sprintf("host=%s user=%s dbname=%s sslmode=disable password=%s", dbHost, username, dbName, password)
	return gorm.Open(mysql.New(mysql.Config{DSN: dbURI}), &gorm.Config{})
}

func HandleRequest(ctx context.Context, event *events.SQSEvent) error {
	log.Println(event)

	svc := sqs.New(queueSession)
	out, err := svc.ReceiveMessage(&sqs.ReceiveMessageInput{MaxNumberOfMessages: aws.Int64(1), QueueUrl: &queueURL})
	if err != nil {
		panic(err)
	}

	for _, msg := range out.Messages {
		log.Println(msg)
	}

	return nil
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
