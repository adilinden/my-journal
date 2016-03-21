---
layout: post
title: AppleScript Wrapper for rsync
date: 2012-10-07 19:57:10
comments: Yes
tags:
  - applescript
  - mac
  - osx
  - sysadmin

redirect_from:
  - /article/applescript-rsync/
category:
  - Sysadmin
assets: resources/2012-10-08-applescript-rsync
---

I like rsync... a lot. It is the perfect tool to keep large amounts of data synchronized across volumes. This especially true if the vast bulk of the data does not change. Until now I have been using a shell script to do the various rsync tasks I required. However, since I just braved the upgrade to Mountain Lion, leaving the beloved Snow Leopard in the dust, I decided to play with some AppleScript.

Here is the AppleScript I cooked up to keep two filesystem locations in sync using rsync. The script will prompt for instructions, such as to whether to upload or download. It also captures the rsync command output and offers to display it at the completion of the operation. Once completed, the very detailed log file is deleted and placed into the Trash. This allows for detailed forensics on the rsync process if desired.

{% highlight applescript %}
(*
    This script sync data up or down a network volume
     
    up   = send data from local volume to network volume
    down = send data from network volume to local volume
 
    This script requires the Mountain Lion. It also relies
    on the terminal-notifier command-line tool to send Mac
    OS X User Notifications. The terminal-notify.app is
    expected to live in "~/Scripts".
     
    terminal-notifier can be found at:
 
https://github.com/alloy/terminal-notifier
 
*)
 
-- Define network volume
set strUser to "Some User"
set strServer to "drive.example.net"
set strVolume to "Scratch"
 
-- Define network volume
set strNetwork to "/Volumes"
 
-- Define local volume
set strLocal to "/Volumes/Volatile/Local Cached"
 
-- Define data source
set strData to "Testing"
 
-- No user defines below --
global notifyApp
global notifyGroup
global notifyTitle
 
-- terminal-notify defines
set pathApp to "/Users/Adi/Scripts"
set pathBundle to "/terminal-notifier.app/Contents/MacOS/terminal-notifier"
set notifyApp to pathApp & pathBundle
set notifyGroup to "Sync-" & strData
set notifyTitle to "Sync"
 
-- Make sure we have terminal-notify
if not checkPath(notifyApp) then
    doError("Cannot find terminal-notify app…")
end if
 
-- rsync defines
set dryRun to true
set rsyncOpt to "-rlth --delete --stats -v"
set rsyncOutApple to (path to temporary items from user domain) & "Sync-rsync_out-" & (characters 3 thru end of ((random number) as string)) as string
set rsyncOut to POSIX path of rsyncOutApple
 
-- Ask user which way to sync
display dialog "Please specify whether to sync:
Up      (from local folder to network folder)
Down    (from network folder to local folder)" with title "Sync Direction" buttons {"Up", "Down"} default button 2
if button returned of result is equal to "Up" then
    set doUp to true
else if button returned of result is equal to "Down" then
    set doUp to false
else
    doError("Ooops…")
end if
 
-- Confirm
if doUp then
    display dialog "Pushing local data to network volume…" with title "Confirmation" buttons {"Abort", "Simulate", "OK"} default button 1
else
    display dialog "Pulling network data to local volume…" with title "Confirmation" buttons {"Abort", "Simulate", "OK"} default button 1
end if
if button returned of result is equal to "Abort" then
    error number -128
else if button returned of result is equal to "Simulate" then
    set dryRun to true
else
    set dryRun to false
end if
 
-- Attempt to mount the network volume
doNotify("Mounting volume " & quoted form of strVolume)
set lstDisks to list disks
if lstDisks does not contain strVolume then
    try
        mount volume "afp://" & strServer & "/" & strVolume as user name strUser
    on error
        doError("Failed to mount volume " & quoted form of strVolume & " on server " & quoted form of strServer & "…")
    end try
end if
 
-- Build source and destination paths
if doUp then
    set strSource to strLocal & "/" & strData
    set strDestination to strNetwork
else
    set strSource to strNetwork & "/" & strData
    set strDestination to strLocal
end if
 
-- Check our paths
if not checkPath(strLocal) then
    doError("Cannot find local path " & quoted form of strLocal & "…")
end if
if not checkPath(strNetwork) then
    doError("Cannot find network path " & quoted form of strNetwork & "…")
end if
if not checkPath(strSource) then
    doError("Cannot find source path " & quoted form of strSource & "…")
end if
 
-- Build the rsync command
if dryRun then -- Simulation only?
    set rsyncOpt to rsyncOpt & " --dry-run"
end if
set rsyncCmd to "rsync " & rsyncOpt & " " & quoted form of strSource & " " & quoted form of strDestination & " >> " & quoted form of rsyncOut & " 2>&1 & echo $!"
 
-- Write informatiom to log file
set fh to open for access rsyncOutApple with write permission
write "Source location: " & quoted form of strSource & return & "Destination location: " & quoted form of strDestination & return & "Command-line: " & rsyncCmd & return & return to fh
close access fh
 
-- Issue rsync command
set thePid to do shell script rsyncCmd
set isRunning to true
repeat until isRunning is false
    doNotify("Running rsync…")
    delay 5
    try
        do shell script "ps -p " & thePid
    on error
        set isRunning to false
    end try
end repeat
 
-- End notifications
undoNotify()
 
-- Inform of completion
if dryRun then
    display dialog "Successfully completed dry run…" with title "Success!" buttons {"View Details"} default button 1
else
    display dialog "Successfully completed sync job…" with title "Success!" buttons {"View Details", "OK"} default button 1
end if
if button returned of result is equal to "View Details" then
    set theView to do shell script "tail -14 " & quoted form of rsyncOut
    display dialog theView with title "View Details" buttons {"OK"} default button 1
end if
 
-- Delete the temporary file
tell application "Finder"
    if exists rsyncOutApple then
        delete rsyncOutApple
    end if
end tell
 
-- Functions
 
on undoNotify()
    do shell script notifyApp & " -remove " & quoted form of notifyGroup
end undoNotify
 
on doNotify(m)
    do shell script notifyApp & " -title " & quoted form of notifyTitle & " -group " & quoted form of notifyGroup & " -message " & quoted form of m
end doNotify
 
on doError(m)
    display dialog m with title "Error!" with icon stop buttons {"OK"} default button 1
    error number -128
end doError
 
on checkPath(p)
    set a to POSIX file p
    tell application "Finder"
        if exists a then
            return true
        else
            return false
        end if
    end tell
end checkPath
{% endhighlight %}

