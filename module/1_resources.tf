resource "apstra_asn_pool" "lab_guide" {
  name = var.name_prefix
  ranges = [
    {
      first = var.asn_range.first
      last  = var.asn_range.last
    },
  ]
}

locals {
  allocation_bits = parseint(split("/", var.ipv4_info.allocation)[1], 10)
  newbits         = var.ipv4_info.subnet_size - local.allocation_bits
}

resource "apstra_ipv4_pool" "lab_guide" {
  name = var.name_prefix
  subnets = [
    for i in range(var.ipv4_info.subnet_count) : {
      network = cidrsubnet(var.ipv4_info.allocation, local.newbits, i)
    }
  ]
}
