generate "provider" {
    path = "provider.tf"
    if_exists = "overwrite_terragrunt"
    contents = file("./provider-template.hcl")
}

terraform {
    extra_arguments "savePlan" {
        commands = ["plan"]
        arguments = ["-out=${abspath(".")}/plan.binary"]
    }

    extra_arguments "alwaysUsePlan" {
        commands = ["apply"]
        arguments = ["plan.binary"]
    }
}