provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      project = var.project_name
      owner   = var.owner_tag
    }
  }
}
