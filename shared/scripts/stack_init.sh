#!/bin/bash

function check_env_exists() {
	if [ -f "$PWD/.env" ]; then
		echo ".env"
	elif [ -f "$PWD/example.env" ]; then
		echo "example.env"
	else
		echo "false"
	fi
}

function set_redis_password() {
	echo "called set redis passwd func"
	local passwd_set="false"
	local key=""
	local val=""
	while read line; do
		#echo "$line"
		key=$(echo "$line" | tr '=' ' ' | awk '{print $1}')
		val=$(echo "$line" | tr '=' ' ' | awk '{print $2}')
		if [[ "$key" == "REDIS_PASSWORD" ]] && [ -z "$val" ]; then
			echo "ERROR: Redis password is not set"
			exit 1
		elif [[ "$key" == "REDIS_PASSWORD" ]] && [ -n "$val" ]; then
			echo "requirepass $val" | sudo tee redis/config/passwd.conf
			passwd_set="true"
		fi
	done < .env

	if [[ "$passwd_set" == "false" ]]; then
		echo "ERROR: .env file found but redis password environment could not be found."
		echo "Make sure to set it in the .env file in the format REDIS_PASSWORD=<password>"
		exit 1
	fi
}

# Find .env f
env_file="false"
while [[ "$env_file" == "false" ]]; do
	echo "$PWD"
	env_file=$(check_env_exists)
	if [[ "$env_file" == ".env" ]]; then
		echo "env file found"
		set_redis_password
	elif [[ "$env_file" == "example.env" ]]; then
		echo "example.env found"
		mv example.env .env
		set_redis_password
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
[ ! -f "pihole/logs/pihole.log" ] && touch pihole/logs/pihole-FTL.log
[ ! -f "influxdb/.influx_history" ] && touch influxdb/.influx_history

echo "INFO: Generating .htpasswd and passwd files"
echo "you will need to insert a username and generate"
echo "an encrypted password into these files in the form"
echo "username:password"
[ ! -f "mosquitto/config/passwd" ] && touch mosquitto/config/passwd || echo "mosquitto/config/passwd exists; leaving alone"
[ ! -f "shared/.htpasswd" ] && touch shared/.htpasswd || echo "shared/.htpasswd exists; leaving alone"
[ ! -f "shared/passwd" ] && touch shared/passwd || echo "shared/passwd exists; leaving alone"

echo "INFO: Setting user and group of directories"
sudo chown ${USER:=$(/usr/bin/id -run)}:docker docker-compose.yml
sudo chown ${USER:=$(/usr/bin/id -run)}:docker .env
sudo chown -R ${USER:=$(/usr/bin/id -run)}:docker grafana/
sudo chown -R root:root ha-dockermon/
sudo chown -R ${USER:=$(/usr/bin/id -run)}:docker heimdall/
sudo chown -R root:root homeassistant/
sudo chown -R ${USER:=$(/usr/bin/id -run)}:docker influxdb/
sudo chown -R ${USER:=$(/usr/bin/id -run)}:docker jackett/
sudo chown -R ${USER:=$(/usr/bin/id -run)}:docker lidarr/
sudo chown -R root:root mosqitto/
sudo chown -R www-data:docker nextcloud/
sudo chown -R ${USER:=$(/usr/bin/id -run)}:docker organizr/
sudo chown -R root:root pihole/
sudo chown -R ${USER:=$(/usr/bin/id -run)}:docker plex/
sudo chown -R ${USER:=$(/usr/bin/id -run)}:docker postgres/
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

