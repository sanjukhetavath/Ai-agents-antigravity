variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region to deploy resources into"
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resource group"
  type        = map(string)
  default     = {}
}
