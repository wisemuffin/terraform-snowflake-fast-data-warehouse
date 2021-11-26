terraform {
  required_providers {
    snowflake = {
      source  = "chanzuckerberg/snowflake"
      version = ">=0.23.2"
    }
  }
}

// CORE RESOURCES
// This section generates base roles, warehouses and users
// It does NOT create grants between these resources
module "employees" {
  source = "./modules/bulk_users"

  users                          = local.employees
  default_role                   = local.public_role
  default_must_change_password   = true
  default_generate_user_password = true
}

module "systems" {
  source = "./modules/bulk_users"

  users                          = local.system_users
  default_role                   = module.bulk_roles.roles["ANALYST"].name
  default_generate_user_password = true
}

module "bulk_roles" {
  source = "./modules/bulk_roles"

  roles = {
    READER    = {}
    ANALYST   = {}
    DBT_CLOUD = {}
  }
}

module "bulk_warehouses" {
  source = "./modules/bulk_warehouses"

  warehouses = {
    PROCESSING_WH = { size = "medium" }
    REPORTING_WH  = {}
  }
}

// APPLICATION DATABASES
// databases (and system users) to be leveraged for a single purpose
module "analytics_db" {
  for_each = toset(["ANALYTICS"])
  source   = "./modules/application_database"

  database_name        = each.value
  grant_admin_to_roles = [local.sysadmin_role]
  grant_admin_to_users = [module.systems.users["DBT_CLOUD_USER"].name]
  grant_read_to_roles = [
    module.bulk_roles.roles["READER"].name,
    module.bulk_roles.roles["ANALYST"].name,
  ]
}

module "raw_db" {
  source = "./modules/application_database"

  database_name                = "RAW"
  create_application_user      = true
  create_application_warehouse = true
  grant_admin_to_roles         = [local.sysadmin_role]
  grant_read_to_roles = [
    module.bulk_roles.roles["READER"].name,
  ]
}

module "developer_dbs" {
  for_each = module.employees.users
  source   = "./modules/application_database"

  database_name                = "DEV_${each.key}"
  create_application_user      = false
  create_application_warehouse = false
  grant_admin_to_users         = [each.value.name]
}

// GRANTS
// Grants on core roles and warehouses need to be performed
// after all resources are defined and created.
module "bulk_role_grants" {
  source = "./modules/bulk_role_grants"
  grants = {
    READER = {
      roles = [module.bulk_roles.roles["ANALYST"].name]
      users = [module.employees.users["EMPLOYEE_A"].name]
    }
    ANALYST = {
      users = [for m in module.employees.users : m.name]
    }
  }
  depends_on = [module.bulk_roles]
}

module "bulk_warehouse_grants" {
  source = "./modules/bulk_warehouse_grants"
  grants = {
    PROCESSING_WH = {
      roles = concat(
        [for m in module.analytics_db : m.admin_role.name],
        [for m in module.developer_dbs : m.admin_role.name],
        [module.bulk_roles.roles["ANALYST"].name]
      )
    }
    REPORTING_WH = {
      roles = [
        module.bulk_roles.roles["ANALYST"].name,
        local.public_role
      ]
    }
  }
  depends_on = [module.bulk_warehouses]
}
