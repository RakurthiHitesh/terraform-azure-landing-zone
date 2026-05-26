environment        = "staging"
location           = "uksouth"
project            = "landing-zone"
vnet_address_space = ["10.1.0.0/16"]

subnets = {
  app  = { address_prefix = "10.1.1.0/24" }
  data = { address_prefix = "10.1.2.0/24" }
  mgmt = { address_prefix = "10.1.3.0/24" }
}
