package main

import (
	"context"
	"errors"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

type GetOrdersResponse struct {
	Orders []Orders `json:"orders,omitempty"`
}

type Orders struct {
	gorm.Model
	Date   time.Time `json:"date"`
	ID     string    `json:"id"`
	Status string    `json:"status"`
	Total  float64   `json:"total"`
}

func getDBConn() (*gorm.DB, error) {
	username := os.Getenv("DB_USER")
	password := os.Getenv("DB_PASS")
	dbName := os.Getenv("DB_NAME")
	dbHost := os.Getenv("DB_HOST")
	dbURI := fmt.Sprintf("host=%s user=%s dbname=%s sslmode=disable password=%s", dbHost, username, dbName, password)
	return gorm.Open(mysql.New(mysql.Config{DSN: dbURI}), &gorm.Config{})
}

func HandleRequest(ctx context.Context, event *events.APIGatewayV2HTTPRequest) (*GetOrdersResponse, error) {
	db, err := getDBConn()
	if err != nil {
		log.Println(err)
		return nil, errors.New("failed to get db connection")
	}
	if err := db.AutoMigrate(&Orders{}); err != nil {
		log.Println(err)
		return nil, errors.New("failed to create orders table")
	}

	userID := event.PathParameters["user_id"]

	orders := make([]Orders, 0)
	db.Where("user_id = ?", userID).Find(&orders)

	return &GetOrdersResponse{
		Orders: orders,
	}, nil
}

func main() {
	lambda.Start(HandleRequest)
}
