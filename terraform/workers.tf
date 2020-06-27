module "worker-1" {
  source = "./modules/ec2"
  name = "worker-1"
  ami = "ami-0f7719e8b7ba25c61"
  instance_type = "t2.micro"
  key_name = module.imank-ssh-public-key.key_name
  vpc_security_group_ids = ["${module.salt-master.id}"]
  associate_public_ip_address = true
  # subnet_id = module.sales-subnet.id
  subnet_id = "subnet-6b07b832" # default vpc
  private_ip = "172.31.0.7"
  get_password_data = false
  volume_type = "standard" # magnetic 
}

output "worker-1-public_ip" {
  value = module.worker-1.public_ip
}

module "worker-2" {
  source = "./modules/ec2"
  name = "worker-2"
  ami = "ami-0f7719e8b7ba25c61"
  instance_type = "t2.micro"
  key_name = module.imank-ssh-public-key.key_name
  vpc_security_group_ids = ["${module.salt-master.id}"]
  associate_public_ip_address = true
  # subnet_id = module.sales-subnet.id
  subnet_id = "subnet-6b07b832" # default vpc
  private_ip = "172.31.0.8"
  get_password_data = false
  volume_type = "standard" # magnetic 
}

output "worker-2-public_ip" {
  value = module.worker-2.public_ip
}