//
//  TwitterTableViewController.swift
//  WSUV Twitter
//
//  Created by Spencer Kitchen on 4/6/17.
//  Copyright © 2017 wsu.vancouver. All rights reserved.
//

import UIKit
import Alamofire

class TwitterTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: kAddTweetNotification,object: nil, queue: nil) { (note : Notification) -> Void in
            if !self.refreshControl!.isRefreshing {
                self.refreshControl!.beginRefreshing()
                self.refreshTweets(self)
            }
        }
        
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
    
    
    
    @IBAction func logIn(_ sender: Any) {
        let alertController = UIAlertController(title: "Login", message: "Please Log in", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Login", style: .default, handler: { _ in
            let usernameTextField = alertController.textFields![0]
            let passwordTextField = alertController.textFields![1]
            // ... check for empty textfields
            //self.loginUser(usernameTextField.text!, password: passwordTextField.text!)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addTextField { (textField : UITextField) -> Void in
            textField.placeholder = "Username"
        }
        alertController.addTextField { (textField : UITextField) -> Void in
            textField.isSecureTextEntry = true
            textField.placeholder = "Password"
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    
       
    @IBAction func refreshTweets(_ sender: AnyObject) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        print ("refreshing tweets")
        let kBaseURLString = "https://ezekiel.encs.vancouver.wsu.edu/~cs458/cgi-bin"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "PST")
        let lastTweetDate = appDelegate.lastTweetDate()
        let dateStr = dateFormatter.string(from: lastTweetDate as Date)
        
        
        print ("making alamofire request")
        // format date string from latest stored tweet...
        Alamofire.request(kBaseURLString + "/get-tweets.cgi", method: .get, parameters: ["date" : dateStr])
            .responseJSON {response in
                switch(response.result) {
                case .success(let JSON):
                    print("succes with AF")
                    
                    //print(response.request!)  // original URL request
                    //print(response.response!) // HTTP URL response
                    //print(response.data!)     // server data
                    //print(response.result)   // result of response serialization
                    
                    //if let JSON = response.result.value {
                    //    print("JSON: \(JSON)")
                    //}

                    
                    
                    
                    
                    
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
                                             isdeleted: (tweet["isdeleted"] != nil),
                                             tweet: tweet["tweet"] as! NSString,
                                             Date: date! as NSDate)
                        
                        tweetDict.append(tmpTweet)
                    }
                    
                    // ... add new (sorted) tweets to appDelegate.tweets...
                    
                    for tweet in tweetDict {
                        //print(tweet.tweet_id)
                        //print(tweet.username)
                        //print(tweet.isdeleted)
                        //print(tweet.tweet)
                        //print(tweet.Date)
                        //print("")
                        
                        appDelegate.tweets.append(tweet)
                    }
                    
                    self.tableView.reloadData() // force table-view to be updated
                    self.refreshControl?.endRefreshing()
                case .failure(let error):
                    print ("fail with AF")
                    let message : String
                    if let httpStatusCode = response.response?.statusCode {
                        switch(httpStatusCode) {
                        case 500:
                            message = "Server error (my bad)"
                            // ...
                        default:
                            print("404/500/etc")
                        }
                    } else { // probably network or server timeout
                        message = error.localizedDescription
                    }
                    // ... display alert with message ..
                    self.refreshControl?.endRefreshing()
                }
        }

    }
    
    
    
    

    // MARK: - Table view data source

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
        //let tweet = appDelegate.tweets[indexPath.row]
        
        var tweets = appDelegate.tweets
        tweets.reverse()
        
        let tweet = tweets[indexPath.row]
        
        cell.textLabel?.numberOfLines = 0 // multiline label
        cell.textLabel?.attributedText = attributedStringForTweet(tweet)
        
        
        return cell
    }
    
    
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
