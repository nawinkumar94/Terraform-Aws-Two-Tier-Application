resource "aws_s3_bucket" "inventory-bucket" {
  bucket = "inventory-receipt-hue-011"
  acl    = "private"

  tags = {
    Name = "inventory-receipt-hue-011"
  }
}
