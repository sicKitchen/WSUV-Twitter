//
//  TwitterTableViewController.swift
//  WSUV Twitter
//
//  Created by Spencer Kitchen on 4/6/17.
//  Copyright © 2017 wsu.vancouver. All rights reserved.
//
/*  Handles main view of twitter app. Can register a new user and log in from top left corner.
    Once logged in, You can post a new tweet from the add button in the top right corner.
    To refresh the tweet feed swipe down on the chat.
*/


import UIKit
import Alamofire

let DEBUG = true

class TwitterTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: kAddTweetNotification,object: nil, queue: nil) { (note : Notification) -> Void in
            if !self.refreshControl!.isRefreshing {
                self.refreshControl!.beginRefreshing()
                self.refreshTweets(self)
            }
        }
        // Calls first refresh for us
        self.refreshTweets(self)
    
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //===============================
    // LogIn/Logout Button (Top left)
    //===============================
    @IBAction func logIn(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // Logout Button---------
        let alertController : UIAlertController
        if appDelegate.LOGIN {
            alertController = UIAlertController(title: "Logout", message: "Please Log out", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Logout", style: .default, handler: { _ in
                
                let SSpass = appDelegate.getSSKeychain(account: appDelegate.USERNAME,
                                          forService: appDelegate.kWazzuTwitterPassword)
                
                self.logoutUser(username: appDelegate.USERNAME, password: SSpass.password!)
                //self.logoutUser(username: appDelegate.USERNAME, password: appDelegate.PASSWORD)
            }))
        } else {
            
            // Login Button---------
            alertController = UIAlertController(title: "Login", message: "Please Log in", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Login", style: .default, handler: { _ in
                let usernameTextField = alertController.textFields![0]
                let passwordTextField = alertController.textFields![1]
                if usernameTextField.text != "" || passwordTextField.text != "" {
                    self.loginUser(username: usernameTextField.text!, password: passwordTextField.text!)
                }else {
                    let alert = UIAlertController(title: "Missing Text Fields",
                                                  message: "Please provide username/password and select Register to sign up",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }))
        }
        // Cancel Button
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // TextFields (username, password)
        if !appDelegate.LOGIN {
            alertController.addTextField { (textField : UITextField) -> Void in
                textField.placeholder = "Username"
            }
            alertController.addTextField { (textField : UITextField) -> Void in
                textField.isSecureTextEntry = true
                textField.placeholder = "Password"
            }
            
            // Register Button
            alertController.addAction(UIAlertAction(title: "Register", style: .default, handler: { _ in
                let usernameTextField = alertController.textFields![0]
                let passwordTextField = alertController.textFields![1]
                if usernameTextField.text != "" || passwordTextField.text != "" {
                    self.registerUser(username: usernameTextField.text!, password: passwordTextField.text!)
                }else {
                    let alert = UIAlertController(title: "Missing Text Fields",
                                                  message: "Please provide username/password to sign up",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.refreshControl?.endRefreshing()
                }
            }))
        }
        self.present(alertController, animated: true, completion: nil)
    }
    //=======================
    // Register New User Func
    //=======================
    func registerUser (username: String, password : String) {
        let kBaseURLString = "https://ezekiel.encs.vancouver.wsu.edu/~cs458/cgi-bin"
        let urlString = kBaseURLString + "/register.cgi"
        let parameters = [
            "username" : username,  // username and password
            "password" : password,  // obtained from user
        ]
        Alamofire.request(urlString, method: .post, parameters: parameters)
            .responseJSON(completionHandler: {
                response in
                switch(response.result) {
                case .success(let JSON):
                
                    let dict = JSON as! [String : AnyObject]
                    let sessTok = dict["session_token"] as! String
                    
                    if DEBUG {
                        print("SUCCESS: session token - \(sessTok)")
                    }
                    
                    break
                    
                case .failure(let error):
                    // Log to console
                    let statusCode = response.response!.statusCode
                    print("ERROR: \(statusCode)")
                    print (error)
                    print ()
                    
                    // inform user of error
                    switch (statusCode) {
                    case 500:
                        let alert = UIAlertController(title: "Internal Server Error",
                                                      message: "Please try again later",
                                                      preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        break
                        
                    case 400:
                        let alert = UIAlertController(title: "Missing Text Fields",
                                                      message: "Please provide username/password to sign up",
                                                      preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        break
                        
                    case 409:
                        let alert = UIAlertController(title: "Username Already Exists",
                                                      message: "Please try a new username/password",
                                                      preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        break
                        
                    default:
                        
                        break
                    }
                    self.refreshControl?.endRefreshing()
                    break
                }
            })
    }
    
    //================
    // User LogIn Func
    //================
    func loginUser(username: String, password : String) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let kBaseURLString = "https://ezekiel.encs.vancouver.wsu.edu/~cs458/cgi-bin"
        let urlString = kBaseURLString + "/login.cgi"
        let parameters = [
            "username" : username,  // username and password
            "password" : password,  // obtained from user
            "action" : "login"
        ]
        Alamofire.request(urlString, method: .post, parameters: parameters)
            .responseJSON(completionHandler: {
                response in
                switch(response.result) {
                    case .success(let JSON):
                        
                        let dict = JSON as! [String : AnyObject]
                        let sessTok = dict["session_token"] as! String
                        
                        // save username
                        appDelegate.USERNAME = parameters["username"]!
                        
                        // --save password to keychain
                        appDelegate.setSSKeychain(password: parameters["password"]!,
                                      forService: appDelegate.kWazzuTwitterPassword,
                                      account: parameters["username"]!)
                        
                        // --save Session token to keychain
                        
                        appDelegate.setSSKeychain(password: sessTok,
                                           forService: appDelegate.kWazzuTwitterToken,
                                           account: parameters["username"]!)
                        
                        // enable "add tweet" button
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                        
                        // change title of controller to show username, etc...
                        self.title = appDelegate.USERNAME
                        appDelegate.LOGIN = true
                        break
                    
                    case .failure(let error):
                        // Log to console
                        let statusCode = response.response!.statusCode
                        print("ERROR: \(statusCode)")
                        print (error)
                        print ()
                        
                        // inform user of error
                        switch (statusCode) {
                        case 500:
                            let alert = UIAlertController(title: "Internal Server Error",
                                                          message: "Please try again later",
                                                          preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            break
                            
                        case 400:
                            let alert = UIAlertController(title: "Missing Text Fields",
                                                          message: "Please provide username/password to sign up",
                                                          preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            break
                            
                        case 401:
                            let alert = UIAlertController(title: "Wrong Password",
                                                          message: "Please re-enter password",
                                                          preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            break
                            
                        case 404:
                            let alert = UIAlertController(title: "Wrong Username",
                                                          message: "Please re-enter username",
                                                          preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            break
                            
                        default:
                            
                            break
                        }
                        self.refreshControl?.endRefreshing()
                        break
                }
        })
    }
    
    //=================
    // User LogOut Func
    //=================
    func logoutUser (username: String, password : String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let kBaseURLString = "https://ezekiel.encs.vancouver.wsu.edu/~cs458/cgi-bin"
        let urlString = kBaseURLString + "/login.cgi"
        let parameters = [
            "username" : username,  // username and password
            "password" : password,  // obtained from user
            "action" : "logout"
        ]
        Alamofire.request(urlString, method: .post, parameters: parameters)
            .responseJSON(completionHandler: {
                response in
                switch(response.result) {
                case .success(let JSON):
                    
                    let dict = JSON as! [String : AnyObject]
                    let sessTok = dict["session_token"] as! String
                    
                    if DEBUG {
                        print("SUCCESS session token - \(sessTok)")
                    }
                    
                    // reset username
                    let SSKpasswrd = appDelegate.getSSKeychain(account: appDelegate.USERNAME,
                                                forService: appDelegate.kWazzuTwitterPassword)
                    SSKpasswrd.password = ""
                    try! SSKpasswrd.save()
                    
                    let SSKtoken = appDelegate.getSSKeychain(account: appDelegate.USERNAME,
                                                        forService: appDelegate.kWazzuTwitterToken)
                    SSKtoken.password = ""
                    try! SSKtoken.save()
                    
                    appDelegate.USERNAME = ""
                    
                    // disable "add tweet" button
                    self.navigationItem.rightBarButtonItem?.isEnabled = false
                    
                    // change title of controller to show Guest, etc...
                    self.title = "Guest"
                    appDelegate.LOGIN = false
                    break
                case .failure(let error):
                    // Log to console
                    let statusCode = response.response!.statusCode
                    print("ERROR: \(statusCode)")
                    print (error)
                    print ()
                    
                    break
                }
            })
    }
    
    //==================================
    // Regfresh Tweets func (swipe down)
    //==================================
    @IBAction func refreshTweets(_ sender: AnyObject) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if DEBUG {
            print ("refreshing tweets")
        }
        
        let kBaseURLString = "https://ezekiel.encs.vancouver.wsu.edu/~cs458/cgi-bin"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "PST")
        let lastTweetDate = appDelegate.lastTweetDate()
        let dateStr = dateFormatter.string(from: lastTweetDate as Date)
        
        // format date string from latest stored tweet...
        Alamofire.request(kBaseURLString + "/get-tweets.cgi", method: .get, parameters: ["date" : dateStr])
            .responseJSON {response in
                switch(response.result) {
                case .success(let JSON):
                    
                    let dict = JSON as! [String : AnyObject]
                    // tweets now holds all the tweats from server
                    let tweets = dict["tweets"] as! [[String : AnyObject]]
                    // ... create a new Tweet object for each returned tweet dictionary
                    var tweetDict = [Tweet]()
                    for tweet in tweets {
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        dateFormatter.timeZone = NSTimeZone(abbreviation: "PST")! as TimeZone
                        let date = dateFormatter.date(from:tweet["time_stamp"] as! String)
                        
                        let tmpTweet = Tweet(tweet_id: tweet["tweet_id"] as! Int,
                                             username: tweet["username"] as! String,
                                             isdeleted: tweet["isdeleted"] as! Int,
                                             tweet: tweet["tweet"] as! NSString,
                                             Date: date! as NSDate)
                        
                        tweetDict.append(tmpTweet)
                    }
                    
                    // ... add new (sorted) tweets to appDelegate.tweets...
                    tweetDict.reverse()
                    appDelegate.tweets.removeAll()
                    for tweet in tweetDict {
                        
                        if tweet.isdeleted == 0{
                            appDelegate.tweets.append(tweet)
                        }
                        
                    }
                    
                    self.tableView.reloadData() // force table-view to be updated
                    self.refreshControl?.endRefreshing()
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
                }
        }

    }
    
    //================
    // TableView Setup
    //================
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.tweets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // Configure the cell...
        var tweets = appDelegate.tweets
        let tweet = tweets[indexPath.row]
        
        cell.textLabel?.numberOfLines = 0 // multiline label
        cell.textLabel?.attributedText = attributedStringForTweet(tweet)
        
        return cell
    }
    
    //==========================
    // Pretty Print to TableView
    //==========================
    lazy var tweetDateFormatter : DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    let tweetTitleAttributes = [
        NSFontAttributeName : UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline),
        NSForegroundColorAttributeName : UIColor.purple
    ]
    
    lazy var tweetBodyAttributes : [String : AnyObject] = {
        let textStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        textStyle.lineBreakMode = .byWordWrapping
        textStyle.alignment = .left
        let bodyAttributes = [
            NSFontAttributeName : UIFont.preferredFont(forTextStyle: UIFontTextStyle.body),
            NSForegroundColorAttributeName : UIColor.black,
            NSParagraphStyleAttributeName : textStyle
        ]
        return bodyAttributes
    }()
    
    var tweetAttributedStringMap : [Tweet : NSAttributedString] = [:]
    
    func attributedStringForTweet(_ tweet : Tweet) -> NSAttributedString {
        let attributedString = tweetAttributedStringMap[tweet]
        if let string = attributedString { // already stored?
            return string
        }
        let dateString = tweetDateFormatter.string(from: tweet.Date as Date)
        let title = String(format: "%@ - %@\n", tweet.username, dateString)
        let tweetAttributedString = NSMutableAttributedString(string: title, attributes: tweetTitleAttributes)
        let bodyAttributedString = NSAttributedString(string: tweet.tweet as String, attributes: tweetBodyAttributes)
        tweetAttributedString.append(bodyAttributedString)
        tweetAttributedStringMap[tweet] = tweetAttributedString
        return tweetAttributedString
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView,
                            estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    //======================
    // Delete from tableView
    //======================
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            // Tweet came from me
            if appDelegate.tweets[indexPath.row].username == appDelegate.USERNAME {
                
                
                let SessionToken = appDelegate.getSSKeychain(account: appDelegate.USERNAME,
                              forService: appDelegate.kWazzuTwitterToken)
                
                
                self.deleteTweet(username: appDelegate.USERNAME,
                                 //session_token: appDelegate.SESSIONTOKEN,
                                 session_token: SessionToken.password!,
                                 tweet_id: appDelegate.tweets[indexPath.row].tweet_id)
                
                appDelegate.tweets.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                self.tableView.isEditing = false

            } else {
                self.tableView.isEditing = false
                let alert = UIAlertController(title: "Restricted",
                                              message: "Must be Registered User to delete tweets",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }

        }
        
        //else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        //}
    }
    
    //==================
    // Delete Tweet Func
    //==================
    func deleteTweet(username: String, session_token: String, tweet_id: Int) {
        let kBaseURLString = "https://ezekiel.encs.vancouver.wsu.edu/~cs458/cgi-bin"
        let urlString = kBaseURLString + "/del-tweet.cgi"
        let parameters = [
            "username" : username,
            "session_token" : session_token,
            "tweet_id" : tweet_id
        ] as [String : Any]
        Alamofire.request(urlString, method: .post, parameters: parameters)
            .responseJSON(completionHandler: {
                response in
                switch(response.result) {
                case .success(let JSON):
                    
                    let dict = JSON as! [String : AnyObject]
                    
                    if DEBUG {
                        print("Success Delete")
                        print (dict)
                    }
                    break
                    
                case .failure(let error):
                    let message : String
                    if let httpStatusCode = response.response?.statusCode {
                        switch(httpStatusCode) {
                        case 500:
                            message = "Server error (my bad)"
                            print(message)
                            break
                            
                        case 400:
                            message = "all parameters not provided"
                            print(message)
                            break
                            
                        case 401:
                            message = "Unauthorized"
                            print(message)
                            break
                            
                        case 403:
                            message = "not the user’s tweet"
                            print(message)
                            break
                            
                        case 404:
                            message = "no such user or no such tweet"
                            print(message)
                            break
                            
                        default: break
                            
                        }
                    } else { // probably network or server timeout
                        message = error.localizedDescription
                        print(message)
                    }
                    
                    // ... display alert with message ..
                    let alert = UIAlertController(title: "Could not delete tweet",
                                                  message: "Check if you are tweet's owner",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.refreshControl?.endRefreshing()

                    break
                }
                
            })

    }
    
    
    
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
