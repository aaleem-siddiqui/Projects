/* ---------- internal security group all access ---------- */
resource "aws_security_group" "generic_internal_all" {
  name              = format(
        "%s-internal-all",
        local.name,
      )
  vpc_id            = aws_vpc.generic.id
  tags              = merge(
    {
      "Name" = format(
        "%s-internal-all",
        local.name,
      )
    },
    local.tags
  )
}
/* ---------- Public security group applicationLoadBalancer access ---------- */
resource "aws_security_group" "public_applicationLoadBalancer" {
  name              = format(
        "%s-public-applicationLoadBalancer",
        local.name,
      )
  vpc_id            = aws_vpc.generic.id
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    iterator = port
    for_each = var.public_ingress_ports
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  tags              = merge(
    {
      "Name" = format(
        "%s-public-applicationLoadBalancer",
        local.name,
      )
    },
    local.tags
  )
}

resource "aws_security_group_rule" "internal_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.generic_internal_all.id
}
resource "aws_security_group_rule" "internal_ingress_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.generic_internal_all.id
}
resource "aws_security_group_rule" "internal_ingress_publicsg" {
  type                      = "ingress"
  from_port                 = 0
  to_port                   = 0
  protocol                  = -1
  source_security_group_id  = aws_security_group.public_applicationLoadBalancer.id
  security_group_id         = aws_security_group.generic_internal_all.id
}
resource "aws_security_group_rule" "internal_ingress_cirrs" {
  for_each          = toset(concat(["0.0.0.0/0", "0.0.0.0/0", "0.0.0.0/0"],var.internal_ingress_cidrs))
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = [each.value]
  security_group_id = aws_security_group.generic_internal_all.id
}