# https://cloudlabs.apstra.com/labguide/Cloudlabs/4.1.2/lab1-junos/lab1-junos-5_devmgnt.html

#resource "apstra_agent_profile" "lab_guide" {
#  name = "vqfx"
#}

#locals {
#  switches = {
#    spine1                  = { management_ip = "172.20.113.11", device_key = "52540037AB37" }
#    spine2                  = { management_ip = "172.20.113.12", device_key = "5254005D14DA" }
#    apstra_esi_001_leaf1    = { management_ip = "172.20.113.13", device_key = "5254008BA2D1" }
#    apstra_esi_001_leaf2    = { management_ip = "172.20.113.15", device_key = "525400106025" }
#    apstra_single_001_leaf1 = { management_ip = "172.20.113.14", device_key = "5254000E7AB0" }
#  }
#}

## Onboard each switch. This will be a comparatively long "terraform apply".
#resource "apstra_managed_device" "lab_guide" {
#  for_each         = local.switches
#  agent_profile_id = apstra_agent_profile.lab_guide.id
#  off_box          = true
#  management_ip    = each.value.management_ip
#  device_key       = each.value.device_key
#}
