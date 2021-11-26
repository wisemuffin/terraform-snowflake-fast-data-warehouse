locals {
  public_role   = "PUBLIC"
  sysadmin_role = "SYSADMIN"
  employees = {
    "EMPLOYEE_A" = {
      name       = "bigboy"
      login_name = "bigboy"
    }
    "EMPLOYEE_B" = {
      name  = "wisemuffin"
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
}
