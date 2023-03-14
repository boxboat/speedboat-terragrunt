# Grabs each hcl containing variables that can be input into a template
locals {
    global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"))
    subscription_vars = read_terragrunt_config(find_in_parent_folders("subscription.hcl"))
    region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
    environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
    module_vars = read_terragrunt_config("module.hcl")
}

# include terragrunt configuration files from parent directories
include {
    path = find_in_parent_folders()
}

terraform {
    source = "../../../../..//terraform//templates/shared_container_registry"
}

inputs = merge(
    local.global_vars.locals,
    local.subscription_vars.locals,
    local.region_vars.locals,
    local.environment_vars.locals,
    local.module_vars.locals,
    {
        tags = merge(
            local.global_vars.locals.tags,
            local.subscription_vars.locals.tags,
            local.region_vars.locals.tags,
            local.environment_vars.locals.tags,
            local.module_vars.locals.tags,
        )
    }
)
