# Project Domino Nominatim node #



*postgres is tuned for a 64 gb machine*

*setup.php is tuned to 16 threads*

For the initial import, the following are set: <br>
fsync = off <br>
full_page_writes = off <br>
***Don't forget to reenable them after the initial import or you risk database corruption.***

Node is tuned to receive *North America* with continuous updates upon import <br>
can change by environment variable on the compose or in the **docker-entrypoint.sh** or **local.php**

in **data/caddy/Caddyfile**  *box_ip* should be replaced with the IP of your server.


***for further information see the administration guide at https://nominatim.org/release-docs/latest/admin/Installation/***