//
//  HomeViewController.swift
//  Chirpy
//
//  Created by Alexander Strandberg on 6/27/16.
//  Copyright © 2016 Alexander Strandberg. All rights reserved.
//

import UIKit
import MBProgressHUD
import TTTAttributedLabel

class TimelineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TTTAttributedLabelDelegate, ComposeViewControllerDelegate, UIScrollViewDelegate {
    @IBOutlet weak var profileView: UIView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var taglineLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var bannerImageView: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    
    let CellIdentifier = "TimelineCell"
    let CellHeightEstimate: CGFloat = 80
    
    var tweets = [Tweet]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if timelineType != "home" && timelineType != "mentions" {
            sizeHeaderToFit()
        }
    }
    
    func sizeHeaderToFit() {
        let headerView = profileView
        
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        
        let height = headerView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        var frame = headerView.frame
        frame.size.height = height
        headerView.frame = frame
        
        tableView.tableHeaderView = headerView
    }
    
    var isFirstLoad = true
    var isMoreDataLoading = false
    
    var loadingMoreView:InfiniteScrollActivityView?
    
    let refreshControl = UIRefreshControl()
    
    var timelineType = "home"
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = CellHeightEstimate
        tableView.rowHeight = UITableViewAutomaticDimension
        
        if timelineType == "mentions" {
            navigationItem.rightBarButtonItem = nil
        }
        
        if timelineType != "user" {
            profileView.removeFromSuperview()
            tableView.tableHeaderView = nil
        } else {
            navigationItem.leftBarButtonItem = nil
        }
        
        // Initialize a UIRefreshControl
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        //tableView.insertSubview(networkErrorView, atIndex: 0)
        tableView.insertSubview(refreshControl, atIndex: 0)
        refreshControlAction(refreshControl)
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
        if timelineType == "user" {
            navigationItem.title = "View Profile"
            if user == nil {
                user = User.currentUser
            }
        }
        
        if let user = user {
            nameLabel.text = user.name
            
            if user.screenname == User.currentUser?.screenname {
                navigationItem.title = "My Profile"
            }
            
            if let profileURLBigger = user.profileURLBigger {
                profileImageView.setImageWithURL(profileURLBigger)
            }
            
            if let screenname = user.screenname {
                screennameLabel.text = "@" + screenname
            }
            
            if let tagline = user.tagline {
                taglineLabel.text = tagline
            }
            
            followingCountLabel.text = "\(user.following)"
            followersCountLabel.text = "\(user.followers)"
            
            if user.followers != 1 {
                followersLabel.text = "Followers"
            } else {
                followersLabel.text = "Follower"
            }
            
            if let profileBannerURL = user.profileBannerURL {
                bannerImageView.setImageWithURL(profileBannerURL)
            }
        }
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
            let data = NSData(contentsOfURL: profileURL)
            if let data = data {
                cell.profileButton.setImage(UIImage(data: data), forState: .Normal)
            }
        }
        cell.profileButton.tag = indexPath.row
        
        if let screenname = tweet.user?.screenname {
            cell.screenNameLabel.text = "@" + screenname
        }
        
        cell.tweetText.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue
        cell.tweetText.delegate = self
        
        cell.tweetText.text = tweet.text
        
        if let text = tweet.text {
            let words = text.componentsSeparatedByString(" ")
            for word in words {
                if word.hasPrefix("@") {
                    let allowedCharacters = "@abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_1234567890"
                    var cleanedWord = ""
                    for letter in word.characters {
                        if allowedCharacters.containsString(String(letter)) {
                            cleanedWord += String(letter)
                        } else if String(letter) == "\'" {
                            break
                        }
                    }
                    
                    if let range = text.rangeOfString(cleanedWord) {
                        cell.tweetText.addLinkToURL(NSURL(string: cleanedWord), withRange: NSRange(location: text.characters.startIndex.distanceTo(range.startIndex), length: range.count))
                    }
                }
            }
        }
        
        if let timestamp = tweet.timestamp {
            cell.timestampLabel.text = Tweet.timeAgoSince(timestamp)
        }
        
        cell.profileButton.addTarget(self, action: #selector(showProfile(_:)), forControlEvents: .TouchUpInside)
            
        return cell
    }
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        if !url.absoluteString.hasPrefix("@") {
            UIApplication.sharedApplication().openURL(url)
        } else {
            
            TwitterClient.sharedInstance.userFromScreenname(url.absoluteString.substringFromIndex(url.absoluteString.startIndex.advancedBy(1)), success: { (user: User) in
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("TimelineViewController") as! TimelineViewController
                vc.timelineType = "user"
                vc.user = user
                self.navigationController?.pushViewController(vc, animated: true)
            }, failure: { (error: NSError) in
                print(error.localizedDescription)
            })
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        if isFirstLoad {
            // Display HUD right before the request is made
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        }
        
        loadMoreData()
    }
    
    func showProfile(sender: UIButton) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("TimelineViewController") as! TimelineViewController
        vc.timelineType = "user"
        vc.user = tweets[sender.tag].user
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func didPostTweet(tweet: Tweet) {
        tweets.insert(tweet, atIndex: 0)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                loadMoreData()
            }
        }
    }
    
    func loadMoreData() {
        var maxID = ""
        if tweets.count > 0 {
            maxID = tweets[tweets.count-1].idStr!
        }
        TwitterClient.sharedInstance.timeline(maxID, timelineType: timelineType, user: user, success: { (tweets: [Tweet], shouldClearArray: Bool) in
            if shouldClearArray {
                self.tweets = []
            }
            self.tweets.appendContentsOf(tweets)
            self.doneLoading()
        }, failure: { (error: NSError) in
            print(error.localizedDescription)
            self.doneLoading()
        })
    }
    
    func doneLoading() {
        refreshControl.endRefreshing()
        if isFirstLoad {
            isFirstLoad = false
            // Hide HUD once the network request comes back (must be done on main UI thread)
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        }
        
        // Update flag
        isMoreDataLoading = false
        
        // Stop the loading indicator
        loadingMoreView!.stopAnimating()
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
        } else if segue.identifier == "composeSegue" {
            let vc = segue.destinationViewController as! ComposeViewController
            vc.delegate = self
        }
    }
}