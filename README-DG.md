# before running terraform set these envs

```bash
export TF_VAR_snowflake_account=XXXXX
export TF_VAR_snowflake_region=XXXXX
export TF_VAR_snowflake_username=XXXXX
export TF_VAR_snowflake_user_password=XXXXX
export TF_VAR_snowflake_user_role=XXXXX
```

# updating terraform

## new dbt project

1) add a new database to analytics_db tf module e.g. DBT_BUSINESS_INTELLIGENCE

Then the following will be built
1) PROCESSING_WH will be given access to the db automatically
2) Role created DBT_BUSINESS_INTELLIGENCE_READER
3) Role created DBT_BUSINESS_INTELLIGENCE_ADMIN
4) Role _READER will be given to ... ANALYST & READER & SYSADMIN
5) Role _ADMIN will be given to DBT_CLOUD & DATAFOLD & SYSADMIN

# Todo
- seperate warehouse currently all using PROCESSING_WH

# example 1 of manually setting up roles for tranforming in dbt

```sql
USE ROLE ACCOUNTADMIN; -- you need accountadmin (or security admin) for user creation, future grants


DROP USER IF EXISTS YFAEP_DBT_CLOUD;
DROP ROLE IF EXISTS YFAEP_TRANSFORMER;
DROP DATABASE IF EXISTS YFAEP_DATABASE CASCADE;
DROP WAREHOUSE IF EXISTS YFAEP_TRANSFORMING;

-- creating a warehouse
CREATE WAREHOUSE YFAEP_TRANSFORMING WITH WAREHOUSE_SIZE = 'XSMALL' WAREHOUSE_TYPE = 'STANDARD' AUTO_SUSPEND = 60 AUTO_RESUME = TRUE COMMENT = 'Warehouse to transform data';

-- creating database
CREATE DATABASE YFAEP_DATABASE COMMENT = 'your first analytics engineering project';

-- creating an access role
CREATE ROLE YFAEP_TRANSFORMER COMMENT = 'Role for dbt';

-- granting role permissions
GRANT USAGE,OPERATE ON WAREHOUSE YFAEP_TRANSFORMING TO ROLE YFAEP_TRANSFORMER;
GRANT USAGE,CREATE SCHEMA ON DATABASE YFAEP_DATABASE TO ROLE YFAEP_TRANSFORMER;

GRANT USAGE ON DATABASE "FIVETRAN_DATABASE" TO ROLE YFAEP_TRANSFORMER;
GRANT USAGE ON SCHEMA "FIVETRAN_DATABASE"."HUBSPOT" TO ROLE YFAEP_TRANSFORMER;
GRANT SELECT ON ALL TABLES IN SCHEMA "FIVETRAN_DATABASE"."HUBSPOT" TO ROLE YFAEP_TRANSFORMER;
GRANT SELECT ON FUTURE TABLES IN SCHEMA "FIVETRAN_DATABASE"."HUBSPOT" TO ROLE YFAEP_TRANSFORMER;

GRANT USAGE ON DATABASE YFAEP_DATABASE TO ROLE YFAEP_TRANSFORMER;
GRANT USAGE ON ALL SCHEMAS IN DATABASE YFAEP_DATABASE TO ROLE YFAEP_TRANSFORMER;
GRANT SELECT ON ALL TABLES IN DATABASE YFAEP_DATABASE TO ROLE YFAEP_TRANSFORMER;

GRANT USAGE ON FUTURE SCHEMAS IN DATABASE YFAEP_DATABASE TO ROLE YFAEP_TRANSFORMER;
GRANT SELECT ON FUTURE TABLES IN DATABASE YFAEP_DATABASE TO ROLE YFAEP_TRANSFORMER;


-- creating user and associating with role
CREATE USER YFAEP_DBT_CLOUD PASSWORD='abc123' DEFAULT_ROLE = YFAEP_TRANSFORMER;
-- Make sure you change the above password! Add the flag -- MUST_CHANGE_PASSWORD = true to force a password change too
GRANT ROLE YFAEP_TRANSFORMER TO USER YFAEP_DBT_CLOUD;

-- grant all roles to sysadmin (always do this)
GRANT ROLE YFAEP_TRANSFORMER  TO ROLE SYSADMIN;
```

# example 2 - only consuming from data warehouse e.g. reporting tools
```sql
USE ROLE ACCOUNTADMIN; -- you need accountadmin for user creation, future grants
DROP USER IF EXISTS DBT_BUSINESS_INTELLIGENCE_FLEXIT;
DROP ROLE IF EXISTS DBT_BUSINESS_INTELLIGENCE_FLEXIT_REPORTER;
DROP WAREHOUSE IF EXISTS DBT_BUSINESS_INTELLIGENCE_FLEXIT_REPORTING;
-- creating a warehouse
CREATE WAREHOUSE DBT_BUSINESS_INTELLIGENCE_FLEXIT_REPORTING WITH WAREHOUSE_SIZE = 'XSMALL' WAREHOUSE_TYPE = 'STANDARD' AUTO_SUSPEND = 60 AUTO_RESUME = TRUE COMMENT = 'Warehouse to transform data';

-- creating an access role
CREATE ROLE DBT_BUSINESS_INTELLIGENCE_FLEXIT_REPORTER COMMENT = 'Role for FLEXIT';
-- granting role permissions
GRANT USAGE,OPERATE ON WAREHOUSE DBT_BUSINESS_INTELLIGENCE_FLEXIT_REPORTING TO ROLE DBT_BUSINESS_INTELLIGENCE_FLEXIT_REPORTER;

GRANT USAGE ON DATABASE DBT_BUSINESS_INTELLIGENCE TO ROLE DBT_BUSINESS_INTELLIGENCE_FLEXIT_REPORTER;
GRANT USAGE ON ALL SCHEMAS IN DATABASE DBT_BUSINESS_INTELLIGENCE TO ROLE DBT_BUSINESS_INTELLIGENCE_FLEXIT_REPORTER;
GRANT SELECT ON ALL TABLES IN DATABASE DBT_BUSINESS_INTELLIGENCE TO ROLE DBT_BUSINESS_INTELLIGENCE_FLEXIT_REPORTER;

GRANT USAGE ON FUTURE SCHEMAS IN DATABASE DBT_BUSINESS_INTELLIGENCE TO ROLE DBT_BUSINESS_INTELLIGENCE_FLEXIT_REPORTER;
GRANT SELECT ON FUTURE TABLES IN DATABASE DBT_BUSINESS_INTELLIGENCE TO ROLE DBT_BUSINESS_INTELLIGENCE_FLEXIT_REPORTER;


-- creating user and associating with role
CREATE USER DBT_BUSINESS_INTELLIGENCE_FLEXIT PASSWORD='abc123' DEFAULT_ROLE = DBT_BUSINESS_INTELLIGENCE_FLEXIT_REPORTER;
-- Make sure you change the above password! Add the flag -- MUST_CHANGE_PASSWORD = true to force a password change too
GRANT ROLE DBT_BUSINESS_INTELLIGENCE_FLEXIT_REPORTER TO USER DBT_BUSINESS_INTELLIGENCE_FLEXIT;
-- grant all roles to sysadmin (always do this)
GRANT ROLE DBT_BUSINESS_INTELLIGENCE_FLEXIT_REPORTER  TO ROLE SYSADMIN;
```