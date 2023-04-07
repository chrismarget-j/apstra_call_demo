data "apstra_logical_device" "lab_guide_switch" {
  name = "virtual-7x10-1"
}

locals {
  single_leaf = "${var.name_prefix}-single-leaf"
  esi_leaf = "${var.name_prefix}-esi-leaf"
}

resource "apstra_rack_type" "lab_guide_single" {
  name                       = "${var.name_prefix}-single"
  fabric_connectivity_design = "l3clos"
  leaf_switches = {
    (local.single_leaf) = {
      logical_device_id = data.apstra_logical_device.lab_guide_switch.id
      spine_link_count  = 1
      spine_link_speed  = "10G"
    }
  }
  generic_systems = {
    single-server = {
      count             = 1
      logical_device_id = data.apstra_logical_device.lab_guide_servers["single_homed"].id
      links = {
        single-link = {
          target_switch_name = local.single_leaf
          speed              = "10G"
        }
      }
    }
  }
}

locals {
  servers = {
    single_homed = "AOS-1x10-1"
    dual_homed   = "AOS-2x10-1"
  }
}
data "apstra_logical_device" "lab_guide_servers" {
  for_each = local.servers
  name = each.value
}

resource "apstra_rack_type" "lab_guide_esi" {
  name                       = "${var.name_prefix}-esi"
  fabric_connectivity_design = "l3clos"
  leaf_switches = {
    (local.esi_leaf) = {
      logical_device_id   = data.apstra_logical_device.lab_guide_switch.id
      spine_link_count    = 1
      spine_link_speed    = "10G"
      redundancy_protocol = "esi"
    }
  }
  generic_systems = {
    dual-server = {
      count             = 1
      logical_device_id = data.apstra_logical_device.lab_guide_servers["dual_homed"].id
      links = {
        esi-link = {
          target_switch_name = local.esi_leaf
          speed              = "10G"
          lag_mode           = "lacp_active"
        }
      }
    }
    single-server-1 = {
      count             = 1
      logical_device_id = data.apstra_logical_device.lab_guide_servers["single_homed"].id
      links = {
        single-link = {
          target_switch_name = local.esi_leaf
          speed              = "10G"
          switch_peer        = "first"
        }
      }
    }
    single-server-2 = {
      count             = 1
      logical_device_id = data.apstra_logical_device.lab_guide_servers["single_homed"].id
      links = {
        single-link = {
          target_switch_name = local.esi_leaf
          speed              = "10G"
          switch_peer        = "second"
        }
      }
    }
  }
}
