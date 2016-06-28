//
//  DetailViewController.swift
//  Chirpy
//
//  Created by Alexander Strandberg on 6/28/16.
//  Copyright © 2016 Alexander Strandberg. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var tweetText: UITextView!
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
        
        retweetButton.setImage(UIImage(named: "retweetPressed"), forState: .Highlighted)
        retweetButton.setImage(UIImage(named: "retweetOnHover"), forState: .Selected)
        
        favoriteButton.setImage(UIImage(named: "likePressed"), forState: .Highlighted)
        favoriteButton.setImage(UIImage(named: "likeOnHover"), forState: .Selected)
        
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
                
                profileImageView.setImageWithURL(profileURL)
            }
            
            if let screenname = tweet.user?.screenname {
                screenNameLabel.text = "@" + screenname
            }
            
            tweetText.text = tweet.text
            
            if let timestamp = tweet.timestamp {
                timestampLabel.text = Tweet.timeAgoSince(timestamp)
            }
            
            retweetLabel.text = "\(tweet.retweetCount)"
            
            favoriteLabel.text = "\(tweet.favoritesCount)"
            
            if tweet.favorited == 1 {
                favoriteButton.selected = true
            } else {
                favoriteButton.selected = false
            }
            
            if tweet.retweeted == 1 {
                retweetButton.selected = true
            } else {
                retweetButton.selected = false
            }
        }
    }
    
    @IBAction func replyButtonPressed(sender: UIButton) {
        
    }

    @IBAction func retweetButtonPressed(sender: UIButton) {
        if !sender.selected {
            tweet!.retweet({
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}