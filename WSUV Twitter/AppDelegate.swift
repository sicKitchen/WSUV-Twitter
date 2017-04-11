//
//  AppDelegate.swift
//  WSUV Twitter
//
//  Created by Spencer Kitchen on 4/5/17.
//  Copyright © 2017 wsu.vancouver. All rights reserved.
//

import UIKit

// Watches for calls to refresh table
let kAddTweetNotification = Notification.Name("AddTweetNotification")

class Tweet: NSObject, NSCoding {
    var tweet_id : Int
    var username : String
    var isdeleted : Int
    var tweet : NSString
    var Date : NSDate
    
    init(tweet_id : Int, username : String, isdeleted : Int, tweet : NSString, Date : NSDate){
        self.tweet_id = tweet_id
        self.username = username
        self.isdeleted = isdeleted
        self.tweet = tweet
        self.Date = Date
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let tweet_id = aDecoder.decodeObject(forKey: "tweet_id") as! Int
        let username = aDecoder.decodeObject(forKey: "username") as! String
        let isdeleted = aDecoder.decodeObject(forKey: "isdeleted") as! Int
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
    var USERNAME : String = ""
    var LOGIN : Bool = false
    let kWazzuTwitterPassword = "WazzuTwitterPassword"  // KeyChain service
    let kWazzuTwitterToken = "WazzuTwitterToken"
    
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

    //======================
    // Set a secure keychain
    //======================
    func setSSKeychain(password: String, forService: String, account: String) {
        // --save password to keychain
        let SSK = SAMKeychainQuery()   // New item
        SSK.password = password
        SSK.service = forService
        SSK.account = account
        try! SSK.save()
    }
    
    //====================================
    // Get a secure Keychain back 
    // - look up is by account and service
    //====================================
    func getSSKeychain(account: String, forService: String) -> SAMKeychainQuery {
        // --look up a keychain
        let SSK = SAMKeychainQuery()
        SSK.service = forService
        SSK.account = account
        try! SSK.fetch()
        return SSK
    }
    
}

