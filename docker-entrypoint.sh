#!/bin/bash

# Defaults
NOMINATIM_DATA_PATH=${NOMINATIM_DATA_PATH:="/srv/nominatim/data"}
NOMINATIM_DATA_LABEL=${NOMINATIM_DATA_LABEL:="data"}
NOMINATIM_PBF_URL=${NOMINATIM_PBF_URL:="http://download.geofabrik.de/asia/maldives-latest.osm.pbf"}


# Retrieve the PBF file
curl -L $NOMINATIM_PBF_URL --create-dirs -o $NOMINATIM_DATA_PATH/$NOMINATIM_DATA_LABEL.osm.pbf
# Allow user accounts read access to the data
chmod 755 $NOMINATIM_DATA_PATH

# Start PostgreSQL
#service postgresql start

# Import data
rm -rf /data/postgresdata
mkdir -p /data/postgresdata
chown postgres:postgres /data/postgresdata
sudo -u postgres /usr/lib/postgresql/12/bin/initdb -D /data/postgresdata
sudo -u postgres /usr/lib/postgresql/12/bin/pg_ctl -D /data/postgresdata start


sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='nominatim'" | grep -q 1 || sudo -u postgres createuser -s nominatim
sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='www-data'" | grep -q 1 || sudo -u postgres createuser -SDR www-data
sudo -u postgres psql postgres -c "DROP DATABASE IF EXISTS nominatim"
useradd -m -p password1234 nominatim
sudo -u nominatim /srv/nominatim/build/utils/setup.php --osm-file $NOMINATIM_DATA_PATH/$NOMINATIM_DATA_LABEL.osm.pbf --all --threads 2
sudo -u nominatim ./srv/nominatim/build/utils/check_import_finished.php


sudo -u postgres /usr/lib/postgresql/12/bin/pg_ctl -D /data/postgresdata stop
sudo chown -R postgres:postgres /data/postgresdata