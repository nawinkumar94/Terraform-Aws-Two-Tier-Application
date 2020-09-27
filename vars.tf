variable AWS_REGION{
  default = "ap-south-1"
}

variable "AWS_ACCESS_KEY"{

}

variable "AWS_SECRET_KEY"{

}

variable "INSTANCE_TYPE"{
  default = "t2.micro"
}

variable "ENVIRONMENT"{
  default = "development"
}

variable "PATH_TO_PUBLICKEY"{
  default = "mykey.pub"
}

variable PATH_TO_PRIVATE_KEY{
  default = "mykey"
}

variable AMIS {
  type= map(string)
  default = {
    ap-south-1 = "ami-04d8d4462ae1ae813"
    ap-northeast-1 = "ami-036cb77005c69fbe0"
    ap-east-1 = "ami-f19cdf80"
  }
}

variable RDS_PASSWORD{
  default = "Naveen@12345"
}

variable INSTANCE_DEVICE_NAME{
  default = "/dev/xvdh"
}

variable "CIDR_BLOCK_16"{
  default = "10.0.0.0/16"
}

variable "CIDR_BLOCK_0"{
  default = "0.0.0.0/0"
}

variable "INSTANCE_CLASS"{
  default = "db.t2.micro"
}
