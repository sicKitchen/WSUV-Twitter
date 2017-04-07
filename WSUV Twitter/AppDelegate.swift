//
//  AppDelegate.swift
//  WSUV Twitter
//
//  Created by Spencer Kitchen on 4/5/17.
//  Copyright © 2017 wsu.vancouver. All rights reserved.
//

import UIKit

let kAddTweetNotification = Notification.Name("AddTweetNotification")

class Tweet: NSObject, NSCoding {
    var tweet_id : Int
    var username : String
    var isdeleted : Bool
    var tweet : NSString
    var Date : NSDate
    
    init(tweet_id : Int, username : String, isdeleted : Bool, tweet : NSString, Date : NSDate){
        self.tweet_id = tweet_id
        self.username = username
        self.isdeleted = isdeleted
        self.tweet = tweet
        self.Date = Date
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let tweet_id = aDecoder.decodeObject(forKey: "tweet_id") as! Int
        let username = aDecoder.decodeObject(forKey: "username") as! String
        //let isdeleted = aDecoder.decodeObject(forKey: "tweet_id") as! String
        let isdeleted = aDecoder.decodeBool(forKey: "isdeleted")
        let tweet = aDecoder.decodeObject(forKey: "tweet") as! NSString
        let Date = aDecoder.decodeObject(forKey: "Date") as! NSDate
        
        self.init(tweet_id:tweet_id, username:username, isdeleted:isdeleted, tweet:tweet, Date:Date)
            
    
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.tweet_id, forKey: "tweet_id")
        aCoder.encode(self.username, forKey: "username")
        aCoder.encode(self.isdeleted, forKey: "isdeleted")
        aCoder.encode(self.tweet, forKey: "tweet")
        aCoder.encode(self.Date, forKey: "Date")
        
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var tweets = [Tweet]()
    
    func lastTweetDate() -> Date{
        var dc = DateComponents()
        dc.year = 2013
        dc.month = 03
        dc.day = 14
        dc.timeZone = TimeZone(abbreviation: "PST")
        dc.hour = 14
        dc.minute = 15
        
        let cal = Calendar.current
        let date = cal.date(from: dc)
        
        return date!
    }
    
    


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

