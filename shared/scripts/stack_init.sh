#!/bin/bash

influxdb_user=""
admin_password=""

function check_env_exists() {
	if [ -f "$PWD/.env" ]; then
		echo ".env"
	elif [ -f "$PWD/example.env" ]; then
		echo "example.env"
	else
		echo "false"
	fi
}

function check_redis_password() {
	local env_passwd=$1
	local passwd=""
	if [ ! -f "$PWD/redis/config/password.conf" ]; then
		echo "false"
	else
		while read line; do
			passwd=$(echo "$line" | awk '{print $2}')
			if [[ "$env_passwd" == "$passwd" ]]; then
				echo "true"
			else
				echo "false"
			fi
		done < redis/config/password.conf
	fi
}

function scan_env() {
	local redis_passwd_set="false"
	local influx_user_set="false"
	local admin_passwd_set="false"
	local key=""
	local val=""
	while read line; do
		key=$(echo "$line" | tr '=' ' ' | awk '{print $1}')
		val=$(echo "$line" | tr '=' ' ' | awk '{print $2}')
		if [[ "$key" == "INFLUXDB_USER" ]] && [ -n "$val" ]; then
			$influxdb_user="$val"
			influx_user_set="true"
		elif [[ "$key" == "ADMIN_PASSWORD" ]] && [ -n "$val" ]; then
			$admin_password="$val"
			admin_passwd_set="true"
		elif [[ "$key" == "REDIS_PASSWORD" ]] && [ -n "$val" ]; then
			redis_passwd_set=$(check_redis_pwd $val)
			if  [[ "$redis_passwd_set" == "false" ]]; then
				echo "requirepass $val" | sudo tee redis/config/passwd.conf
				redis_passwd_set="true"
			fi
		fi
	done < .env

	if [[ "$redis_passwd_set" == "false" ]]; then
		echo "ERROR: .env file found but redis password environment could not be found."
		echo "Make sure to set it in the .env file in the format REDIS_PASSWORD=<password>"
		exit 1
	fi
	if [[ "$influx_user_set" == "false" ]]; then
		echo "ERROR: .env file found but influx admin username environment could not be found."
		echo "Make sure to set it in the .env file in the format INFLUX_ADMIN_USER=<username>"
		exit 1
	fi
	if [[ "$admin_passwd_set" == "false" ]]; then
		echo "ERROR: .env file found but influx admin password environment could not be found."
		echo "Make sure to set it in the .env file in the format INFLUX_ADMIN_PASSWORD=<password>"
		exit 1
	fi
}

# Find .env file
env_file="false"
while [[ "$env_file" == "false" ]]; do
	echo "$PWD"
	env_file=$(check_env_exists)
	if [[ "$env_file" == ".env" ]]; then
		scan_env
	elif [[ "$env_file" == "example.env" ]]; then
		mv example.env .env
		scan_env
	elif [ "$PWD" == "/" ]; then
		echo "ERROR: neither the .env or example.env file could be found"
		echo "make sure one of these exist in the home_stack directory and"
		echo "that you are calling this script from that directory or one"
		echo "of its sub-directories"
		exit 1
	else
		cd ../
	fi
done

echo "INFO: Generating log files"
[ ! -d "pihole/logs" ] && mkdir pihole/logs
[ ! -f "pihole/logs/pihole.log" ] && touch pihole/logs/pihole.log
[ ! -f "pihole/logs/pihole-FTL.log" ] && touch pihole/logs/pihole-FTL.log
[ ! -f "influxdb/.influx_history" ] && touch influxdb/.influx_history

echo "INFO: Generating .htpasswd and passwd files"
echo "you will need to insert a username and generate an encrypted password into these files in the form username:password"
[ ! -f "mosquitto/config/passwd" ] && touch mosquitto/config/passwd || echo "mosquitto/config/passwd exists; leaving alone"
[ ! -f "shared/.htpasswd" ] && touch shared/.htpasswd || echo "shared/.htpasswd exists; leaving alone"
[ ! -f "shared/passwd" ] && touch shared/passwd || echo "shared/passwd exists; leaving alone"

echo "INFO: Moving postgres config files"
[ ! -d "postgres/data" ] && mkdir postgres/data/
if [ -f "postgres/config/pg_hba.conf" ] && [ ! -f "postgres/data/pg_hba.conf" ]; then
       	mv postgres/config/pg_hba.conf postgres/data
fi
if [ -f "postgres/config/pg_ident.conf" ] && [ ! -f "postgres/data/pg_ident.conf" ]; then
       	mv postgres/config/pg_ident.conf postgres/data
fi
if [ -f "postgres/config/postgresql.conf" ] && [ ! -f "postgres/data/postgresql.conf" ]; then
	mv postgres/config/postgresql.conf postgres/data
fi

echo "INFO: Setting user and group of directories"
sudo chown ${USER:=$(/usr/bin/id -run)}:docker docker-compose.yml
sudo chown ${USER:=$(/usr/bin/id -run)}:docker .env
sudo chown -R root:root ha-dockermon/
sudo chown -R ${USER:=$(/usr/bin/id -run)}:docker heimdall/
sudo chown -R root:root homeassistant/
sudo chown -R ${USER:=$(/usr/bin/id -run)}:docker jackett/
sudo chown -R ${USER:=$(/usr/bin/id -run)}:docker lidarr/
sudo chown -R root:root mosquitto/
sudo chown -R www-data:docker nextcloud/
sudo chown -R ${USER:=$(/usr/bin/id -run)}:docker organizr/
sudo chown -R root:root pihole/
sudo chown -R ${USER:=$(/usr/bin/id -run)}:docker plex/
sudo chown -R ${USER:=$(/usr/bin/id -run)}:docker prometheus/
sudo chown -R ${USER:=$(/usr/bin/id -run)}:docker radarr/
sudo chown -R root:root redis/
sudo chown -R ${USER:=$(/usr/bin/id -run)}:docker shared/
sudo chown -R ${USER:=$(/usr/bin/id -run)}:docker sonarr/
sudo chown -R ${USER:=$(/usr/bin/id -run)}:docker tautulli/
sudo chown -R ${USER:=$(/usr/bin/id -run)}:docker telegraf/
sudo chown -R root:root traefik/
sudo chown -R ${USER:=$(/usr/bin/id -run)}:docker transmission/
sudo chown -R ${USER:=$(/usr/bin/id -run)}:docker varken/


echo "INFO: setting up Influxdb"
docker run --rm -u ${USER:=$(/user/bin/id -run)}
	-e INFLUXDB_HTTP_AUTH_ENABLED=true \
	-e INFLUXDB_ADMIN_USER=$influxdb_admin \
        -e INFLUXDB_ADMIN_PASSWORD=$admin_password \
        -v /var/lib/influxdb:/var/lib/influxdb \
        -v ./shared/scripts/nfluxdb-init.iql:/docker-entrypoint-initdb.d/influxdb-init.iql \
        influxdb /init-influxdb.sh
sudo chown -R ${USER:=$(/usr/bin/id -run)}:docker influxdb/

echo "INFO: setting up Postgres"
sudo chown -R ${USER:=$(/usr/bin/id -run)}:docker postgres/

echo "INFO: setting up Grafana"
sudo chown -R ${USER:=$(/usr/bin/id -run)}:docker grafana/
