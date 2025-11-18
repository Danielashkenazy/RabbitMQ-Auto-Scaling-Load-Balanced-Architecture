resource "aws_secretsmanager_secret" "rabbit_admin_user1" {
  name = "rabbit_admin_user1"
}

resource "aws_secretsmanager_secret_version" "rabbit_admin_user_ver1" {
  secret_id     = aws_secretsmanager_secret.rabbit_admin_user1.id
  secret_string = "admin"
}

resource "aws_secretsmanager_secret" "rabbit_admin_pass1" {
  name = "rabbit_admin_pass1"
}

resource "aws_secretsmanager_secret_version" "rabbit_admin_pass_ver1" {
  secret_id     = aws_secretsmanager_secret.rabbit_admin_pass1.id
  secret_string = "StrongPassword123!"
}

resource "aws_secretsmanager_secret" "rabbit_erlang_cookie1" {
  name = "rabbit_erlang_cookie1"
}

resource "aws_secretsmanager_secret_version" "rabbit_erlang_cookie_ver1" {
  secret_id     = aws_secretsmanager_secret.rabbit_erlang_cookie1.id
  secret_string = "SuperSecretSharedCookie123!"
}



