#!/bin/bash

# اعمال تنظیمات کرنل
sysctl -p

# ری‌لود سیستم‌دی و ری‌استارت x-ui
systemctl daemon-reexec
systemctl daemon-reload
systemctl restart x-ui
systemctl enable x-ui
