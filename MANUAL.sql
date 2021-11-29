/* To optimize te Snowflake resource usage through caching intermediate results,
Datafold requires a dedicated schema with write access */
CREATE SCHEMA ANALYTICS_TPCH.DATAFOLD_TMP;
GRANT ALL ON SCHEMA ANALYTICS_TPCH.DATAFOLD_TMP TO DATAFOLD;
CREATE SCHEMA ANALYTICS_TPCH_DEV.DATAFOLD_TMP;
GRANT ALL ON SCHEMA ANALYTICS_TPCH_DEV.DATAFOLD_TMP TO DATAFOLD;
/* To provide column-level lineage, Datafold needs to read & parse all SQL statements
executed in your Snowflake account */
GRANT MONITOR EXECUTION ON ACCOUNT TO ROLE DATAFOLD;
GRANT IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE TO ROLE DATAFOLD;