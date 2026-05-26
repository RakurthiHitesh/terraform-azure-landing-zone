environment        = "dev"
location           = "uksouth"
project            = "landing-zone"
vnet_address_space = ["10.0.0.0/16"]

subnets = {
  app = { address_prefix = "10.0.1.0/24" }
  data = { address_prefix = "10.0.2.0/24" }
  mgmt = { address_prefix = "10.0.3.0/24" }
}
