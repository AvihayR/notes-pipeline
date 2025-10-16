
module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
}

module "igw" {
  source = "./modules/igw"
  vpc_id = module.vpc.vpc_id
}

module "nat_gw" {
  source    = "./modules/nat_gw"
  subnet_id = values(module.public_subnets)[0].id
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

module "private_subnets" {
  source      = "./modules/subnet"
  for_each    = var.availability_zone
  subnet_type = "private"
  az          = each.value
  cidr_block  = var.private_subnet_cidr_block[each.key]
  vpc_id      = module.vpc.vpc_id
  description = "Private subnets"
}

module "doc_db" {
  source              = "./modules/document_db"
  master_username     = var.db_user
  master_password     = var.db_password
  vpc_id              = module.vpc.vpc_id
  az_list             = values(var.availability_zone)
  allowed_cidr_blocks = values(var.private_subnet_cidr_block)
  subnet_ids          = [for s in module.private_subnets : s.id]

}
