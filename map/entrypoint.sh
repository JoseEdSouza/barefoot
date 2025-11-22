#!/bin/bash
set -e

# Define database name from environment variable
DB_NAME="${OSM_DB_NAME}"

# Start the cluster temporarily to check/import data
# Using pg_ctlcluster wrapper specific to Debian/Ubuntu based images
pg_ctlcluster 9.3 main start

# Check if the database exists
if sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='${DB_NAME}'" | grep -q 1; then
    echo "Database '${DB_NAME}' already exists. Skipping initialization."
else
    echo "Database '${DB_NAME}' not found. Running import.sh..."

    # Validation for PBF path
    if [ "$OSM_PBF_PATH" = "NULL" ] || [ ! -f "$OSM_PBF_PATH" ]; then
      echo "ERROR: OSM_PBF_PATH is not set or file does not exist: $OSM_PBF_PATH"
      exit 1
    fi

    # Execute the import script
    bash /mnt/map/osm/import.sh \
      "${OSM_PBF_PATH}" \
      "${OSM_DB_NAME}" \
      "${OSM_DB_USER}" \
      "${OSM_DB_PASSWORD}" \
      "/mnt/map/tools/road-types.json" \
      "slim"
fi

# Stop the temporary cluster
echo "Stopping temporary cluster..."
pg_ctlcluster 9.3 main stop

# Start Postgres in FOREGROUND (Official Docker way)
# This replaces 'service start && sleep infinity'
# We execute the binary directly so it becomes the main process
echo "Starting PostgreSQL 9.3 in foreground..."

exec sudo -u postgres /usr/lib/postgresql/9.3/bin/postgres \
    -D /var/lib/postgresql/9.3/main \
    -c config_file=/etc/postgresql/9.3/main/postgresql.conf