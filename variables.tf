variable "aws_region" {
  description = "리소스를 생성할 AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}

variable "instance_type" {
  description = "EC2 인스턴스 타입 (프리티어 대상)"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH 접속용 EC2 키페어 이름 (AWS 콘솔이나 CLI로 미리 생성해야 함)"
  type        = string
}

variable "my_ip" {
  description = "SSH 접속을 허용할 본인 IP. CIDR 형식으로 입력 (예: 1.2.3.4/32). 터미널에서 `curl ifconfig.me`로 확인 가능"
  type        = string
}
