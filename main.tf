terraform {
  required_version = "~> 0.14.4"

  required_providers {
    null = {
      source = "hashicorp/null"
      version = "~> 3.1.0"
    }
  }
}

resource "null_resource" "foo" {
  count = var.resource_count
}

resource "null_resource" "bar" {
  count = length(null_resource.foo)
}

resource "null_resource" "baz" {
  count = var.resource_count
}
