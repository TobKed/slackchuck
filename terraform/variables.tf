variable "project_id" {
  type        = string
  description = "Google Project ID"
}

variable "region" {
  type        = string
  default     = "europe-west3"
  description = "Google Project Region"
}


variable "slack_verification_token" {
  type        = string
  description = "Slack verification token"
}
