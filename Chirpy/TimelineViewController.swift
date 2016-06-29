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
            let tempImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            tempImageView.setImageWithURLRequest(NSURLRequest(URL: profileURL), placeholderImage: nil, success: { (request: NSURLRequest, response: NSHTTPURLResponse?, image: UIImage) in
                cell.profileButton.setImage(image, forState: .Normal)
                cell.profileButton.selected = false
            }, failure: { (request: NSURLRequest, response:NSHTTPURLResponse?, error: NSError) in
                print(error.localizedDescription)
            })
        }
        cell.profileButton.tag = indexPath.row
        
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
    
    func showProfile(sender: UIButton) {
        performSegueWithIdentifier("profileSegue", sender: sender)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "detailSegue" {
            let vc = segue.destinationViewController as! DetailViewController
            let cell = sender as! TimelineCell
            let indexPath = tableView.indexPathForCell(cell)
            vc.tweet = tweets[indexPath!.row]
        } else if segue.identifier == "profileSegue" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let vc = navigationController.topViewController as! ProfileViewController
            let button = sender as! UIButton
            vc.user = tweets[button.tag].user
        }
    }
}