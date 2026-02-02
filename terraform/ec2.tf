resource "aws_instance" "file_server" {
    ami = "ami-077aec33f15de0896"                 ## Escolho qual sistema operacional eu quero usar através do ID da AMI disponivel no site da AWS
    instance_type = var.instance_type             ## Utiliza a saida da variavel instance_type
    key_name = var.key_name                       ## Utiliza a saida da variavel key_name

    vpc_security_group_ids = [
        aws_security_group.smb_sg.id
    ]

    tags = {
        name = "file_server"
    }
}