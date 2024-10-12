variable "project" {
    description = "The projects name"
    default = "contapprb"
}

variable "enviroment" {
    description = "The enviroment to release"
    default = "dev"
}

variable "location" {
    description = "The Azure servers region"
    default = "East US 2"
}

variable "tags" {
    description = "All tags used"
    default = {
        enviroment = "dev"
        project = "contapprb"
        created_by = "terraform"
    }
}

variable "password" {
    description = "The sqlserver password"
    type = string
    sensitive = true
}