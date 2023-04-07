variable "name_prefix" {
  type        = string
  description = "Prefix used in resource names"
}

variable "ipv4_info" {
  type = object({
    allocation   = string
    subnet_count = number
    subnet_size  = number
  })
}

variable "asn_range" {
  type = object({
    first = number
    last  = number
  })
}

output "ipv4_info" {
  value = var.ipv4_info
}


