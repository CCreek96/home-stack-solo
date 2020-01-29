<?php
$CONFIG = array (
  # General config settings
  'updater.release.channel' => 'stable',
  'appcodechecker' => true,
  'datadirectory' => '/opt/data',
  'share_folder' => '/opt/data/shared',
  'enable_previews' => true,
  'preview_libreoffice_path' => '/usr/bin/libreoffice',
  #'theme' => '',

  # HTTP settings
  'htaccess.RewriteBase' => '/',
  'overwritehost' => 'nextcloud.'.getenv('DOMAIN_NAME'),
  'overwriteprotocol' => 'https',
  'overwrite.cli.url' => 'https://nextcloud.'.getenv('DOMAIN_NAME'),
  'login_form_autocomplete' => false,
  'remember_login_cookie_lifetime' => 60*60*24*5,
  'session_lifetime' => 60*60*24,
  'lost_password_link' => 'disabled',
  'trusted_domains' => 
  array(
    0 => getenv('DOMAIN_NAME'),
    1 => 'nextcloud.'.getenv('DOMAIN_NAME'),
  ),
  'trusted_proxies' => 
  array(
    0 => 'traefik',
  ),
  'forwarded_for_headers' =>
  array(
    0 => 'HTTP_X_FORWARDED_FOR',
    1 => 'HTTP_CF_CONNECTING_IP',
  ),

  # Redis settings
  'memcache.local' => '\OC\Memcache\APCu',
  'memcache.distributed' => '\OC\Memcache\Redis',
  'memcache.locking' => '\OC\Memcache\Redis',
  'redis' => array(
    'host' => getenv('REDIS_HOST'),
    'password' => getenv('REDIS_HOST_PASSWORD'),
    'dbindex' => (int) getenv('REDIS_HOST_DBINDEX'),
  ),

  # Database settings
  'dbtype' => 'pgsql',
  'dbname' => getenv('POSTGRES_DB'),
  'dbuser' => getenv('POSTGRES_USER'),
  'dbpassword' => getenv('POSTGRES_PASSWORD'),
  'dbhost' => getenv('POSTGRES_HOST'),
  'dbtableprefix' => getenv('NEXTCLOUD_TABLE_PREFIX') ?: '',

  # SMTP settings
  #'mail_smtpmode' => 'smtp',
  #'mail_smtphost' => getenv('SMTP_HOST'),
  #'mail_smtpport' => getenv('SMTP_PORT') ?: (getenv('SMTP_SECURE') ? 465 : 25),
  #'mail_smtpsecure' => getenv('SMTP_SECURE') ?: '',
  #'mail_smtpauth' => getenv('SMTP_NAME') && getenv('SMTP_PASSWORD'),
  #'mail_smtpauthtype' => getenv('SMTP_AUTHTYPE') ?: 'LOGIN',
  #'mail_smtpname' => getenv('SMTP_NAME') ?: '',
  #'mail_smtppassword' => getenv('SMTP_PASSWORD') ?: '',
  #'mail_from_address' => getenv('MAIL_FROM_ADDRESS'),
  #'mail_domain' => getenv('MAIL_DOMAIN'),

  # Logging settings
  ##'log_type' => 'file',
  ##'logfile' => '/var/log/nextcloud/nextcloud.log',
  ##'logfilemode' => 0640,
  'loglevel' => 0,
  'logtimezone' => 'America/Chicago',
  'log_rotate_size' => 100*1024*1024, 
);

if (getenv('REDIS_HOST_PORT') !== false) {
  $CONFIG['redis']['port'] = (int) getenv('REDIS_HOST_PORT');
} elseif (getenv('REDIS_HOST')[0] != '/') {
  $CONFIG['redis']['port'] = 6379;
}

