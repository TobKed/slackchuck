// The cmd command starts an HTTP server.
package main

import (
	"log"
	"net/http"
	"os"

	"github.com/TobKed/slackchuck"
)

func main() {
	http.HandleFunc("/", slackchuck.SlashCommandHandler)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	log.Printf("Listening on port %s", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatal(err)
	}
}
