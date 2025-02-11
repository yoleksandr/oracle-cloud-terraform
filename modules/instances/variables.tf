
locals {
  default_primary_config = {
    primary_ip    = ""
    secondary_ips = {}
  }
}

variable "instances" {
  type = map(object({
    name                     = string
    availability_domain_name = string
    fault_domain_name        = string
    compartment_id           = string
    volume_size              = number
    state                    = string
    autherized_keys          = string
    config = object({
      shape             = string
      flex_shape_config = map(string)
      image_id          = string
      network_sgs_ids   = list(string)
      subnet = object({
        id                         = string,
        prohibit_public_ip_on_vnic = bool
      })
      primary_vnic = object({
        primary_ip = string
        secondary_ips = map(object({
          name       = string
          ip_address = string
        }))
      })
    })
    secondary_vnics = map(object({
      name                   = string
      primary_ip             = string
      subnet_id              = string
      nsg_ids                = list(string)
      skip_source_dest_check = bool
      hostname_label         = string
      secondary_ips = map(object({
        name       = string
        ip_address = string
      }))
    }))
    optionals = map(any)
    # preserve_boot_volume =  bool (true)
  }))
  description = <<EOF
    map of objects that represent instances to create. The key name is the instance name that is used for FQDN
    name                    : the name of instance
    availability_domain_name: the name of the availability domain to create instance in
    fault_domain_name       : the name of the fault domain in the availability domain to create instance in
    compartment_id          : ocid of the compartment
    volume_size             : the initial boot volume size in GB
    state                   : RUNNING or STOPPED
    autherized_keys         : single string containing the SSH-RSA keys seperated by \n
    config                  : object of instance configuration
      shape           : name of the VM shape to be used
      flex_shape_config     : customize number of ocpus and memory when using Flex Shape
      image_id        : ocid of the boot image
      network_sgs_ids : list network security groups ids to be applied to the main interface
      subnet          : object for the subnet configuration
        id                         : ocid of the subnet
        prohibit_public_ip_on_vnic : whether to create public IP or not if located in public subnet, set to false if not
      primary_vnic : object for primary VNIC configuration
        primary_ip    : custom initial IP. If left empty, oci will create IP dynamically.
        secondary_ips : map of objects for secondary IP configuration
          name         : the name of IP
          ip_address   : custom IP that must be in the same subnet above of VNIC. If left empty, oci will create IP dynamically
    secondary_vnics: map of object for secondary VNIC configuration
      name       = the name of VNIC
      primary_ip =  custom initial IP. If left empty, oci will create IP dynamically.
      subnet_id  = subnet id for creating the VNIC in
      nsg_ids    = list network security groups ids to be applied to the VNIC
      skip_source_dest_check = bool (false)
      hostname_label         = string (null)
      secondary_ips = map of objects for secondary IP configuration
        name       = string
        ip_address = string
    optionals : set of key/value map that can be used for customise default values.
      preserve_boot_volume  : whether to keep boot volume after delete or not
  EOF

  validation {
    condition = alltrue(flatten([
      for k, v in var.instances : [
        for key in keys(v.config.flex_shape_config) :
        contains(["ocpus", "memory_in_gbs"], key)
      ]
    ]))
    error_message = "The instances.*.config.flex_shape_config accepts only \"ocpus\", \"memory_in_gbs\"."
  }
}
