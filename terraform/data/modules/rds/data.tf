data "aws_subnets" "database" {
    filter {
        name   = "vpc-id"
        values = [var.vpc_id]
    }
    filter {
      name = "tag:type"
      values = [ "database" ]
    }
}

data "aws_subnets" "allow" {
    filter {
        name   = "vpc-id"
        values = [var.vpc_id]
    }
    filter {
      name = "tag:type"
      values = [ "private","public" ]
    }
}

data "aws_subnet" "allow" {
    for_each = toset([ for s in data.aws_subnets.allow.ids : s ])
    id = each.value

}

data "aws_subnet" "database" {
    for_each = toset([ for s in data.aws_subnets.database.ids : s ])
    id = each.value
    
}