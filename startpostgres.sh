#!/bin/bash


chown postgres:postgres -R /var/lib/postgresql/12/main

service postgresql start
tail -f /var/log/postgresql/postgresql-12-main.log