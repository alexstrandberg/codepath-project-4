//
//  ProfileViewController.swift
//  Chirpy
//
//  Created by Alexander Strandberg on 6/28/16.
//  Copyright © 2016 Alexander Strandberg. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var taglineLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var exitButton: UIBarButtonItem!
    
    var user: User?
    
    let profileTabIndex = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationItem.title = "View Profile"
        
        if tabBarController?.selectedIndex == profileTabIndex {
            navigationItem.leftBarButtonItem = nil
        }
        
        if user == nil {
            user = User.currentUser
        }
        
        if let user = user {
            nameLabel.text = user.name
            
            if user.screenname == User.currentUser?.screenname {
                navigationItem.title = "My Profile"
            }
            
            if let profileURL = user.profileURL {
                imageView.setImageWithURL(profileURL)
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
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func exitPressed(sender: AnyObject) {
        if tabBarController?.selectedIndex != profileTabIndex {
            dismissViewControllerAnimated(true, completion: nil)
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
