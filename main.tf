# 실험용 Ubuntu 22.04 최신 AMI 조회 (Canonical 공식 계정)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 실험 인스턴스 전용 보안 그룹
# - SSH는 본인 IP에서만 허용
# - HTTP(80)는 Nginx 테스트를 위해 전체 허용 (필요 없으면 나중에 좁히면 됨)
resource "aws_security_group" "experiment_sg" {
  name        = "whitehat-linux-experiment-sg"
  description = "Security group for Linux privilege experiment instance"

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "HTTP for Nginx test"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = "whitehat-agentic-ai"
    Purpose = "linux-privilege-experiment"
  }
}

# 실험용 EC2 인스턴스
resource "aws_instance" "linux_experiment" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.experiment_sg.id]

  # 의도적으로 iam_instance_profile을 지정하지 않음.
  # Linux 권한 실험과 AWS IAM 권한 실험을 독립적으로 유지하기 위해,
  # 이 인스턴스에는 어떤 IAM Role도 연결하지 않는다.

  metadata_options {
    http_tokens                 = "required" # IMDSv2 강제 (v1 조회 차단)
    http_put_response_hop_limit = 1          # 컨테이너 등 내부 홉을 통한 메타데이터 접근도 제한
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y nginx
              systemctl enable nginx
              systemctl start nginx
              EOF

  tags = {
    Name    = "whitehat-linux-experiment"
    Project = "whitehat-agentic-ai"
  }
}
