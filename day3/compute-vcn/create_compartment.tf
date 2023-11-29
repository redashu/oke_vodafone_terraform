resource "oci_identity_compartment" "ashu-compartment1" {
    compartment_id = var.oci_compartment-id # root compartment id 
    name = "ashu-oke-poc" # name of compartment
    description = "all my resources will be here"
    
}