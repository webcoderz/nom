# Nominatim node #

Machine Specifications: ***4 cores or greater, 64GB memory 1TB NVME***

*postgres is tuned for a 64 gb machine*

*setup.php is tuned to 16 threads*

For the initial import, the following are set: <br>
fsync = off <br>
full_page_writes = off <br>
***Don't forget to reenable them after the initial import or you risk database corruption.***
 make this change in */etc/postgresql/12/main/postgresql.conf*
 
**1: su - postgres <br>
2: export PGDATA=/data/postgresdata <br>
3: /usr/lib/postgresql/12/bin/pg_ctl reload**

Node is tuned to receive *North America* with continuous updates upon import <br>
can change by environment variable on the compose or in the **docker-entrypoint.sh** or **local.php**

in **data/caddy/Caddyfile**  *box_ip* should be replaced with the IP of your server.


***for further information see the administration guide at https://nominatim.org/release-docs/latest/admin/Installation/***
