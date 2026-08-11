# Linux 권한 실험용 EC2 — Terraform

승희님 담당 Linux 권한 실험(1단계)을 AWS EC2 위에서 재현하기 위한 최소 구성입니다. Ubuntu 22.04 인스턴스 하나에 Nginx가 설치된 상태로 뜹니다. IAM Role은 의도적으로 붙이지 않았고, IMDSv2를 강제해서 AWS 자격증명 노출 경로를 막아뒀습니다.

## 사전 준비

1. `terraform --version`, `aws --version`이 정상 출력되는지 확인
2. `aws sts get-caller-identity`로 자격증명이 연결됐는지 확인
3. SSH 접속용 EC2 키페어가 없다면 아래 명령으로 생성

   ```
   aws ec2 create-key-pair --key-name whitehat-key --query 'KeyMaterial' --output text > ~/.ssh/whitehat-key.pem
   chmod 400 ~/.ssh/whitehat-key.pem
   ```

4. 본인 IP 확인 (SSH 허용 대상 설정용)

   ```
   curl ifconfig.me
   ```

## 변수 설정

```
cp terraform.tfvars.example terraform.tfvars
```

`terraform.tfvars`를 열어서 `key_name`(위에서 만든 키페어 이름, 예: whitehat-key)과 `my_ip`(확인한 IP + `/32`)를 채웁니다.

## 실행

```
terraform init      # 처음 한 번만
terraform plan       # 무엇이 만들어질지 미리 확인
terraform apply      # 실제로 생성 (yes 입력 필요)
```

`apply`가 끝나면 `instance_public_ip`, `ssh_command`가 출력됩니다. 출력된 `ssh_command`를 그대로 터미널에 붙여넣으면 인스턴스에 접속됩니다.

## 확인

```
curl http://<instance_public_ip>          # Nginx 기본 페이지가 떠야 정상
```

SSH 접속 후에는 이런 것들을 확인해보시면 좋습니다.

```
id
sudo -l
curl -H "X-aws-ec2-metadata-token: $(curl -s -X PUT http://169.254.169.254/latest/api/token -H 'X-aws-ec2-metadata-token-ttl-seconds: 21600')" http://169.254.169.254/latest/meta-data/iam/security-credentials/
```

마지막 명령은 IAM Role이 없고 IMDSv2가 강제되어 있으므로 자격증명이 조회되지 않아야 정상입니다(이게 의도한 결과입니다).

## 정리 (비용 방지)

실험이 끝나면 반드시 삭제하세요.

```
terraform destroy    # yes 입력 필요
```
