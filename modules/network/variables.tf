variable "compartment_id" { type = string }
variable "name" {
  type        = string
  default     = "vcn"
  description = "The name of the VCN which will be used in FQDN"
}

variable "cidr_block" {
  type        = string
  default     = "192.168.0.0/16"
  description = "The CIDR block for the VCN"
}

variable "private_subnets" {
  type = map(object({
    name              = string
    cidr_block        = string
    security_list_ids = list(string)
    optionals         = any # map(any)
    # The followings are the keys for the optionals with defaults in brackets
    # route_table_id = string # id of custom route table
  }))

  description = <<EOL
  map of subnet object configurations. Key is used as subnet name in the FQDN (as dns_label)
    name             : the display name of the subnet (node dns_label can't be updated)
    cidr_block       : the cidr block for the subnet
    security_list_ids: list of security ids to be attached to the subnet
    optionals        : map of optional values
      route_table_id: route table id to be used instead of default one
  EOL
}

variable "public_subnets" {
  type = map(object({
    name              = string
    cidr_block        = string
    security_list_ids = list(string)
    optionals         = map(any)
    # The followings are the keys for the optionals with defaults in brackets
    # route_table_id = string # id of custom route table
  }))

  description = <<EOL
  map of subnet object configurations. Key is used as subnet name in the FQDN (as dns_label)
    name             : the display name of the subnet (node dns_label can't be updated)
    cidr_block       : the cidr block for the subnet
    security_list_ids: list of security ids to be attached to the subnet
    optionals        : map of optional values
      route_table_id: route table id to be used instead of defaul one
  EOL
}

variable "public_route_table_rules" {
  type = map(object({
    destination       = string
    destination_type  = string
    network_entity_id = string
  }))
  default = {}

  description = <<EOL
  map of route table configurations. Key is used as route table rule name
    destination      : IP or OCID of oracle service (oci-phx-objectstorage)
    destination_type : The type of destination above
    network_entity_id: The OCID for the route rule's target
  EOL
}

variable "private_route_table_rules" {
  type = map(object({
    destination       = string
    destination_type  = string
    network_entity_id = string
  }))
  default = {}

  description = <<EOL
  map of route table configurations. Key is used as route table rule name
    destination      : IP or OCID of oracle service (oci-phx-objectstorage)
    destination_type : The type of destination above
    network_entity_id: The OCID for the route rule's target
  EOL
}

variable "default_security_list_rules" {
  type = object({
    public_subnets = object({
      tcp_egress_ports_to_all    = list(number)
      tcp_ingress_ports_from_all = list(number)
      udp_egress_ports_to_all    = list(number)
      udp_ingress_ports_from_all = list(number)
      enable_icpm_from_all       = bool
      enable_icpm_to_all         = bool
    })
    private_subnets = object({
      tcp_egress_ports_to_all    = list(number)
      tcp_ingress_ports_from_vcn = list(number)
      udp_egress_ports_to_all    = list(number)
      udp_ingress_ports_from_vcn = list(number)
      enable_icpm_from_vcn       = bool
      enable_icpm_to_all         = bool
    })
  })

  default = {
    public_subnets = {
      tcp_egress_ports_to_all    = []
      tcp_ingress_ports_from_all = []
      udp_egress_ports_to_all    = []
      udp_ingress_ports_from_all = []
      enable_icpm_from_all       = false
      enable_icpm_to_all         = false
    }
    private_subnets = {
      tcp_egress_ports_to_all    = []
      tcp_ingress_ports_from_vcn = []
      udp_egress_ports_to_all    = []
      udp_ingress_ports_from_vcn = []
      enable_icpm_from_vcn       = false
      enable_icpm_to_all         = false
    }
  }
  description = "map of objects for allowed tcp and udp ingress/egress ports to the internet (0.0.0.0/0)"
}

variable "nat_configuration" {
  type = object({
    public_ip_id  = string
    block_traffic = bool
  })
  default = {
    block_traffic = false
    public_ip_id  = ""
  }

  description = <<EOF
    map of object to configure NAT
      public_ip_id: ID of reserved public IP. Leave empty if you want oci to create random public IP
      block_traffic: disable traffic on the NAT
  EOF
}

variable "enable_internet_gateway" {
  type    = bool
  default = true
}
