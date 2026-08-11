output "instance_public_ip" {
  description = "생성된 인스턴스의 퍼블릭 IP (SSH 접속 및 웹 접속에 사용)"
  value       = aws_instance.linux_experiment.public_ip
}

output "instance_id" {
  description = "생성된 인스턴스 ID"
  value       = aws_instance.linux_experiment.id
}

output "ssh_command" {
  description = "바로 복사해서 쓸 수 있는 SSH 접속 명령어"
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${aws_instance.linux_experiment.public_ip}"
}
