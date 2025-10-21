
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

module "public_rt" {
  for_each         = module.public_subnets
  source           = "./modules/public_rt"
  vpc_id           = module.vpc.vpc_id
  igw_id           = module.igw.igw-id
  local_cidr       = var.vpc_cidr
  public_subnet_id = each.value.id
}

module "private_rt" {
  for_each          = module.private_subnets
  source            = "./modules/private_rt"
  vpc_id            = module.vpc.vpc_id
  nat_gw_id         = module.nat_gw.id
  local_cidr        = var.vpc_cidr
  private_subnet_id = each.value.id
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

module "vpc_endpoints" {
  source          = "./modules/vpc_endpoints"
  vpc_id          = module.vpc.vpc_id
  region          = var.region
  route_table_ids = [for s in module.private_rt : s.id]
  subnet_ids      = [for s in module.private_subnets : s.id]
}

module "ecr" {
  source     = "./modules/ecr"
  for_each   = { backend = "notes-backend", frontend = "notes-frontend" }
  vpc_id     = module.vpc.vpc_id
  aws_region = var.region
  repo_name  = each.value
}

module "alb" {
  source            = "./modules/alb"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = [for s in module.public_subnets : s.id]
}

module "ecs" {
  source              = "./modules/ecs"
  aws_region          = var.region
  vpc_id              = module.vpc.vpc_id
  ecr_repo_urls       = { backend = module.ecr["backend"].url, frontend = module.ecr["frontend"].url }
  alb_tg_backend_arn  = module.alb.backend_tg_arn
  alb_tg_frontend_arn = module.alb.frontend_tg_arn
  backend_url         = "${module.alb.alb_url}/notes"
  db_url              = module.doc_db.url
  alb_sg_ids          = [module.alb.sg_id]
  private_subnet_ids  = [for s in module.private_subnets : s.id]
}

output "ecr_repository_urls" {
  value = [for s in module.ecr : s.url]
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

output "alb_dns_name" {
  value = module.alb.alb_url
}

output "doc_db_url" {
  value = module.doc_db.url
}
