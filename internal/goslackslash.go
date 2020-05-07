// Package contains an HTTP function that replies for slack slash command.
package internal

import (
	"bytes"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"

	"github.com/slack-go/slack"
)

var categories = []string{"animal", "career", "celebrity", "dev", "explicit", "fashion", "food", "history", "money", "movie", "music", "political", "religion", "science", "sport", "travel"}

type APIResponse struct {
	Categories []string `json:"categories"`
	CreatedAt  string   `json:"created_at"`
	IconUrl    string   `json:"icon_url"`
	Id         string   `json:"id"`
	UpdatedAt  string   `json:"updated_at"`
	Url        string   `json:"url"`
	Value      string   `json:"value"`
}

func SlashCommandHandler(w http.ResponseWriter, r *http.Request) {

	s, err := slack.SlashCommandParse(r)

	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	log.Printf("%+v\n", s)

	token := os.Getenv("SLACK_VERIFICATION_TOKEN")
	if !s.ValidateToken(token) || token == "" {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	switch s.Command {
	case "/chuck":
		params := &slack.Msg{Text: s.Text}
		text := params.Text

		if text != "" && text != "list" && !IsValidCategory(text) {
			response := fmt.Sprintf("Unknown command. List categories with 'list' option. List of available categories: %v", strings.Join(categories, ", "))
			_, err = w.Write([]byte(response))
			if err != nil {
				log.Fatal(err)
			}
		} else if text == "list" {
			response := fmt.Sprintf("Available categories: %v", strings.Join(categories, ", "))
			_, err = w.Write([]byte(response))
			if err != nil {
				log.Fatal(err)
			}
		} else {

			buf := bytes.Buffer{}
			buf.WriteString("https://api.chucknorris.io/jokes/random")
			if IsValidCategory(text) {
				buf.WriteString("?category=")
				buf.WriteString(text)
			}

			url := buf.String()

			req, err := http.NewRequest("GET", url, nil)
			if err != nil {
				log.Fatal(err)
			}

			client := &http.Client{}
			resp, err := client.Do(req)
			if err != nil {
				log.Fatal(err)
			}

			defer resp.Body.Close()

			if resp.StatusCode == http.StatusOK {
				apiResponse := &APIResponse{}

				err = json.NewDecoder(resp.Body).Decode(&apiResponse)
				if err != nil {
					log.Fatal(err)
				}

				response := fmt.Sprintf("%v", apiResponse.Value)
				_, err = w.Write([]byte(response))
				if err != nil {
					log.Fatal(err)
				}
			}
		}

	default:
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

}

func IsValidCategory(category string) bool {
	for _, existingsCcategory := range categories {
		if existingsCcategory == category {
			return true
		}
	}
	return false
}
