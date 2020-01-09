resource "aws_instance" "jenkins-instance" {
  ami                    = var.AMIS[var.AWS_REGION]
  instance_type          = var.AWS_INSTANCE_FLAVOR
  subnet_id              = aws_subnet.main-public.id
  vpc_security_group_ids = [aws_security_group.jenkins-securitygroup.id]
  key_name               = aws_key_pair.mykeypair.key_name
  provisioner "local-exec" {
    #Add host to ./ssh/config
    command = "sh ./scripts/add_host.sh jenkins-instance ${self.public_ip} ubuntu ~/aws-jenkins/ssh_keys/mykey >> ~/.ssh/config"
  }
  provisioner "local-exec" {
    # remove host from ./ssh/config
    when    = destroy
    command = "sh ./scripts/remove_host.sh jenkins-instance ~/.ssh/config"
  }
  provisioner "file" {
    #uploads installation file
    source      = "./scripts/install_jenkins.sh"
    destination = "/tmp/install_jenkins.sh"
  }
  provisioner "remote-exec" {
    # install docker and jenkins
    inline = ["sudo sh /tmp/install_jenkins.sh",
    "cat /var/jenkins_home/secrets/initialAdminPassword"]
  }
  connection {
    host        = coalesce(self.public_ip, self.private_ip)
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.PATH_TO_PRIVATE_KEY)
  }
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