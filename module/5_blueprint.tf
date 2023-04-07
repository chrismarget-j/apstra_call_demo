# https://cloudlabs.apstra.com/labguide/Cloudlabs/4.1.2/lab1-junos/lab1-junos-6_blueprints_.html

# Instantiate a blueprint from the previously-created template
resource "apstra_datacenter_blueprint" "lab_guide" {
  name        = var.name_prefix
  template_id = apstra_template_rack_based.lab_guide.id
}

# Assign previously-created ASN resource pools to roles in the fabric
locals { asn_roles = toset(["spine_asns", "leaf_asns"]) }
resource "apstra_datacenter_resource_pool_allocation" "lab_guide_asn" {
  for_each     = local.asn_roles
  blueprint_id = apstra_datacenter_blueprint.lab_guide.id
  role         = each.key
  pool_ids     = [apstra_asn_pool.lab_guide.id]
}

# Assign previously-created IPv4 resource pools to roles in the fabric
locals { ipv4_roles = toset(["spine_loopback_ips", "leaf_loopback_ips", "spine_leaf_link_ips"]) }
resource "apstra_datacenter_resource_pool_allocation" "lab_guide_ipv4" {
  for_each     = local.ipv4_roles
  blueprint_id = apstra_datacenter_blueprint.lab_guide.id
  role         = each.key
  pool_ids     = [apstra_ipv4_pool.lab_guide.id]
}

# Discover details (we need the ID) of an interface map using the name supplied
# in the lab guide.
data "apstra_interface_map" "lab_guide" {
  name = "Juniper_vEX__slicer-7x10-1"
}

locals {
  switches = [
  "spine1",
  "spine2",
  "${var.name_prefix}_esi_001_leaf1",
  "${var.name_prefix}_esi_001_leaf2",
  "${var.name_prefix}_single_001_leaf1",
  ]
}

# Assign interface map and system IDs using the map we created earlier
resource "apstra_datacenter_device_allocation" "lab_guide" {
#  depends_on = [apstra_managed_device.lab_guide]
  for_each         = toset(local.switches)
  blueprint_id     = apstra_datacenter_blueprint.lab_guide.id
  interface_map_id = data.apstra_interface_map.lab_guide.id
  node_name        = lower(trimprefix(each.key, "_"))
}

# Deploy the blueprint.
resource "apstra_blueprint_deployment" "lab_guide" {
  blueprint_id = apstra_datacenter_blueprint.lab_guide.id
  comment      = "Deployed during the Apstra Abstract call by $USER using Terraform v{{.TerraformVersion}} and plugin v{{.ProviderVersion}}"
  depends_on = [
    # Lots of terraform happens in parallel -- this section forces deployment
    # to wait until resources which modify the blueprint are complete.
    apstra_datacenter_device_allocation.lab_guide,
    apstra_datacenter_resource_pool_allocation.lab_guide_asn,
    apstra_datacenter_resource_pool_allocation.lab_guide_ipv4,
  ]
}
