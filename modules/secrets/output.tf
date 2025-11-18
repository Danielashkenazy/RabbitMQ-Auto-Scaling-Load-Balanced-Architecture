output "aws_secret_rabbit_admin_user_arn" {
  value = aws_secretsmanager_secret.rabbit_admin_user1.arn
}
output "aws_secret_admin_pass_arn" {
  value = aws_secretsmanager_secret.rabbit_admin_pass1.arn
}
output "aws_secret_rabbit_erlang_cookie_arn" {
  value = aws_secretsmanager_secret.rabbit_erlang_cookie1.arn
}