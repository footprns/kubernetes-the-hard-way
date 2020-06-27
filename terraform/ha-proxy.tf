module "haproxy" {
  source = "./modules/ec2"
  name = "haproxy"
  ami = "ami-0f7719e8b7ba25c61"
  instance_type = "t2.micro"
  key_name = module.imank-ssh-public-key.key_name
  vpc_security_group_ids = ["${module.salt-master.id}"]
  associate_public_ip_address = true
  # subnet_id = module.sales-subnet.id
  subnet_id = "subnet-6b07b832" # default vpc
  private_ip = "172.31.0.6"
  get_password_data = false
  volume_type = "standard" # magnetic 
}

output "haproxy-public_ip" {
  value = module.haproxy.public_ip
}