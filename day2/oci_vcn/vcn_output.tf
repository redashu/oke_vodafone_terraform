output "vcn_details-id" {
    value = "ashu vcn OCID is ${oci_core_vcn.ashu_oke_vcn-new.id}"
  
}

output "subnet_details" {
    value = " public subnet details ${oci_core_subnet.public_subnet.id}"
  
}