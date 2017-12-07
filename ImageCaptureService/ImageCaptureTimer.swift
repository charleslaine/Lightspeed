//
//  Timer.swift
//  ImageCaptureService
//
//  Created by Charles Laine on 12/6/17.
//  Copyright © 2017 Charles Laine. All rights reserved.
//

import Foundation
//******************************************************************************
// ImageCaptureTimer is a simple class containing an intance of NSTimer that
// performs a repeating task on a predefined interval.

// During each occurence of the timer's execution, this class will (or.. should)
// do the following...
// 1. grab a screenshot of the current user's desktop
// 2. post the screenshot to the AWS s3 API
//
// Each attempt will make two nested http requests.  The first one retrieves a pre-signed
// URL (identified as "s3_screens" per the instructions) as well as several
// additional parameters required by AWS s3.  The second http request will attempt to
// post the image using the values gathered in the first http request//
//******************************************************************************
class ImageCaptureTimer
{
    //MARK: Properties of ImageCaptureTimer
    var timer = Timer() //NSTimer
    var delayInterval: Int = 30 //this value is replaced in init by a value from the plist
    var maxTimerLimit: Int? //optional.  If nil, timer will run indefinitely
    var isTimerRunning: Bool = false
  
    var urlStr: String!
    var contentTypeStr: String!
    var cacheControlStr: String!
    var customerIdStr: String!
    var apiKeyStr: String!
    var postmanTokenStr: String!
    var uuidStr: String!
    //MARK: -
    init()
    {
        //read the required values from plist
        if let path = Bundle.main.path(forResource: "imageCaptureDefaults", ofType: "plist"){
            let plistDictionary: NSDictionary! = NSDictionary(contentsOfFile: path)

            self.urlStr          = plistDictionary.value(forKey: "url") as! String
            self.contentTypeStr  = plistDictionary.value(forKey: "contentType") as! String
            self.cacheControlStr = plistDictionary.value(forKey: "cacheControl") as! String
            self.customerIdStr   = plistDictionary.value(forKey: "customerId") as! String
            self.apiKeyStr       = plistDictionary.value(forKey: "apiKey") as! String
            self.postmanTokenStr = plistDictionary.value(forKey: "postmanToken") as! String
            self.delayInterval   = plistDictionary.value(forKey: "interval") as! Int
            
            //The test says...
            //Bonus: Retrieve a unique value for the logged in users identity and use in the API post body field for the “udid” key
            //Therefore...
            self.uuidStr = NSUUID.init().uuidString
            print("auto-generated uuidStr == \(uuidStr)")
            
            print("********************** values from plist **********************")
            print("cacheControl from plist = \(cacheControlStr)")
            print("contentType from plist = \(contentTypeStr)")
            print("customerId from plist = \(customerIdStr)")
            print("apiKey from plist = \(apiKeyStr)")
            print("url from plist = \(urlStr)")
            print("postmanToken from plist = \(postmanTokenStr)")
            print("***************************************************************\n")
        }
    }
    
    func getTimeStamp() -> String {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        let date = Date()
        let timeStamp = dateFormatter.string(from: date)
        //print ("timeStamp == \(dateString)")
        return timeStamp
    }

    @objc private func updateTimerWrapper() -> Void {
        updateTimer()
        doAPI()
    }

    func updateTimer(){
        print("in ImageCaptureTimer::updateTimer() with timestamp:  \(getTimeStamp())")
        //}
    }

