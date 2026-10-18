#!/bin/bash
# ========================================
# Script to Add Applications to Login Items on macOS
# ========================================

osascript -e 'tell application "System Events" to make new login item at end with properties {name: "Vorssaint", path: "/Applications/Vorssaint.app", hidden: true}'