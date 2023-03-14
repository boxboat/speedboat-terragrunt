variable "scope" {
  type        = string
  description = "Identifier added as a suffix to resource names."
}

variable "location" {
  type        = string
  description = "Region for resources to created in."
  default     = "eastus"
}

variable "tags" {
  type        = map(string)
  description = "Tags to include for any resources supporting them."
  default     = {}
}

# don't have access to AzureAD, so falling back on per user provisioning
variable "registry_users" {
  type        = list(string)
  description = "Email addresses of users to provision full admin access"
  default     = []
}
