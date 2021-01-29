#!/bin/bash

# Defaults
NOMINATIM_DATA_PATH=${NOMINATIM_DATA_PATH:="/srv/nominatim/data"}
NOMINATIM_DATA_LABEL=${NOMINATIM_DATA_LABEL:="data"}
NOMINATIM_PBF_URL=${NOMINATIM_PBF_URL:="http://download.geofabrik.de/asia/maldives-latest.osm.pbf"}
PG_DIR=${PG_DIR:="postgresdata"}

# Start PostgreSQL
service postgresql start
export PGDATA=/data/$PG_DIR

if [ -z "$(ls -A /data/$PG_DIR)" ] || [ "$ENABLE_IMPORT" = False ]; then
   echo "[*] starting data import and database initialization"
   # Retrieve the PBF file
   curl -L $NOMINATIM_PBF_URL --create-dirs -o $NOMINATIM_DATA_PATH/$NOMINATIM_DATA_LABEL.osm.pbf
   # Allow user accounts read access to the data
   chmod 755 $NOMINATIM_DATA_PATH



# Import data download
   rm -rf /data/$PG_DIR
   mkdir -p /data/$PG_DIR
   chown postgres:postgres /data/$PG_DIR

   sudo -u postgres /usr/lib/postgresql/12/bin/initdb -D /data/$PG_DIR
   sudo -u postgres /usr/lib/postgresql/12/bin/pg_ctl -D /data/$PG_DIR start


   sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='nominatim'" | grep -q 1 || sudo -u postgres createuser -s nominatim
   sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='www-data'" | grep -q 1 || sudo -u postgres createuser -SDR www-data
   sudo -u postgres psql postgres -c "DROP DATABASE IF EXISTS nominatim"
   useradd -m -p password1234 nominatim
   sudo -u nominatim ./srv/nominatim/build/utils/setup.php --osm-file $NOMINATIM_DATA_PATH/$NOMINATIM_DATA_LABEL.osm.pbf --all --threads 4
   sudo -u nominatim ./srv/nominatim/build/utils/check_import_finished.php
   sudo -u postgres /usr/lib/postgresql/12/bin/pg_ctl -D /data/$PG_DIR stop
   #sudo chown -R postgres:postgres /data/$PG_DIR

else
   echo "[*] Importing from existing database"
   chown postgres:postgres /data/$PG_DIR
   sudo -u postgres /usr/lib/postgresql/12/bin/initdb -D  /data/$PG_DIR
   sudo -u postgres /usr/lib/postgresql/12/bin/pg_ctl -D /data/$PG_DIR start
   sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='nominatim'" | grep -q 1 || sudo -u postgres createuser -s nominatim
   sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='www-data'" | grep -q 1 || sudo -u postgres createuser -SDR www-data
fi




# Tail Apache logs
tail -f /var/log/apache2/* &

/usr/sbin/apache2ctl -D FOREGROUND