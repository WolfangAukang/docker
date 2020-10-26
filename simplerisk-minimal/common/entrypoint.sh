#!/bin/bash

set -exo pipefail

print_log(){
    echo "$(date -u +"[%a %b %e %X.%6N %Y]") [$1] $2"
}

exec_cmd(){
    exec_cmd_nobail "$1" || fatal_error "$2"
}

exec_cmd_nobail() {
    bash -c "$1"
}

fatal_error(){
    print_log "error" "$1"
    exit 1
}

set_db_password(){
    if [ ! -z "${FIRST_TIME_SETUP:-}" ]; then
        [ -z "${SIMPLERISK_DB_PASSWORD:-}" ] && SIMPLERISK_DB_PASSWORD=$(cat /dev/urandom | tr -dc _A-Z-a-z-0-9 | head -c 21) && \
          print_log "initial_setup:warn" "As no password was provided and this is a first time setup, a random password will be generated. Check /var/www/simplerisk/includes/config.php"|| \
          true
        sed -i "s/\('DB_PASSWORD', '\).*\(');\)/\1$(echo $SIMPLERISK_DB_PASSWORD)\2/g" $CONFIG_PATH
    else
        [ "${SIMPLERISK_DB_PASSWORD:-simplerisk}" != 'simplerisk' ] && sed -i "s/\('DB_PASSWORD', '\).*\(');\)/\1$(echo $SIMPLERISK_DB_PASSWORD)\2/g" $CONFIG_PATH || SIMPLERISK_DB_PASSWORD="simplerisk"
    fi
    echo $SIMPLERISK_DB_PASSWORD
}

set_config(){
    CONFIG_PATH='/var/www/simplerisk/includes/config.php'

    # Replacing config variables if they exist
    [ "${SIMPLERISK_DB_HOSTNAME:-localhost}" != 'localhost' ] && sed -i "s/\('DB_HOSTNAME', '\).*\(');\)/\1$(echo $SIMPLERISK_DB_HOSTNAME)\2/g" $CONFIG_PATH || SIMPLERISK_DB_HOSTNAME="localhost"

    [ "${SIMPLERISK_DB_PORT:-3306}" != '3306' ] && sed -i "s/\('DB_PORT', '\).*\(');\)/\1$(echo $SIMPLERISK_DB_PORT)\2/g" $CONFIG_PATH || SIMPLERISK_DB_PORT="3306"

    [ "${SIMPLERISK_DB_USERNAME:-simplerisk}" != 'simplerisk' ] && sed -i "s/\('DB_USERNAME', '\).*\(');\)/\1$(echo $SIMPLERISK_DB_USERNAME)\2/g" $CONFIG_PATH || SIMPLERISK_DB_USERNAME="simplerisk"

    SIMPLERISK_DB_PASSWORD=$(set_db_password)

    [ "${SIMPLERISK_DB_DATABASE:-simplerisk}" != 'simplerisk' ] && sed -i "s/\('DB_DATABASE', '\).*\(');\)/\1$(echo $SIMPLERISK_DB_DATABASE)\2/g" $CONFIG_PATH || SIMPLERISK_DB_DATABASE="simplerisk"

    [ ! -z "${SIMPLERISK_DB_FOR_SESSIONS:-}" ] && sed -i "s/\('USE_DATABASE_FOR_SESSIONS', '\).*\(');\)/\1$(echo $SIMPLERISK_DB_FOR_SESSIONS)\2/g" $CONFIG_PATH || true

    [ ! -z "${SIMPLERISK_DB_SSL_CERT_PATH:-}" ] && sed -i "s/\('DB_SSL_CERTIFICATE_PATH', '\).*\(');\)/\1$(echo $SIMPLERISK_DB_SSL_CERT_PATH)\2/g" $CONFIG_PATH || true
}

db_setup(){
    echo "${SIMPLERISK_DB_HOSTNAME:-none}"
    echo "${SIMPLERISK_DB_USERNAME:-none}"
    echo "${SIMPLERISK_DB_PASSWORD:-none}"
    echo "${SIMPLERISK_DB_DATABASE:-none}"
    echo "${SIMPLERISK_DB_PORT:-none}"
    
    print_log "initial_setup:info" "First time setup. Will wait..."
    exec_cmd "sleep ${FIRST_TIME_SETUP_WAIT:-20}s > /dev/null 2>&1" "FIRST_TIME_SETUP_WAIT variable is set incorrectly. Exiting."

    print_log "initial_setup:info" "Starting database set up"

    print_log "initial_setup:info" "Downloading schema..."
    SCHEMA_FILE='/tmp/simplerisk.sql'
    exec_cmd "curl -sL https://github.com/simplerisk/database/raw/master/simplerisk-en-$(cat /tmp/version).sql > $SCHEMA_FILE" "Could not download schema from Github. Exiting."

    FIRST_TIME_SETUP_USER="${FIRST_TIME_SETUP_USER:-root}"
    FIRST_TIME_SETUP_PASS="${FIRST_TIME_SETUP_PASS:-root}"

    print_log "initial_setup:info" "Applying changes to MySQL database... (MySQL error will be printed to console as guidance)"
    exec_cmd "mysql --protocol=socket -u $FIRST_TIME_SETUP_USER -p$FIRST_TIME_SETUP_PASS -h$SIMPLERISK_DB_HOSTNAME -P$SIMPLERISK_DB_PORT <<EOSQL
    CREATE DATABASE ${SIMPLERISK_DB_DATABASE};
    USE ${SIMPLERISK_DB_DATABASE};
    \. ${SCHEMA_FILE}
    CREATE USER ${SIMPLERISK_DB_USERNAME}@'%' IDENTIFIED BY '${SIMPLERISK_DB_PASSWORD}';
    GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, REFERENCES, INDEX, ALTER ON ${SIMPLERISK_DB_DATABASE}.* TO ${SIMPLERISK_DB_USERNAME}@'%';
EOSQL" "Was not able to apply settings on database. Check error above. Exiting."

    print_log "initial_setup:info" "Setup has been applied successfully!"
    print_log "initial_setup:info" "Removing schema file..."
    exec_cmd "rm ${SCHEMA_FILE}"

    if [ ! -z "${FIRST_TIME_SETUP_ONLY:-}" ]; then
        print_log "initial_setup:info" "Running on setup only. Container will be discarded."
        exit 0
    fi
}

unset_variables() {
    unset FIRST_TIME_SETUP
    unset FIRST_TIME_SETUP_ONLY
    unset FIRST_TIME_SETUP_USER
    unset FIRST_TIME_SETUP_PASS
    unset FIRST_TIME_SETUP_WAIT
    unset SIMPLERISK_DB_HOSTNAME
    unset SIMPLERISK_DB_PORT
    unset SIMPLERISK_DB_USERNAME
    unset SIMPLERISK_DB_PASSWORD
    unset SIMPLERISK_DB_DATABASE
    unset SIMPLERISK_DB_FOR_SESSIONS
    unset SIMPLERISK_DB_SSL_CERT_PATH
}

_main() {
    set_config
    if [ ! -z "${FIRST_TIME_SETUP:-}" ]; then
      db_setup
    fi
    unset_variables
    exec "$@"
}

_main "$@"
