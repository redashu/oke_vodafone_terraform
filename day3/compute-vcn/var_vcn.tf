variable "oci_cidr" {
    type = string
    default = "10.0.0.0/16"
  
}

variable "oci_compartment-id" {
    type = string
    default = "ocid1.ciutndf7kq"
  
}
# public subnet details 
# creating public subnet 
variable "vcn_public_subnet" {
  type    = string
  default = "10.0.10.0/24"
}
# private subnet 
variable "vcn_private_subnet" {
  type    = string
  default = "10.0.20.0/24"
}
