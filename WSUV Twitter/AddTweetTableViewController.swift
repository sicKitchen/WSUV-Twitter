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
    

    //==== ADDED CODE =================================================
    // Cancel button
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion:nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tweetTextView.becomeFirstResponder()
    }
    
    @IBAction func done(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // Make sure user entered something
        if tweetTextView.text != "" {
            self.addTweet(username: appDelegate.USERNAME,
                          session_token: appDelegate.SESSIONTOKEN,
                          tweet: tweetTextView.text)
        }
        
    }
    
    // Add tweet Func
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
                    //print(response.request!)  // original URL request
                    //print(response.response!) // HTTP URL response
                    //print(response.data!)     // server data
                    //print(response.result)   // result of response serialization
                    
                    //if let JSON = response.result.value {
                    //    print("JSON: \(JSON)")
                    //}
                    
                    let dict = JSON as! [String : AnyObject]
                    let sessTok = dict["tweet"] as! String
                    //print (sessTok)
                    self.dismiss(animated: true, completion: {
                        NotificationCenter.default.post(name: kAddTweetNotification, object: nil)
                    })
                    break
                    
                case .failure(let error):
                    print ("error: register")
                    
                    print(response.request!)  // original URL request
                    print(response.response!) // HTTP URL response
                    print(response.data!)     // server data
                    print(response.result)   // result of response serialization
                    
                    if let JSON = response.result.value {
                        print("JSON: \(JSON)")
                    }
                    // inform user of error
                    break
                }
            })

    }
    
    // Responds to when tweetTextView changes, shows character count in UILable
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
    
    
        
    //==== XCODE GENERATED CODE ========================================
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tweetTextView.delegate = self
        
        // Set the start of tweet to 0 out of 140 characters
        tweetCount.text = "0/140"

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    */
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...
       
        return cell
    }
    */
    

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


















