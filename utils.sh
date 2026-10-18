#!/bin/bash
# ========================================
# Utility Functions and Variables
# This script contains common functions and variables used across the various scripts
# ========================================
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helpers for printing steps and results in a consistent format.
print_step() { echo -e "${NC}➜ $1"; }
print_info() { echo -e "${GREEN}[INFO]${NC} ${1}"; }
print_ok()   { echo -e "${GREEN}✔ [OK]${NC} ${1}"; }
print_warning() { echo -e "${YELLOW}⚠ [WARNING]${NC} ${1}"; }
print_error() { echo -e "${RED}✘ [ERROR]${NC} ${1}"; }