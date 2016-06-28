//
//  HomeViewController.swift
//  Chirpy
//
//  Created by Alexander Strandberg on 6/27/16.
//  Copyright © 2016 Alexander Strandberg. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    let CellIdentifier = "TimelineCell"
    
    var tweets = [Tweet]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 130
        tableView.rowHeight = UITableViewAutomaticDimension
        
        TwitterClient.sharedInstance.homeTimeline({ (tweets: [Tweet]) in
            self.tweets.appendContentsOf(tweets)
            }, failure: { (error: NSError) in
                print(error.localizedDescription)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogout(sender: AnyObject) {
        TwitterClient.sharedInstance.logout()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! TimelineCell
        
        let tweet = tweets[indexPath.row]
        cell.usernameLabel.text = tweet.user?.name
        
        if let profileURL = tweet.user?.profileURL {
            cell.profileImageView.setImageWithURL(profileURL)
        }
        
        if let screenname = tweet.user?.screenname {
            cell.screenNameLabel.text = "@" + screenname
        }
        
        cell.tweetTextLabel.text = tweet.text
        
        if let timestamp = tweet.timestamp {
            cell.timestampLabel.text = Tweet.timeAgoSince(timestamp)
        }
            
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}