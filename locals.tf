locals {
  public_role   = "PUBLIC"
  sysadmin_role = "SYSADMIN"
  employees = {
    "EMPLOYEE_A" = {
      name       = "davidgriffithsgg777@gmail.com"
      login_name = "davidgriffithsgg777@gmail.com"
    }
    "EMPLOYEE_B" = {
      name  = "wisemuffinhubspot@gmail.com"
      email = "wisemuffinhubspot@gmail.com"
    }
  }
  system_users = {
    "LOOKER_USER"    = {}
    "SUPERSET_USER"  = {}
    "IMMUTA_USER"    = {}
    "HIGHTOUCH_USER" = {}
    "DBT_CLOUD_USER" = {
    }
  }
  monitored_warehouses = []
}
