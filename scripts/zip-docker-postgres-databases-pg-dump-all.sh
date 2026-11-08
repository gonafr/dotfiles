#!/bin/bash
# ========================================
# Script to Backup ALL PostgreSQL Databases Running in Docker using pg_dumpall
# Usage: ./zip-docker-postgres-databases-pg-dump-all.sh [user]
# Dumps every database in the cluster, plus global objects (roles, tablespaces),
# into a single SQL file and compresses it with gzip. The user defaults to 'postgres' and must
# be a superuser to read all databases and roles.

# Restore with:
#   gunzip -c all-databases-backup-<timestamp>.sql.gz | docker exec -i postgres psql -U postgres -f - postgres

# As output files are created with timestamp in the folder you run this script
# You can run this script multiple times without overwriting previous backups.
# ========================================

set -e

PG_USER="${1:-postgres}"
CONTAINER="postgres"
DUMP_FILE="all-databases-backup.sql"

timestamp=$(date +"%Y%m%d%H%M")
echo "Starting pg_dumpall backup process at $timestamp"

if ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER"; then
    echo "Error: the '$CONTAINER' container is not running."
    exit 1
fi

# Check for gzip up front so we fail before dumping, not after
if ! command -v gzip >/dev/null 2>&1; then
    echo "Error: 'gzip' is not installed."
    exit 1
fi

OUTPUT="all-databases-backup-$timestamp.sql.gz"

# Always clean up temporary files, even if a step fails
cleanup() {
    rm -f "$DUMP_FILE"
    docker exec "$CONTAINER" rm -f "/tmp/$DUMP_FILE" >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "Dumping all databases with user '$PG_USER'..."

# Run pg_dumpall inside the PostgreSQL container
docker exec -t "$CONTAINER" pg_dumpall -U "$PG_USER" -f "/tmp/$DUMP_FILE"

# Copy the SQL file from the container to the host
docker cp "$CONTAINER:/tmp/$DUMP_FILE" .

# Compress with timestamped filename
gzip -c "$DUMP_FILE" > "$OUTPUT"

echo "Backup completed: $OUTPUT"
