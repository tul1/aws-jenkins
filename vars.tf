variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "PATH_TO_PUBLIC_KEY" {}
variable "PATH_TO_PRIVATE_KEY" {}
variable "AWS_INSTANCE_FLAVOR" {
  default = "t2.micro"
}
variable "AWS_REGION" {
  default = "eu-west-3"
}
variable "AVAILABILITY_ZONE" {
  default = "eu-west-3a"
}
variable "AMIS" {
  default = {
    eu-west-3 = "ami-00c60f4df93ff408e"
  }
}
variable "INSTANCE_DEVICE_NAME" {
  default = "/dev/xvdh"
}