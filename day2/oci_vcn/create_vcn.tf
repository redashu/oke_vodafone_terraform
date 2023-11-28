resource "oci_core_vcn" "ashu_oke_vcn-new" {

    cidr_block = var.oci_cidr
    dns_label = "ashucvn1"
    compartment_id = var.oci_compartment-id
    display_name = "ashu-terraform-vcn-new"
}

# creating public subnet 
resource "oci_core_subnet" "public_subnet" {
    cidr_block     = var.vcn_public_subnet
    display_name   = "ashuPublicSubnet"
    vcn_id         = "${oci_core_vcn.ashu_oke_vcn-new.id}"
    compartment_id = var.oci_compartment-id
    # adding routing table
    route_table_id = oci_core_route_table.ashupublic_route_table.id
}

# creating private subnet 
resource "oci_core_subnet" "private_subnet" {
    cidr_block     = var.vcn_private_subnet
    display_name   = "ashuPrivateSubnet"
    vcn_id         = "${oci_core_vcn.ashu_oke_vcn-new.id}"
    compartment_id = var.oci_compartment-id
    # adding routing table 
    route_table_id = oci_core_route_table.private_route_table.id
}
# creating public IP for Nat gw
## creating Nat gateway 
resource "oci_core_nat_gateway" "ashu_nat_gateway" {
  compartment_id = var.oci_compartment-id
  vcn_id         = oci_core_vcn.ashu_oke_vcn-new.id
  display_name   = "ashuNatGateway"
  block_traffic = false  # to allow any outgoing traffic
  #public_ip_id   = oci_core_public_ip.ashu_public_ip.id 
}

# creating routing table first

# creating routing rules with nat gw
resource "oci_core_route_table" "private_route_table" {
  compartment_id = var.oci_compartment-id
  display_name   = "ashu-private-route-table"
  vcn_id         = oci_core_vcn.ashu_oke_vcn-new.id
# routing rule 
  route_rules {
    destination          = "0.0.0.0/0"
    destination_type     = "CIDR_BLOCK"
    #network_entity_type  = "NAT_GATEWAY"
    network_entity_id    = oci_core_nat_gateway.ashu_nat_gateway.id
  }


}

# creating Internet gateway 
resource "oci_core_internet_gateway" "ashu_internet_gateway" {
  compartment_id = var.oci_compartment-id
  vcn_id         = oci_core_vcn.ashu_oke_vcn-new.id
  display_name   = "AshuInternetGateway"
}

# creating routing table using internet gw
resource "oci_core_route_table" "ashupublic_route_table" {
  compartment_id = var.oci_compartment-id
  display_name   = "ashu-public-route-table"
  vcn_id         = oci_core_vcn.ashu_oke_vcn-new.id

  route_rules {
    destination           = "0.0.0.0/0"
    destination_type      = "CIDR_BLOCK"
    #network_entity_type   = "INTERNET_GATEWAY"
    network_entity_id = oci_core_internet_gateway.ashu_internet_gateway.id
    }


}