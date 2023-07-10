/*---------------- VPC -------------------*/
resource "aws_vpc" "generic" {
  cidr_block                      = var.cidr_block
  instance_tenancy                = var.instance_tenancy
  enable_dns_hostnames            = var.enable_dns_hostnames
  enable_dns_support              = var.enable_dns_support
  tags                            = merge(
    {
      "Name"                      = local.name
    },
    local.tags
  )
}
/*---------------- DHCP opt -------------------*/
resource "aws_vpc_dhcp_options" "generic" {
  domain_name                     = var.dhcp_options_domain_name
  domain_name_servers             = var.dhcp_options_domain_name_servers
  tags                            = merge(
    {
      "Name"                      = local.name
    },
    local.tags
  )
}
/*---------------- DHCP -> VPC attachment -------------------*/
resource "aws_vpc_dhcp_options_association" "generic" {
  vpc_id                          = aws_vpc.generic.id
  dhcp_options_id                 = aws_vpc_dhcp_options.generic.id
}
/*---------------- Internet Gateway -------------------*/
resource "aws_internet_gateway" "generic" {
  vpc_id                          = aws_vpc.generic.id
  tags                            = merge(
    {
      "Name"                      = local.name
    },
    local.tags
  )
}
/*---------------- Public route table -------------------*/
resource "aws_route_table" "public" {
  vpc_id                          = aws_vpc.generic.id
  tags                            = merge(
    {
      "Name"                      = "${local.name}-public-1"
    },
    local.tags
  )
}

