package test

import (
	"net/http"
	"net/http/httptest"
	"net/url"
	"os"
	"strings"
	"testing"

	"github.com/TobKed/slackchuck"
)

func TestSlashCommandHandlerFaileAutorization(t *testing.T) {
	rr := httptest.NewRecorder()
	req := httptest.NewRequest("GET", "/", nil)
	slackchuck.SlashCommandHandler(rr, req)
	if rr.Result().StatusCode != http.StatusUnauthorized {
		t.Errorf("Gopher StatusCode = %v, want %v", rr.Result().StatusCode, http.StatusUnauthorized)
	}
}

func TestSlashCommandHandler(t *testing.T) {
	os.Setenv("SLACK_VERIFICATION_TOKEN", "faketoken")
	data := url.Values{}
	data.Set("token", "faketoken")
	data.Set("command", "/chuck")
	rr := httptest.NewRecorder()
	req := httptest.NewRequest("POST", "/", strings.NewReader(data.Encode()))
	req.Header.Add("Content-Type", "application/x-www-form-urlencoded")
	slackchuck.SlashCommandHandler(rr, req)
	if rr.Result().StatusCode != http.StatusOK {
		t.Errorf("Gopher StatusCode = %v, want %v", rr.Result().StatusCode, http.StatusOK)
	}
}
