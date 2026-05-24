#!/bin/bash

mkdir -p ~/.local/state/containerd
mkdir -p ~/.config/systemd/user/containerd.service.d
cat > ~/.config/systemd/user/containerd.service.d/override.conf << EOF
[Service]
StandardOutput=append:%h/.local/state/containerd/containerd.log
StandardError=append:%h/.local/state/containerd/containerd.log
EOF

systemctl --user daemon-reload
systemctl --user restart containerd
sleep 10
systemctl --user status containerd


nerdctl rm nginx
nerdctl run -d --name nginx -p 127.0.0.1:8080:80 ghcr.io/stargz-containers/nginx:1.19-alpine-org
nerdctl ps -a

cat ~/.local/state/containerd/containerd.log
