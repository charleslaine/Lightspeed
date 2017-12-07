//
//  AppDelegate.swift
//  ImageCaptureService
//
//  Created by Charles Laine on 12/6/17.
//  Copyright © 2017 Charles Laine. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    var imageCaptureTimer: ImageCaptureTimer!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        //TODO: Open a radar ticket to Apple telling them to fix this curious "Month 13 is out of bounds" glitch in macOS 10.13.1
        
        print("ImageCaptureService::AppDelegate - applicationDidFinishLaunching")
        
        let defaults:UserDefaults = UserDefaults.standard
        if (!defaults.bool(forKey:"LaunchAsAgentApp")) {
            NSApp.setActivationPolicy(NSApplication.ActivationPolicy.accessory)  //turn us into background process along with LSUIElement==true in Info.plist
        }
       
        enableScreenSharing()
        
        let imageCaptureTimer = ImageCaptureTimer()
        imageCaptureTimer.doAPI() //do the first one immediately
        imageCaptureTimer.doTimer() //then let the timer handle the rest
    }
   
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

 
    func enableScreenSharing(){
       
        //I am running out of time.  Up all night, and going on nearly 20 hours straight of working on this little homework assignment.
        //I Spent waaaaaay too much time on trying to figure out the problem with my second http request to the AWS s3 api and now I'm mentally fogged over.
        //
        //NOTE: I've included some FOSS from github called STPrivilegedTask.  It's in objective-c.  I've added the necessary
        //bridging header to the project so that its invokable from swift.
        //
        //The commands for enabling screen sharing are located within a shell script inside the application bundle.
        //See enableScreenSharing.sh.  This script works when run from the command line.  It turns on Screen Sharing and
        //leaves everything else as-is.  When I run this script using STPRivilegedTask, I actually get an auth prompt.
        //So it looks like it ought to work.  But... nay.  The setting is not being toggled on the Sharing panel.  I think
        //this is VERY close to working.  I just needed a little more time to debug and work with this 3rd party source.
        //But I really am out of time.
        //
        //The really strange thing is, the console output is telling me...
        //
        // /System/Library/LaunchDaemons/com.apple.screensharing.plist: service already loaded
        //
        //This means that the script is actually running and doing its thing.  But the Sharing settings UI is just not showing any change.  Strange indeed!
    
        //Here's the obj-c command in objc per the author's own documentation at https://github.com/sveinbjornt/STPrivilegedTask...
        //OSStatus err = [STPrivilegedTask launchedPrivilegedTaskWithLaunchPath:@"/bin/sh" arguments:@[@"/path/to/script.sh"]];
        
        let scriptPath = Bundle.main.path(forResource: "enableScreenSharing", ofType: "sh")
        print("\nscriptPath = \(scriptPath.debugDescription)\n")
        
        STPrivilegedTask.launchedPrivilegedTask(withLaunchPath:"/bin/sh", arguments:[scriptPath!])
        return
    }
}


