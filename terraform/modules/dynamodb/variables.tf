variable "region" {
  type = string
}

variable "table_name" {
  type = string
}

variable "hash_key" {
  description = "The hash key for the DynamoDB table"
  type        = string
}

variable "range_key" {
  description = "The range key for the DynamoDB table"
  type        = string
}

variable "hash_key_type" {
  description = "Type for the hash key (S, N, or B)"
  type        = string
  default     = "S"
}

variable "range_key_type" {
  description = "Type for the range key (S, N, or B)"
  type        = string
  default     = "N"
}

variable "project" {
  description = "Name of project"
  type        = string
}


