#!/bin/bash
set -o pipefail
# ========================================
# Script to Backup PostgreSQL Databases Running in Docker
# Usage: ./zip-docker-postgres-databases.sh <user | user:database ...>
# Pass a single user (no ":") to discover and back up every database owned
# by that user, or a list of "user:database" pairs to back up specific ones.

# Configuration variables - Add more pairs as needed
# Format: "username:database_name"
# DATABASES="user1:database1 user2:database2 user3:database3"

# As output files are created with timestamp in the folder you run this script
# You can run this script multiple times without overwriting previous backups.
# ========================================

if [ $# -eq 0 ]; then
    echo "Error: no arguments provided."
    echo "Usage: $0 <user | user:database ...>"
    echo "  - Pass a single user (e.g. 'postgres') to back up every database owned by that user."
    echo "  - Pass one or more 'user:database' pairs (e.g. 'user1:database1 user2:database2') to back up specific databases."
    exit 1
elif [ $# -eq 1 ] && [[ "$1" != *:* ]]; then
    PG_USER="$1"
    echo "Discovering all databases owned by '$PG_USER'..."
    ALL_DBS=$(docker exec -t postgres psql -U "$PG_USER" -tAc \
        "SELECT datname FROM pg_database WHERE datistemplate = false;" | tr -d '\r')

    if [ -z "$ALL_DBS" ]; then
        echo "Error: could not discover any databases. Is the 'postgres' container running?"
        exit 1
    fi

    DATABASES=""
    for db in $ALL_DBS; do
        DATABASES="$DATABASES $PG_USER:$db"
    done
else
    DATABASES="$*"
fi

timestamp=$(date +"%Y%m%d%H%M")
echo "Starting backup process at $timestamp"

# Loop through each database configuration
for db_config in $DATABASES; do
    # Split the configuration into user and database name
    PG_USER=$(echo "$db_config" | cut -d':' -f1)
    DATABASE_NAME=$(echo "$db_config" | cut -d':' -f2)

    echo "Backing up database '$DATABASE_NAME' with user '$PG_USER'..."

    OUTPUT_FILE="${DATABASE_NAME}-backup-$timestamp.sql.gz"

    # Stream pg_dump from the container straight into gzip on the host.
    # No -t here: a TTY would mangle the binary-safe output stream.
    if ! docker exec postgres pg_dump -U "$PG_USER" "$DATABASE_NAME" | gzip > "$OUTPUT_FILE"; then
        echo "Error: backup of '$DATABASE_NAME' failed."
        rm -f "$OUTPUT_FILE"
        exit 1
    fi

    echo "Backup completed: $OUTPUT_FILE"
done

echo "All backups completed successfully!"