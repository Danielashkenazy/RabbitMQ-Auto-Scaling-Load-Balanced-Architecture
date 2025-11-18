
resource "aws_iam_role" "rabbit_ec2_role" {
  name = "rabbit_ec2_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "rabbit_secrets_policy" {
  name = "rabbit_secrets_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = ["secretsmanager:GetSecretValue"],
      Resource = [
        var.aws_secret_rabbit_admin_user_arn,
        var.aws_secret_admin_pass_arn,
        var.aws_secret_rabbit_erlang_cookie_arn
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_secrets" {
  role       = aws_iam_role.rabbit_ec2_role.name
  policy_arn = aws_iam_policy.rabbit_secrets_policy.arn
}

resource "aws_iam_instance_profile" "rabbit_profile" {
  name = "rabbit_profile"
  role = aws_iam_role.rabbit_ec2_role.name
}