output "main_vpc"{
  value = aws_vpc.main_vpc.id
  description = "Vpc id of the instances"
}
output "subnet_public1"{
  value = aws_subnet.main_subnet_public_id_1.id
  description = "public subnet id 1"
}
output "subnet_public2"{
  value = aws_subnet.main_subnet_public_id_2.id
  description = "public subnet id 2"
}
output "subnet_public3"{
  value = aws_subnet.main_subnet_public_id_3.id
  description = "public subnet id 3"
}
