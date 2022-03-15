#! /bin/bash

# Script to package all the rule files and start a web server making the rule
# files available locally via http://localhost:8080/servers.txt.

export BASEPATH=http://localhost:8080
./package-all.sh

docker build --tag rc-rules-server .
docker run -d -p 8080:80 --name rc-rules rc-rules-server

echo "Rules are now being served at http://localhost:8080"