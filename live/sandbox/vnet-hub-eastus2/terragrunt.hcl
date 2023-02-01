# Grabs each hcl containing variables that can be input into a template
locals {
    global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"))
    environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
    module_vars = read_terragrunt_config("module.hcl")
}

# include terragrunt configuration files from parent directories
include {
    path = find_in_parent_folders()
}

terraform {
    source = "../../../terraform//templates/virtual_network_hub"
}

inputs = merge(
    local.global_vars.locals,
    local.environment_vars.locals,
    local.module_vars.locals,
    {
        tags = merge(
            local.global_vars.locals.tags,
            local.environment_vars.locals.tags,
            local.module_vars.locals.tags,
        )
    }
)