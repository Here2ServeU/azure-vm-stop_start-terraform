variable "location" {
  description = "The Azure region to deploy resources"
  type        = string
  default     = "East US"
}

variable "vm_ids" {
  description = "List of VM IDs to start and stop"
  type        = list(string)
}

variable "start_schedule" {
  description = "Cron expression for the start schedule"
  type        = string
}

variable "stop_schedule" {
  description = "Cron expression for the stop schedule"
  type        = string
}

variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string
}
