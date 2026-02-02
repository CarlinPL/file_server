output "public_ip" {                                      ## Retorna o IP publico que a instância adquiriu
  value = aws_instance.file_server.public_ip
}

output "private_ip" {                                     ## Retorna o IP privado que a instância adquiriu
    value = aws_instance.file_server.private_ip
}
