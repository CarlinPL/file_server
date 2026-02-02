variable "instance_type" {                          ## cria variavel que informa o tipo da instancia
    description = "Tipo da instancia EC2"
    type = string                                   ## seleciona o tipo da variável que nesse caso é texto ou seja string
    default = "t3.micro"                            ## Define o Padrão do hardware da instância que queremos
}

variable "key_name" {                               ## cria variável key name onde informamos o nome do par de chaves
    description = "Escreva qual o par de chaves"
    type = string
    default = "iacalura"                            ## Aqui deixamos o par de chaves padrão caso a gente já saiba o nome e não queira digitar na hora de executar o código
}