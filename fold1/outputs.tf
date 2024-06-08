output "provpc" {
  value = aws_vpc.provpc.id
}

output "proig" {
  value = aws_internet_gateway.proig.id
}

output "aval_1a_subnet" {
  value = aws_subnet.aval_1a_subnet.id
}

output "aval_1b_subnet" {
  value = aws_subnet.aval_1b_subnet.id
}

output "aval_1c_subnet" {
  value = aws_subnet.aval_1c_subnet.id
}

output "first_instance_ami" {
  value = aws_ami_from_instance.first_instance_ami.id
}

output "first_instance_ip" {
  value = aws_instance.first_instance.public_ip
}

output "prosg" {
  value = aws_security_group.prosg.id
}


