//
//  ViewController.swift
//  KarthVaderExample
//
//  Created by Karthik Keyan on 11/12/15.
//  Copyright © 2015 Karthik Keyan. All rights reserved.
//

import UIKit
import Social
import Accounts
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView?
    
    lazy var store = ACAccountStore()
    
    var tweets = [Tweet]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Tweets (20)"
        
        // Do any additional setup after loading the view, typically from a nib.
        let type = store.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        store.requestAccessToAccountsWithType(type, options: nil) { [weak self] (grant: Bool, error: NSError!) -> Void in
            if grant {
                if let strongSelf = self {
                    strongSelf.fetchFeedsFromServer()
                }
            }
        }
        
        fetchLocalFeeds()
    }
    
    
    // MARK: - Private Methods
    
    private func fetchFeedsFromServer() {
        let type = store.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        let accounts = store.accountsWithAccountType(type)
        
        if let account = accounts.last as? ACAccount where accounts.count > 0 {
            let url = NSURL(string: "https://api.twitter.com/1.1/statuses/user_timeline.json")
            let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, URL: url, parameters: ["count" : "20"])
            request.account = account
            request.performRequestWithHandler({ [weak self] (data: NSData!, response: NSHTTPURLResponse!, error: NSError!) -> Void in
                if error == nil {
                    let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
                    self?.storeResponse(responseDictionary)
                }
            })
        }
    }
    
    private func storeResponse(response: AnyObject) {
        KarthVader.transaction { [weak self] (context) -> () in
            context.parse(response as! JSONArray, type: Tweet.self)
            context.commit() {
                self?.fetchLocalFeeds()
            }
        }
    }
    
    private func fetchLocalFeeds() {
        KarthVader.transactionMain { [weak self] (context) -> () in
            
            if let objects = context.fetch(Tweet.self) {
                self?.tweets = objects
            }
            
            self?.tableView?.reloadData()
        }
    }

}


// MARK: - UITableViewDataSource

private let tableViewCellIdentifier = "tableViewCellIdentifier"

extension ViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(tableViewCellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: tableViewCellIdentifier)
            cell?.textLabel?.numberOfLines = 0
            cell?.textLabel?.font = UIFont.systemFontOfSize(14.0)
            
            cell?.detailTextLabel?.font = UIFont.systemFontOfSize(12.0)
            cell?.detailTextLabel?.textColor = UIColor.grayColor()
        }
        
        cell?.textLabel?.text = ""
        cell?.detailTextLabel?.text = ""
        
        let tweet = tweets[indexPath.row]
        cell?.textLabel?.text = tweet.text
        
        if let userHandle = tweet.userHandle {
            cell?.detailTextLabel?.text = "@" + userHandle
        }
        
        return cell!
    }
    
}



// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let tweet = tweets[indexPath.row]
        
        let attributedString = NSAttributedString(string: tweet.text!, attributes: [ NSFontAttributeName : UIFont.systemFontOfSize(14.0) ])
        let rect = attributedString.boundingRectWithSize(CGSizeMake(UIScreen.mainScreen().bounds.size.width - 31, 999), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        
        return rect.size.height + 32
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}

