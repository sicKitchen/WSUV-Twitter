//
//  AddTweetTableViewController.swift
//  WSUV Twitter
//
//  Created by Spencer Kitchen on 4/5/17.
//  Copyright © 2017 wsu.vancouver. All rights reserved.
//

import UIKit
import Alamofire

class AddTweetTableViewController: UITableViewController, UITextViewDelegate {
    
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var tweetCount: UILabel!
    
    //==============
    // Cancel button
    //==============
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion:nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tweetTextView.becomeFirstResponder()
    }
    
    //============
    // Done button
    //============
    @IBAction func done(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // Make sure user entered something
        if tweetTextView.text != "" {
            
            let sessionToken = appDelegate.getSSKeychain(account: appDelegate.USERNAME,
                                      forService: appDelegate.kWazzuTwitterToken)
            
            self.addTweet(username: appDelegate.USERNAME,
                          //session_token: appDelegate.SESSIONTOKEN,
                          session_token: sessionToken.password!,
                          tweet: tweetTextView.text)
        }
    }
    
    //===============
    // Add tweet Func
    //===============
    func addTweet(username: String, session_token: String, tweet: String){
        let kBaseURLString = "https://ezekiel.encs.vancouver.wsu.edu/~cs458/cgi-bin"
        let urlString = kBaseURLString + "/add-tweet.cgi"
        let parameters = [
            "username" : username,
            "session_token" : session_token,
            "tweet" : tweet
        ]
        Alamofire.request(urlString, method: .post, parameters: parameters)
            .responseJSON(completionHandler: {
                response in
                switch(response.result) {
                case .success(let JSON):
                    
                    let dict = JSON as! [String : AnyObject]
                    let sessTok = dict["tweet"] as! String
                    
                    if DEBUG {
                        print ("SUCCESS: tweet content - \(sessTok)")
                    }
                    
                    self.dismiss(animated: true, completion: {
                        NotificationCenter.default.post(name: kAddTweetNotification, object: nil)
                    })
                    break
                    
                case .failure(let error):
                    let message : String
                    if let httpStatusCode = response.response?.statusCode {
                        switch(httpStatusCode) {
                        case 500:
                            message = "Server error (my bad)"
                            print(message)
                            break
                            
                        case 503:
                            message = "Unable to connect to internal database"
                            print(message)
                            break
                            
                        default: break
                            
                        }
                    } else { // probably network or server timeout
                        message = error.localizedDescription
                        print(message)
                    }
                    
                    // ... display alert with message ..
                    let alert = UIAlertController(title: "Could not connect to Database",
                                                  message: "Please try again later",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.refreshControl?.endRefreshing()
                    
                    break
                }
            })

    }
    
    //=======================================
    // Responds to when tweetTextView changes
    // Shows character count in UILabel
    //=======================================
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let MAX = 140
        let length = textView.text.characters.count + text.characters.count - range.length
        if length > MAX {
            print ("max input")
            return false
        }
        else {
            tweetCount.text = String(length) + "/140"
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tweetTextView.delegate = self
        
        // Set the start of tweet to 0 out of 140 characters
        tweetCount.text = "0/140"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


















