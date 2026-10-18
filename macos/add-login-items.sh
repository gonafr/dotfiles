#!/bin/bash
# ========================================
# Script to Add Applications to Login Items on macOS
# ========================================

osascript -e 'tell application "System Events" to make new login item at end with properties {name: "Ice", path: "/Applications/Ice.app", hidden: true}'
osascript -e 'tell application "System Events" to make new login item at end with properties {name: "KeepingYouAwake", path: "/Applications/KeepingYouAwake.app", hidden: true}'
osascript -e 'tell application "System Events" to make new login item at end with properties {name: "KeyClu", path: "/Applications/KeyClu.app", hidden: true}'
osascript -e 'tell application "System Events" to make new login item at end with properties {name: "Rectangle", path: "/Applications/Rectangle.app", hidden: true}'
osascript -e 'tell application "System Events" to make new login item at end with properties {name: "Stats", path: "/Applications/Stats.app", hidden: true}'