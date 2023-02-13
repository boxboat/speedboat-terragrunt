generate "provider" {
    path = "provider.tf"
    if_exists = "overwrite_terragrunt"
    contents = file("./provider-template.hcl")
}

generate "backend" {
    path = "backend.tf"
    if_exists = "overwrite_terragrunt"
    contents = templatefile("./backend-template.hcl",
        {
            resource_group_name = "rg-github-workshop-tf-state"
            storage_account_name = "saworkshoptfstate"
            container_name = "tfstate"
            terraform_state_path = "${path_relative_to_include()}"
            subscription_id = "cb87be4f-1fc8-4539-bf00-cfe21a36e926"
            tenant_id = "9e2c6a16-2c0f-45c1-a107-7bc5cf1f7c5f"
        }
    )
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