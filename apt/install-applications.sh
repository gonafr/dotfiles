#!/bin/bash
# ========================================
# Script to Install Applications on Linux (Debian/Ubuntu) that are not available in the default apt repositories
# ========================================

# Oxker CLI
mkdir -p /tmp/oxker-install && cd /tmp/oxker-install
curl https://raw.githubusercontent.com/mrjackwills/oxker/main/install.sh | bash