variable "web_app_name" {
    description = "This is a web app name"
    type = string
}

variable "env" {
    default = "dev"
    type = string
}

variable "instance_type" {
    description = "This is instance type of web app name"
    type = string
}

variable "ami_id" {
    description = "This is ami id of web app name"
}