/*---------------- Private route tables -------------------*/
resource "aws_route_table" "private" {
  count                           = length(var.availability_zone)
  vpc_id                          = aws_vpc.generic.id
  tags                            = merge(
    {
      "Name"                      = format(
        "${local.name}-private-%s",
        count.index+1,
      )
    },
    local.tags
  )
}
/*---------------- Public subnets -------------------*/
resource "aws_subnet" "public" {
  count                           = length(var.public_subnets)
  vpc_id                          = aws_vpc.generic.id
  cidr_block                      = element(var.public_subnets, count.index)
  availability_zone               = format("%s%s", data.aws_region.current.name, element(var.availability_zone, count.index))
  map_public_ip_on_launch         = var.map_public_ip_on_launch
  tags                            = merge(
    {
      "Name"                      = format(
        "${local.name}-public-%s",
        count.index+1,
      )
    },
    local.tags
  )
}
/*---------------- Private example_application subnets -------------------*/
resource "aws_subnet" "example_application" {
  count                           = length(var.example_application_subnets)
  vpc_id                          = aws_vpc.generic.id
  cidr_block                      = element(var.example_application_subnets, count.index)
  availability_zone               = format("%s%s", data.aws_region.current.name, element(var.availability_zone, count.index))
  map_public_ip_on_launch         = var.map_public_ip_on_launch
  tags                            = merge(
    {
      "Name"                      = format(
        "${local.name}-example_application-%s",
        count.index+1,
      )
    },
    local.tags
  )
}
/*---------------- Public example_gateway_loadbalancer subnets -------------------*/
resource "aws_subnet" "example_gateway_loadbalancer" {
  count                           = length(var.example_gateway_loadbalancer_subnets)
  vpc_id                          = aws_vpc.generic.id
  cidr_block                      = element(var.example_gateway_loadbalancer_subnets, count.index)
  availability_zone               = format("%s%s", data.aws_region.current.name, element(var.availability_zone, count.index))
  map_public_ip_on_launch         = var.map_public_ip_on_launch
  tags                            = merge(
    {
      "Name"                      = format(
        "${local.name}-example_gateway_loadbalancer-%s",
        count.index+1,
      )
    },
    local.tags
  )
}
/*---------------- Private nat subnets -------------------
resource "aws_subnet" "nat" {
  count                           = length(var.nat_subnets)
  vpc_id                          = aws_vpc.generic.id
  cidr_block                      = element(var.nat_subnets, count.index)
  availability_zone               = format("%s%s", data.aws_region.current.name, element(var.availability_zone, count.index))
  map_public_ip_on_launch         = var.map_public_ip_on_launch
  tags                            = merge(
    {
      "Name"                      = format(
        "${local.name}-nat-%s",
        count.index+1,
      )
    },
    local.tags
  )
}*/
/*---------------- Private example_database subnets -------------------
resource "aws_subnet" "example_database" {
  count                           = length(var.example_database_subnets)
  vpc_id                          = aws_vpc.generic.id
  cidr_block                      = element(var.example_database_subnets, count.index)
  availability_zone               = format("%s%s", data.aws_region.current.name, element(var.availability_zone, count.index))
  map_public_ip_on_launch         = var.map_public_ip_on_launch
  tags                            = merge(
    {
      "Name"                      = format(
        "${local.name}-example_database-%s",
        count.index+1,
      )
    },
    local.tags
  )
}*/
/*---------------- Allocate IP's -------------------*/
resource "aws_eip" "nat" {
  count                           = length(var.example_application_subnets)
  vpc                             = true
  tags                            = merge(
    {
      "Name"                      = format(
        "${local.name}-nat-ip-%s",
        format("%s%s", data.aws_region.current.name, element(var.availability_zone, count.index)),
      )
    },
    local.tags
  )
}
/*---------------- NAT Gateway -------------------*/
resource "aws_nat_gateway" "nat_gw" {
  count                           = length(var.public_subnets)

  allocation_id                   = element(aws_eip.nat.*.id, count.index)
  subnet_id                       = element(aws_subnet.public.*.id, count.index)

  tags = merge(
    {
      "Name"                      = format(
        "${local.name}-nat-%s",
        format("%s%s", data.aws_region.current.name, element(var.availability_zone, count.index)),
      )
    },
    local.tags
  )
}
/*---------------- Public route -------------------
resource "aws_route" "public_internet_gateway" {
  route_table_id                  = aws_route_table.public.id
  destination_cidr_block          = "0.0.0.0/0"
  gateway_id                      = aws_internet_gateway.generic.id
}*/
/*---------------- example_application routes -------------------*/
resource "aws_route" "example_application_gateway_routes" {
  count                           = length(aws_nat_gateway.nat_gw.*.id)
  route_table_id                  = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block          = "0.0.0.0/0"
  nat_gateway_id                  = element(aws_nat_gateway.nat_gw.*.id, count.index)
}
/*---------------- NAT routes -------------------*/
resource "aws_route" "nat_gateway_routes" {
  count                           = length(aws_nat_gateway.nat_gw.*.id)
  route_table_id                  = element(aws_route_table.public.*.id, count.index)
  destination_cidr_block          = "0.0.0.0/0"
  nat_gateway_id                  = element(aws_nat_gateway.nat_gw.*.id, count.index)
}
/*---------------- Public route table association -------------------*/
resource "aws_route_table_association" "public" {
  count                           = length(aws_subnet.public.*.id)
  subnet_id                       = element(aws_subnet.public.*.id, count.index)
  route_table_id                  = aws_route_table.public.id
}
/*---------------- Private route table association -------------------*/
resource "aws_route_table_association" "example_application_private" {
  count                           = length(aws_subnet.example_application.*.id)
  subnet_id                       = element(aws_subnet.example_application.*.id, count.index)
  route_table_id                  = element(aws_route_table.private.*.id, count.index)
}
/*---------------- example_gateway_loadbalancer route table association -------------------*/
resource "aws_route_table_association" "example_gateway_loadbalancer_public" {
  count                           = length(aws_subnet.example_gateway_loadbalancer.*.id)
  subnet_id                       = element(aws_subnet.example_gateway_loadbalancer.*.id, count.index)
  route_table_id                  = element(aws_route_table.public.*.id, count.index)
}
/*
resource "aws_route_table_association" "example_database_private" {
  count                           = length(aws_subnet.example_database.*.id)
  subnet_id                       = element(aws_subnet.example_database.*.id, count.index)
  route_table_id                  = element(aws_route_table.private.*.id, count.index)
}
*/