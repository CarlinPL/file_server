# state.tf
terraform{
    backend "s3" {
        bucket = "terraformgoku"
        key = "estado/tfstate"
        region = "sa-east-1"
        encrypt = true
    }
}
