module "hasan_web_app_name" {
    source = "./web-app-project"
    web_app_name = "webAppbyHasan"
    instance_type = "t3.micro"
    ami_id = "ami-020cba7c55df1f615"
}