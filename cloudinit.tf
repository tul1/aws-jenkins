data "template_file" "jenkins-init" {
  template = file("scripts/jenkins-init.sh")
  vars = {
    DEVICE          = "/dev/xvdh"
    JENKINS_VERSION = "2.121.2"
  }
}

data "template_cloudinit_config" "cloudinit-jenkins" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.jenkins-init.rendered
  }
}
