#!/bin/bash
# ========================================
# Script to Add Applications to Login Items on macOS
# ========================================

osascript -e 'tell application "System Events" to make new login item at end with properties {name: "Handy", path: "/Applications/Handy.app", hidden: true}'
osascript -e 'tell application "System Events" to make new login item at end with properties {name: "HazeOver", path: "/Applications/HazeOver.app", hidden: true}'
osascript -e 'tell application "System Events" to make new login item at end with properties {name: "Logi Options+", path: "/Applications/logioptionsplus.app", hidden: true}'
osascript -e 'tell application "System Events" to make new login item at end with properties {name: "Vorssaint", path: "/Applications/Vorssaint.app", hidden: true}'
