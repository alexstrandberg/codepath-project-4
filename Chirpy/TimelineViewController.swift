//
//  HomeViewController.swift
//  Chirpy
//
//  Created by Alexander Strandberg on 6/27/16.
//  Copyright © 2016 Alexander Strandberg. All rights reserved.
//

import UIKit
import MBProgressHUD

class TimelineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    let CellIdentifier = "TimelineCell"
    let CellHeightEstimate: CGFloat = 87
    
    var tweets = [Tweet]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var isFirstLoad = true
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = CellHeightEstimate
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Initialize a UIRefreshControl
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        //tableView.insertSubview(networkErrorView, atIndex: 0)
        tableView.insertSubview(refreshControl, atIndex: 0)
        refreshControlAction(refreshControl)
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
        
        cell.tweetText.text = tweet.text
        
        if let timestamp = tweet.timestamp {
            cell.timestampLabel.text = Tweet.timeAgoSince(timestamp)
        }
            
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        if isFirstLoad {
            // Display HUD right before the request is made
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        }
        
        TwitterClient.sharedInstance.homeTimeline({ (tweets: [Tweet]) in
            self.tweets = []
            self.tweets.appendContentsOf(tweets)
            }, failure: { (error: NSError) in
                print(error.localizedDescription)
        })
        
        refreshControl.endRefreshing()
        if self.isFirstLoad {
            self.isFirstLoad = false
            // Hide HUD once the network request comes back (must be done on main UI thread)
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        }
    }
}