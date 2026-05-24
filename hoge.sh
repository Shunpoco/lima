#!/bin/bash

nerdctl rm nginx
nerdctl run -d --name nginx -p 127.0.0.1:8080:80 ghcr.io/stargz-containers/nginx:1.19-alpine-org

sleep 10

echo "AAAA!"
nerdctl ps -a