    func doTimer() {
        //at least it doesn't leak!
        print("in ImageCaptureTimer::doTimer()")

        timer = Timer.scheduledTimer(timeInterval: TimeInterval(self.delayInterval as Int), target: self, selector: #selector(ImageCaptureTimer.updateTimerWrapper), userInfo: nil, repeats: true)
        isTimerRunning = true
    }

    func doAPI()
    {
        //FYI, generally speaking this entire closure should be refactored.  Just for the sake of time in the rush to get as much done as possble,
        //I simply nested the return blocks from the two http requests.  It's ugly but I didn't want to use up any time on this, given the amount of other
        //tasks remaining to be solved or investigated in this test.
        //For clarity and just to do it the "right way", it should be refactored and handled asynchronously via NotificationCenter.
        
        //set up new url request
        let request = NSMutableURLRequest(url: NSURL(string: "https://zzw3k2tgpf.execute-api.us-west-2.amazonaws.com/development/classroom/device_policy")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        
        //headers
        let headers: [String : String] = [
            "x-api-key": self.apiKeyStr,
            "customerId": self.customerIdStr,
            "Content-Type": self.contentTypeStr,
            "Cache-Control": self.cacheControlStr,
            "Postman-Token": self.postmanTokenStr
        ]
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        
        //body
        let parameters = ["udid": uuidStr] as [String : Any]
        var postData: (Data!)
        do {
            postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch{
            print("error initializing postData for request body")
        }
        request.httpBody = postData as Data
        print ("request.httpBody == \(String(describing: request.httpBody))")
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            let myData: Data! = data
            if (error != nil) {
                print(error as Any)
                return
            }
            var rootJSON: NSDictionary!
            var screenJSON: NSDictionary! //just trying to make things clear
            var tabsJSON: NSDictionary!
            //var err: NSError?
            do {
                rootJSON = try JSONSerialization.jsonObject(with: myData, options: .mutableLeaves) as? NSDictionary
            } catch{
                print("error parsing json after outer url request")
            }
            
            screenJSON = rootJSON.object(forKey: "s3_screen") as! NSDictionary
            print ("screenJSON == \(screenJSON)")
            
            tabsJSON = rootJSON.object(forKey: "s3_tabs") as! NSDictionary
            print ("tabsJSON == \(tabsJSON)")
            
            //according to instructions given, this is the "pre signed URL to the s3 bucket in which you can upload screenshots"
            let signedURLStr = screenJSON.object(forKey: "url") as! String
            print("***************************************************************")
            print ("signedURLStr = \(signedURLStr)")
            print("***************************************************************\n")

            //Get all of the values returned from the initial http request
            //These will be required for making the second http request (ie posting to the pre-signed url)
            screenJSON = screenJSON.object(forKey: "fields") as! NSDictionary
            let policyStr: String!          = screenJSON.value(forKey: "Policy") as! String
            let algorithmStr: String!       = screenJSON.value(forKey: "X-Amz-Algorithm") as! String
            let credentialStr: String!      = screenJSON.value(forKey: "X-Amz-Credential") as! String
            let accessKeyStr: String!       = "ASIAI7SNQSO2NJAQZGUA" //When I try to run this in a browser with a static form, it complains that I'm missing the AWSAccessKeyId field.  So, I'm adding it here.  Discuss!!!!
            let dateStr: String!            = screenJSON.value(forKey: "X-Amz-Date") as! String
            let securityTokenStr: String!   = screenJSON.value(forKey: "X-Amz-Security-Token") as! String
            let signatureStr: String!       = screenJSON.value(forKey: "X-Amz-Signature") as! String
            let bucketStr: String!          = screenJSON.value(forKey: "bucket") as! String
            let keyPrefixStr: String!       = screenJSON.value(forKey: "keyPrefix") as! String
            print("policyStr = \(policyStr)")
            print("algorithmStr = \(algorithmStr)")
            print("credentialStr = \(credentialStr)")
            print("accessKeyStr = \(accessKeyStr)")
            print("dateStr = \(dateStr)")
            print("securityTokenStr = \(securityTokenStr)")
            print("signatureStr = \(signatureStr)")
            print("bucketStr = \(bucketStr)")
            print("keyPrefixStr = \(keyPrefixStr)")
            
            let request2 = NSMutableURLRequest(url: NSURL(string: signedURLStr)! as URL,
                                               cachePolicy: .useProtocolCachePolicy,
                                               timeoutInterval: 10.0)
            
            //headers
            //per document http://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-HTTPPOSTForms.html
            //headers should be...
            // Content-Type: text/html; charset=UTF-8
            let headers2: [String : String] = [
                "Content-Type": "text/html",
                "charset": "UTF-8",
            ]
            
            request2.httpMethod = "POST"
            request2.allHTTPHeaderFields = headers2
            
            //Grab a current image of the user's desktop
            self.captureDesktopImage(folderName: "/tmp/") //don't forget the tailing slash! 
            
            //TODO: This image does not need to be written out to a file. Instead just retain the bitmap and pass it directly into the request.
            //I've been awake now for going on nearly 24 hours now and my brain is really starting to shut down.  Gotta call it where it is.
            
            //body
            //TODO: Blocked with a status 412 on the http request.
            //I'm unclear how to go about formatting the body of this request.
            //I am using all of the paramaters returned from the initial request and trying to build up the full pre-signed url.
            //But something is missing or just wrong.  I'm getting a 412 error and have been unable to resolve it in the one day-ish amount of time
            //I've spent on this test. I spent the majority of the time working on this test just trying to figure out this API call. I'd really like to know
            //what's wrong with it and what needs to be changed.  I think I have the general idea, but there's just something not right with the format.
            
            let parameters2 = [
                "Policy": policyStr,
                "X-Amz-Algorithm": algorithmStr,
                "X-Amz-Credential": credentialStr,
                "AWSAccessKeyId": accessKeyStr,
                "X-Amz-Date": dateStr,
                "X-Amz-Security-Token": securityTokenStr,
                "X-Amz-Signature": signatureStr,
                "bucket": bucketStr,
                "keyPrefix": keyPrefixStr,
                "file": "foo" //screenshot goes here.  but according to api docs, anything should work.  hence, foo for now, until I get past the 412 problem
                ] as [String : Any]
            var postData2: (Data!)
            do {
                postData2 = try JSONSerialization.data(withJSONObject: parameters2, options: [])
            } catch{
                print("error initializing postData2")
            }
            
            request2.httpBody = postData2 as Data
            
            let session = URLSession.shared
            let dataTask2 = session.dataTask(with: request2 as URLRequest, completionHandler: { (data, response, error) -> Void in
                let myData2: Data! = data
                let myResponse2: URLResponse! = response
                
                if (error != nil) {
                    print("Error in inner completionHandler. error == \(error.debugDescription)")
                    return
                }
                print("\n\n")
                print("myResponse2 == \(myResponse2)")
                print("\n\n")
                
                var myJSON: NSDictionary!
                do {
                    myJSON = try JSONSerialization.jsonObject(with: myData2, options: .mutableLeaves) as? NSDictionary
                    print("inner myJSON == \(myJSON)")
                } catch{
                    //note: this is a known (observed) problem.  This will occur due to the http code 412 that I'm getting back from the second http request
                    print(error)
                }
                
            })//end of inner completion handler for session.dataTask(
            dataTask2.resume()
            print ("after dataTask2.resume")
            
        })//end of outer completion handler for session.dataTask(
        
        dataTask.resume()
        print ("after dataTask.resume")
        
    }
    func captureSafariState(){
        //TODO: Implement the Safari stuff
        //Several ways to go about this.  Use the scripting bridge and include a simple AppleSript in the bundle that iterates over the window and gets all the tabs.
        //OR, more cumbersomely, use the Accessibility API.  The problem with Accessibility these days is Apple's restrictive permissions.  It has to be
        //explictely enabled per app by the user and there is no longer any sort of silent workaround to this like there used to be back in the old timey days.
 
        //Regarding the detection of application launch...
        //I've written a previous application that detected when a browser was launched, terminated, etc.
        //This is achieved by using NSWorkspace, as shown in this example
        
//        NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
//
//        //Register the observer for application activation notifications    (NOTE: these appear BEFORE a launch notification)
//        [[workspace notificationCenter] addObserver:self
//            selector:@selector(applicationActivated:)
//            name:NSWorkspaceDidActivateApplicationNotification
//            object:workspace];

        //In the implementaion of applicationLaunched:(NSNotification *)notification, you can get then extract the bundle identifier from the
        //notification object to see if it is Safari or not (com.apple.Safari)

    
    }

    func captureDesktopImage(folderName: String){
        
        //verified to be functioning properly.  During testing, created screenshots in the /tmp directory.
        
        print("in captureDesktopImage with folderName == \(folderName)")
        var displayCount: UInt32 = 0;
        var result = CGGetActiveDisplayList(0, nil, &displayCount)
        if (result != CGError.success) {
            print("error: \(result)")
            return
        }
        let allocated = Int(displayCount)
        let activeDisplays = UnsafeMutablePointer<CGDirectDisplayID>.allocate(capacity: allocated)
        result = CGGetActiveDisplayList(displayCount, activeDisplays, &displayCount)
        
        if (result != CGError.success) {
            print("error: \(result)")
            return
        }
        
        for i in 1...displayCount {
            let unixTimestamp = getTimeStamp()
            let fileUrl = URL(fileURLWithPath: folderName + "\(unixTimestamp)" + "_" + "\(i)" + ".jpg", isDirectory: true)
            let screenShot:CGImage = CGDisplayCreateImage(activeDisplays[Int(i-1)])!
            let bitmapRep = NSBitmapImageRep(cgImage: screenShot)
            let jpegData = bitmapRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])!
            
            do {
                try jpegData.write(to: fileUrl, options: .atomic)
            }
            catch {print("error: \(error)")}
        }
    }
    func deleteDesktopImage(){
        //TODO: Remove this unnecessary function. Instead of writing and deleting the a file, pass the bitmap straight into the request
        //But oh the humanity, I'm out of time!
        //And, for testing purposes, creating an actual file had its merits.  I did confirm that the app was indeed capturing
        //actual desktop images on a 30 second interval per the specifications of this test.
    }

    
}
