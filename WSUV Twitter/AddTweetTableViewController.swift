//
//  AddTweetTableViewController.swift
//  WSUV Twitter
//
//  Created by Spencer Kitchen on 4/5/17.
//  Copyright © 2017 wsu.vancouver. All rights reserved.
//

import UIKit

class AddTweetTableViewController: UITableViewController, UITextFieldDelegate {
    
    
    
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var tweetCount: UILabel!
    
    
    

    //==== ADDED CODE =================================================
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion:nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tweetTextView.becomeFirstResponder()
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else { return true }
        let length = text.characters.count + string.characters.count - range.length
        
        // create an Integer of 55 - the length of your TextField.text to count down
        let count = 55 - length
        
        // set the .text property of your UILabel to the live created String
        tweetCount.text =  String(count)
        
        // if you want to limit to 55 charakters
        // you need to return true and <= 55
        
        return length <= 55 // To just allow up to 55 characters
    }
    
    
    

    
    
    
    //==== XCODE GENERATED CODE ========================================
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tweetCount.text = String(140)

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


















