#!/bin/bash
sysctl -p
systemctl daemon-reexec
systemctl daemon-reload
systemctl restart x-ui
systemctl enable x-ui
exit 0
