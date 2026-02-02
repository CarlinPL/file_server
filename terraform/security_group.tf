resource "aws_security_group" "smb_sg" {
    name = "server-samba"
    description = "Permite acesso SSH e SMB"

    ingress {                                      ## Permitir entrada
        from_port = 22                             ## Porta de comunicação
        to_port = 22                               ## Porta de comunicação
        protocol = "tcp"                           ## Protocolo
        cidr_blocks = ["0.0.0.0/0"]                ## Mascara de sub-rede
    }

    ingress {                                      ## Permitir entrada
        from_port = 445                            ## Porta de comunicação
        to_port = 445                              ## Porta de comunicação
        protocol = "tcp"                           ## Escolhe o tipo de protocolo
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {                                       ## Permitir saida
        from_port = 0                              ## Porta de comunicação
        to_port = 0                                ## Porta de comunicação
        protocol = "-1"                            ## Permitir saida de qualquer protocolo
        cidr_blocks = ["0.0.0.0/0"]
    }

}
