//
//  DetailViewController.swift
//  Chirpy
//
//  Created by Alexander Strandberg on 6/28/16.
//  Copyright © 2016 Alexander Strandberg. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class DetailViewController: UIViewController, TTTAttributedLabelDelegate {
    
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var tweetText: TTTAttributedLabel!
    @IBOutlet weak var retweetLabel: UILabel!
    @IBOutlet weak var favoriteLabel: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var tweet: Tweet?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationItem.title = "View Tweet"
        navigationItem.backBarButtonItem?.title = "Back"
        
        replyButton.setImage(UIImage(named: "replyPressed"), forState: .Highlighted)
        
        retweetButton.setImage(UIImage(named: "retweetOnHover"), forState: .Selected)
        
        favoriteButton.setImage(UIImage(named: "likeOnHover"), forState: .Selected)
        
        profileButton.addTarget(self, action: #selector(showProfile(_:)), forControlEvents: .TouchUpInside)
        
        updateView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateView() {
        if let tweet = tweet {
            usernameLabel.text = tweet.user?.name
            
            if let profileURL = tweet.user?.profileURL {
                let data = NSData(contentsOfURL: profileURL)
                if let data = data {
                    profileButton.setImage(UIImage(data: data), forState: .Normal)
                }
            }
            
            if let screenname = tweet.user?.screenname {
                screenNameLabel.text = "@" + screenname
            }
            
            tweetText.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue
            tweetText.delegate = self
            tweetText.text = tweet.text
            
            if let text = tweet.text {
                let words = text.componentsSeparatedByString(" ")
                for word in words {
                    if word.hasPrefix("@") {
                        let allowedCharacters = "@abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_1234567890"
                        var cleanedWord = ""
                        for letter in word.characters {
                            if allowedCharacters.containsString(String(letter)) {
                                cleanedWord += String(letter)
                            }
                        }
                        let range = text.rangeOfString(cleanedWord)!
                        tweetText.addLinkToURL(NSURL(string: cleanedWord), withRange: NSRange(location: text.characters.startIndex.distanceTo(range.startIndex), length: range.count))
                    }
                }
            }
            
            if let timestamp = tweet.timestamp {
                timestampLabel.text = Tweet.timeAgoSince(timestamp)
            }
            
            retweetLabel.text = "\(tweet.retweetCount)"
            
            favoriteLabel.text = "\(tweet.favoritesCount)"
            
            if tweet.favorited == 1 {
                favoriteButton.selected = true
                favoriteButton.setImage(UIImage(named: "likePressed"), forState: .Highlighted)
            } else {
                favoriteButton.selected = false
                favoriteButton.setImage(UIImage(named: "likeOnPressed"), forState: .Highlighted)
            }
            
            if tweet.retweeted == 1 {
                retweetButton.selected = true
                retweetButton.setImage(UIImage(named: "retweetPressed"), forState: .Highlighted)
            } else {
                retweetButton.selected = false
                retweetButton.setImage(UIImage(named: "retweetOnPressed"), forState: .Highlighted)
            }
        }
    }

    @IBAction func retweetButtonPressed(sender: UIButton) {
        if !sender.selected {
            tweet!.retweet({
                self.updateView()
            }, failure: { (error: NSError) in
                print(error.localizedDescription)
            })
        } else {
            tweet!.unretweet({
                self.updateView()
                }, failure: { (error: NSError) in
                    print(error.localizedDescription)
            })
        }
    }
    
    @IBAction func favoriteButtonPressed(sender: UIButton) {
        if !sender.selected {
            tweet!.favorite({
                self.updateView()
                }, failure: { (error: NSError) in
                    print(error.localizedDescription)
            })
        } else {
            tweet!.unfavorite({
                self.updateView()
                }, failure: { (error: NSError) in
                    print(error.localizedDescription)
            })
        }
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
    
    func showProfile(sender: UIButton) {
        if let tweet = tweet {
            let vc = storyboard?.instantiateViewControllerWithIdentifier("TimelineViewController") as! TimelineViewController
            vc.timelineType = "user"
            vc.user = tweet.user
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "replySegue" {
            let vc = segue.destinationViewController as! ComposeViewController
            vc.replyUsername = tweet?.user?.name
            vc.replyScreenname = tweet?.user?.screenname
            vc.replyStatusID = (tweet?.idStr)!
        }
    }

}
