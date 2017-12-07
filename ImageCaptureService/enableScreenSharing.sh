#!/bin/sh

/usr/libexec/PlistBuddy -c 'Set :com.apple.screensharing:Disabled NO' /var/db/launchd.db/com.apple.launchd/overrides.plist
launchctl load -w /System/Library/LaunchDaemons/com.apple.screensharing.plist

exit 5
