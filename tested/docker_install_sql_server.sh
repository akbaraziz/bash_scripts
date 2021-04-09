#!/bin/bash
# Script author: Akbar Aziz
# Script site: https://github.com/akbaraziz/bash_scripts/blob/master/tested/docker_install_sql_server.sh
# Script date: 06/05/2020
# Script ver: 1.0.0
# Script purpose: To install SQL Server 2019 on Linux
# Script tested on OS: CentOS and Redhat 7.x
#--------------------------------------------------

set -ex

# Install SQL Server 2019
sudo docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=<YourStrong!Passw0rd>' \
-p 1433:1433 --name sql2019 \
-v /users/xxxx/mssql:/mssql \
-d mcr.microsoft.com/mssql/server:2019-latest
