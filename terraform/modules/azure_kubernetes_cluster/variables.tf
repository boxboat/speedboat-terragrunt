variable "scope" {
  type        = string
  description = "Identifier added as a suffix to resource names."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group to create the cluster within."
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
variable "full_admin_users" {
  type        = list(string)
  description = "Email addresses of users to provision full admin access"
  default     = []
}

variable "container_registry_id" {
  type        = string
  description = "Azure resource id for the container registry to grant AKS pull against."
}