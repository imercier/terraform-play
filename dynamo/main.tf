resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "mi-dynamo-table-1"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "UserId"

  attribute {
    name = "UserId"
    type = "S"
  }
}
