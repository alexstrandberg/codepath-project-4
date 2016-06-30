//
//  ComposeViewController.swift
//  Chirpy
//
//  Created by Alexander Strandberg on 6/28/16.
//  Copyright © 2016 Alexander Strandberg. All rights reserved.
//

import UIKit
import MBProgressHUD

protocol ComposeViewControllerDelegate : class {
    func didPostTweet(tweet: Tweet)
}

class ComposeViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var charactersLeftLabel: UILabel!
    @IBOutlet weak var tweetButton: UIButton!
    @IBOutlet weak var composeLabel: UILabel!
    
    let tweetPlaceholder = "What's happening?"
    let characterLimit = 140
    
    weak var delegate: ComposeViewControllerDelegate?
    
    var replyStatusID: String = ""
    var replyUsername: String?
    var replyScreenname: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        toggleButton(false)
        
        tweetTextView.text = tweetPlaceholder
        tweetTextView.textColor = UIColor.lightGrayColor()
        tweetTextView.delegate = self
        
        if let replyUsername = replyUsername, let replyScreenname = replyScreenname {
            tweetTextView.text = "@" + replyScreenname + " "
            composeLabel.text = "Reply to " + replyUsername
            tweetTextView.textColor = UIColor.blackColor()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == tweetPlaceholder {
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
        textView.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" {
            textView.text = tweetPlaceholder
            textView.textColor = UIColor.lightGrayColor()
        }
        textView.resignFirstResponder()
    }
    
    func textViewDidChange(textView: UITextView) {
        charactersLeftLabel.text = "\(characterLimit-textView.text.characters.count)"
        if characterLimit-textView.text.characters.count < 0 {
            textView.text = textView.text.substringToIndex(textView.text.startIndex.advancedBy(characterLimit))
            charactersLeftLabel.text = "0"
        }
        if textView.text.characters.count > 0 {
            toggleButton(true)
        } else {
            toggleButton(false)
        }
        
        if let replyScreenname = replyScreenname, replyUsername = replyUsername {
            if textView.text.containsString("@"+replyScreenname+" ") {
                composeLabel.text = "Reply to " + replyUsername
            } else {
                composeLabel.text = "Compose Tweet"
            }
        }
    }
    
    @IBAction func tapped(sender: UITapGestureRecognizer) {
        tweetTextView.resignFirstResponder()
    }

    @IBAction func postTweet(sender: UIButton) {
        toggleButton(false)
        // Display HUD right before the request is made
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        TwitterClient.sharedInstance.postTweet(replyStatusID: replyStatusID, message: tweetTextView.text, success: { (tweet: Tweet) in
            self.delegate?.didPostTweet(tweet)
            // Hide HUD once the network request comes back (must be done on main UI thread)
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            self.dismissViewControllerAnimated(true, completion: nil)
        }) { (error: NSError) in
            print(error.localizedDescription)
        }
    }
    
    @IBAction func cancelButton(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func toggleButton(enabled: Bool) {
        tweetButton.enabled = enabled
        if enabled {
            UIView.animateWithDuration(0.5, delay:0, options:UIViewAnimationOptions.TransitionFlipFromTop, animations: {
                self.tweetButton.alpha = 1
                }, completion: { finished in
            })
        } else {
            UIView.animateWithDuration(0.5, delay:0, options:UIViewAnimationOptions.TransitionFlipFromTop, animations: {
                self.tweetButton.alpha = 0.5
                }, completion: { finished in
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
