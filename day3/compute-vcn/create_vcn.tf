resource "oci_core_vcn" "ashu_oke_vcn-new" {

    cidr_block = var.oci_cidr
    dns_label = "ashucvn1"
    compartment_id = oci_identity_compartment.ashu-compartment1.id
    display_name = "ashu-terraform-vcn-day3"
}

# creating public subnet 
resource "oci_core_subnet" "public_subnet" {
    cidr_block     = var.vcn_public_subnet
    display_name   = "ashuPublicSubnet"
    vcn_id         = "${oci_core_vcn.ashu_oke_vcn-new.id}"
    compartment_id = oci_identity_compartment.ashu-compartment1.id
    # adding routing table
    route_table_id = oci_core_route_table.ashupublic_route_table.id
    # adding security list
    security_list_ids = [ oci_core_security_list.ashu_security_list.id ]
}

# creating private subnet 
resource "oci_core_subnet" "private_subnet" {
    cidr_block     = var.vcn_private_subnet
    display_name   = "ashuPrivateSubnet"
    vcn_id         = "${oci_core_vcn.ashu_oke_vcn-new.id}"
    compartment_id = oci_identity_compartment.ashu-compartment1.id
    # adding routing table 
    route_table_id = oci_core_route_table.private_route_table.id
}
# creating public IP for Nat gw
## creating Nat gateway 
resource "oci_core_nat_gateway" "ashu_nat_gateway" {
  compartment_id = oci_identity_compartment.ashu-compartment1.id
  vcn_id         = oci_core_vcn.ashu_oke_vcn-new.id
  display_name   = "ashuNatGateway"
  block_traffic = false  # to allow any outgoing traffic
  #public_ip_id   = oci_core_public_ip.ashu_public_ip.id 
}

# creating routing table first

# creating routing rules with nat gw
resource "oci_core_route_table" "private_route_table" {
  compartment_id = oci_identity_compartment.ashu-compartment1.id
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
  compartment_id = oci_identity_compartment.ashu-compartment1.id
  vcn_id         = oci_core_vcn.ashu_oke_vcn-new.id
  display_name   = "AshuInternetGateway"
}

# creating routing table using internet gw
resource "oci_core_route_table" "ashupublic_route_table" {
  compartment_id = oci_identity_compartment.ashu-compartment1.id
  display_name   = "ashu-public-route-table"
  vcn_id         = oci_core_vcn.ashu_oke_vcn-new.id

  route_rules {
    destination           = "0.0.0.0/0"
    destination_type      = "CIDR_BLOCK"
    #network_entity_type   = "INTERNET_GATEWAY"
    network_entity_id = oci_core_internet_gateway.ashu_internet_gateway.id
    }


}

# creating security list 
resource "oci_core_security_list" "ashu_security_list" {
  compartment_id = oci_identity_compartment.ashu-compartment1.id
  vcn_id         = oci_core_vcn.ashu_oke_vcn-new.id
  display_name   = "ashu-SecurityList"

  egress_security_rules {
    destination_type = "CIDR_BLOCK"
    destination      = "0.0.0.0/0"
    protocol         = "all"
  }
 # for ssh 
  ingress_security_rules {
    source_type      = "CIDR_BLOCK"
    source           = "0.0.0.0/0"
    protocol         = "6"
    tcp_options {
      min = 22
      max = 22
    }
  }
  # http
  ingress_security_rules {
    source_type      = "CIDR_BLOCK"
    source           = "0.0.0.0/0"
    protocol         = "6"
    tcp_options {
      min = 80
      max = 80
    }
  }
}