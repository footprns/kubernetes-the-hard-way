module "imank-ssh-public-key" {
  source = "./modules/key-pair"
  key_name = "imank-ssh-public-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

module "salt-master" {
  source = "./modules/security-group"
  name = "salt-master"
  description = "Allow ssh inbound traffic"
  vpc_id = "vpc-4cc2dd2b" # default vpc
  ingress_rules = [
  {
    description = "SSH from Intenet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["223.229.165.24/32"]
  },
  {
    description = "Kubernetes API Server"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    description = "Kubernetes API Server01"
    from_port   = 7443
    to_port     = 7443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    description = "etcd traffic"
    from_port   = 2380
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    description = "etcd server client API"
    from_port   = 2379
    to_port     = 2379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    description = "Kubelet API"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    description = "kube-scheduler"
    from_port   = 10251
    to_port     = 10251
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    description = "kube-controller-manager"
    from_port   = 10252
    to_port     = 10252
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    description = "Read-Only Kubelet API"
    from_port   = 10255
    to_port     = 10255
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    description = "weave01"
    from_port   = 6783
    to_port     = 6783
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    description = "weave02"
    from_port   = 6783
    to_port     = 6783
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    description = "weave03"
    from_port   = 6784
    to_port     = 6784
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    description = "Traffic inside"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["172.31.0.0/20"]
  }
  ]

  egress_rules = [
  {
    description = "Traffic to Intenet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ]
}
/*
module "salt-master-instance" {
  source = "./modules/ec2"
  name = "salt-master"
  ami = "ami-0ec225b5e01ccb706"
  instance_type = "t2.micro"
  key_name = module.imank-ssh-public-key.key_name
  vpc_security_group_ids = ["${module.salt-master.id}"]
  associate_public_ip_address = true
  # subnet_id = module.sales-subnet.id
  subnet_id = "subnet-cab073ac" # default vpc
  get_password_data = false
  volume_type = "standard" # magnetic 
}

output "salt-master-public_ip" {
  value = module.salt-master-instance.public_ip
}
*/
module "master-1" {
  source = "./modules/ec2"
  name = "master-1"
  ami = "ami-0f7719e8b7ba25c61"
  instance_type = "t2.micro"
  key_name = module.imank-ssh-public-key.key_name
  vpc_security_group_ids = ["${module.salt-master.id}"]
  associate_public_ip_address = true
  # subnet_id = module.sales-subnet.id
  subnet_id = "subnet-6b07b832" # default vpc
  private_ip = "172.31.0.4"
  get_password_data = false
  volume_type = "standard" # magnetic 
}

output "master-1-public_ip" {
  value = module.master-1.public_ip
}

module "master-2" {
  source = "./modules/ec2"
  name = "master-2"
  ami = "ami-0f7719e8b7ba25c61"
  instance_type = "t2.micro"
  key_name = module.imank-ssh-public-key.key_name
  vpc_security_group_ids = ["${module.salt-master.id}"]
  associate_public_ip_address = true
  subnet_id = "subnet-6b07b832" # default vpc
  private_ip = "172.31.0.5"
  get_password_data = false
  volume_type = "standard" # magnetic 
}

output "master-2-public_ip" {
  value = module.master-2.public_ip
}