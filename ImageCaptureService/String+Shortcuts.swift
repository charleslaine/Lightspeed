//
//  String+Shortcuts.swift
//  ImageCaptureService
//
//  Created by Charles Laine on 12/7/17.
//  Copyright © 2017 Charles Laine. All rights reserved.
//
// I found this nifty little extension here...
// https://stackoverflow.com/questions/412562/execute-a-terminal-command-from-a-cocoa-app

import Foundation

extension String {
    func runAsCommand() -> String {
        let pipe = Pipe()
        let task = Process()
        task.launchPath = "/bin/sh"
        task.arguments = ["-c", String(format:"%@", self)]
        task.standardOutput = pipe
        let file = pipe.fileHandleForReading
        task.launch()
        if let result = NSString(data: file.readDataToEndOfFile(), encoding: String.Encoding.utf8.rawValue) {
            return result as String
        }
        else {
            return "--- Error running command - Unable to initialize string from file data ---"
        }
    }
}


