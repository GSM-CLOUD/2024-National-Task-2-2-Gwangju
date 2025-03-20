resource "aws_instance" "bastion" {
  ami = var.ami_id
  instance_type = "t3.small"

  subnet_id = var.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.bastion-sg.id]
  key_name = aws_key_pair.bastion-key-pair.key_name
  iam_instance_profile = aws_iam_instance_profile.bastion_instance_profile.name

  user_data = <<-EOF
#!/bin/bash
sudo su
set -e
set -x

echo "complete"
yum install -y docker
systemctl enable docker
systemctl restart docker

echo "complete"
cat <<EOT > app_rollout.yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: ${var.rollout_app_name}
  namespace: app
spec:
  replicas: 2
  revisionHistoryLimit: 2
  selector:
    matchLabels:
      app: ${var.rollout_app_name}
  template:
    metadata:
      labels:
        app: ${var.rollout_app_name}
    spec:
      containers:
      - name: ${var.rollout_app_name}
        image: ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/gwangju-ecr-app:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
  strategy:
    blueGreen:
      activeService: app-service
      previewService: app-service-preview
      autoPromotionEnabled: true
      autoPromotionSeconds: 20
EOT

echo "complete"
cat <<EOT > buildspec.yaml
version: 0.2

env:
  shell: bash
  variables:
    ACCOUNT_ID: ${var.account_id}
    AWS_REGION: ${var.region}
    REPO_NAME: ${var.ecr_app_name}
    GITOPS_REPO: ${var.gitops_repo_name}
phases:
  pre_build:
    commands:
      - echo "Logging in to Amazon ECR..."
      - aws ecr get-login-password --region \$AWS_REGION | docker login --username AWS --password-stdin \$ACCOUNT_ID.dkr.ecr.\$AWS_REGION.amazonaws.com
      - IMAGE_TAG=\$(date '+%Y%m%d%H%M%S')
      - echo \$IMAGE_TAG
  build:
    commands:
      - |
        echo "Building Docker image" \
        && docker build -t \$REPO_NAME:\$IMAGE_TAG . \
        && docker tag \$REPO_NAME:\$IMAGE_TAG \$ACCOUNT_ID.dkr.ecr.\$AWS_REGION.amazonaws.com/\$REPO_NAME:\$IMAGE_TAG \
        && docker push \$ACCOUNT_ID.dkr.ecr.\$AWS_REGION.amazonaws.com/\$REPO_NAME:\$IMAGE_TAG
  post_build:
    commands:
      - |
        git config --global credential.helper '!aws codecommit credential-helper $@' \
        && git config --global credential.UseHttpPath true \
        && git clone https://git-codecommit.ap-northeast-2.amazonaws.com/v1/repos/\$GITOPS_REPO \
        && cd \$GITOPS_REPO \
        && sed "s|image: .*|image: \$ACCOUNT_ID.dkr.ecr.\$AWS_REGION.amazonaws.com/\$REPO_NAME:\$IMAGE_TAG|" app_rollout.yaml > tmpfile && mv tmpfile app_rollout.yaml \
        && git config --global user.email codedeploy \
        && git config --global user.name codedeploy \
        && git add . \
        && git commit -m "update image tag \$IMAGE_TAG" \
        && git push origin main
EOT

echo "complete"
yum install git -y

echo "complete"
export HOME=/root
git config --global credential.helper '!aws codecommit credential-helper $@'
git config --global credential.UseHttpPath true

git clone https://git-codecommit.${var.region}.amazonaws.com/v1/repos/${var.app_repo_name}

echo "complete"
aws s3 cp s3://${var.file_bucket_name}/app.zip ./${var.app_repo_name}

echo "complete"
mv ./buildspec.yaml ./${var.app_repo_name}
cd ${var.app_repo_name}
unzip ./*.zip -d .
rm -rf *.zip

echo "complete"
aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com
docker build -t ${var.ecr_app_name} .
docker tag ${var.ecr_app_name}:latest ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_app_name}:latest
docker push ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_app_name}:latest

echo "complete"
git init 
git add .
git commit -m "initial code"
git checkout -b main
git push origin main

echo "complete"
cd ..
git clone https://git-codecommit.${var.region}.amazonaws.com/v1/repos/${var.gitops_repo_name}
mv ./app_rollout.yaml ./${var.gitops_repo_name}
cd ${var.gitops_repo_name}

echo "complete"
git init
git add .
git commit -m "initial code"
git checkout -b main
git push origin main


EOF

  tags = {
    "Name" = "${var.prefix}-bastion"
  }
}

