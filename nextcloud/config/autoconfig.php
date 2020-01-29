<?php
$autoconfig_enabled = true;
$AUTOCONFIG = array(
  'dbtype' => "pgsql";
  'dbname' => getenv('POSTGRES_DB'),
  'dbuser' => getenv('POSTGRES_USER'),
  'dbpass' => getenv('POSTGRES_PASSWORD'),
  'dbhost' => getenv('POSTGRES_HOST'),
  'dbtableprefix' => getenv('NEXTCLOUD_TABLE_PREFIX') ?: '',
  'adminlogin' => getenv('NEXTCLOUD_ADMIN_USER'),
  'adminpass' => getenv('NEXTCLOUD_ADMIN_PASSWORD'),
  'directory' => getenv('NEXTCLOUD_DATA_DIR') ?: '/opt/data',
);
