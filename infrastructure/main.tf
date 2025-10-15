
module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
}


module "private_subnets" {
  source      = "./modules/subnet"
  for_each    = var.availability_zone
  subnet_type = "private"
  az          = each.value
  cidr_block  = var.private_subnet_cidr_block[each.key]
  vpc_id      = module.vpc.vpc_id
  description = "Private subnets"
}

module "public_subnets" {
  source      = "./modules/subnet"
  for_each    = var.availability_zone
  subnet_type = "public"
  az          = each.value
  cidr_block  = var.public_subnet_cidr_block[each.key]
  vpc_id      = module.vpc.vpc_id
  description = "Public subnets"
}
