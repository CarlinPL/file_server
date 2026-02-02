terraform {                         ##  indicar onde quero me comunicar e qual versão eu quero usar
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
    required_version = ">= 1.3.0"
    }