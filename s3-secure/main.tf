resource "aws_s3_bucket" "b" {
  bucket_prefix = "secure-bucket-"
}
resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.b.id
  acl    = "private"
}
resource "aws_s3_bucket_public_access_block" "access_control" {
  bucket = aws_s3_bucket.b.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
