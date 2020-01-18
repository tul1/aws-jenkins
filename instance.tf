resource "aws_instance" "jenkins-instance" {
  ami                    = var.AMIS[var.AWS_REGION]
  instance_type          = var.AWS_INSTANCE_FLAVOR
  subnet_id              = aws_subnet.main-public.id
  vpc_security_group_ids = [aws_security_group.jenkins-securitygroup.id]
  key_name               = aws_key_pair.mykeypair.key_name
  provisioner "local-exec" {
    #Add host to ./ssh/config
    command = "sh ./scripts/add-host.sh jenkins-instance ${self.public_ip} ubuntu ~/aws-jenkins/ssh_keys/mykey >> ~/.ssh/config"
  }
  provisioner "local-exec" {
    # remove host from ./ssh/config
    when    = destroy
    command = "sh ./scripts/remove-host.sh jenkins-instance ~/.ssh/config"
  }
  provisioner "file" {
    # upload Dockerfile
    source      = "./Dockerfile"
    destination = "/tmp/Dockerfile"
  }
  connection {
    host        = coalesce(self.public_ip, self.private_ip)
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.PATH_TO_PRIVATE_KEY)
  }
  user_data = data.template_cloudinit_config.cloudinit-jenkins.rendered
}

resource "aws_ebs_volume" "jenkins-data" {
  availability_zone = var.AVAILABILITY_ZONE
  size              = 20
  type              = "gp2"
  tags = {
    Name = "jenkins-data"
  }
}

resource "aws_volume_attachment" "jenkins-data-attachment" {
  device_name  = var.INSTANCE_DEVICE_NAME
  volume_id    = aws_ebs_volume.jenkins-data.id
  instance_id  = aws_instance.jenkins-instance.id
  skip_destroy = true
}