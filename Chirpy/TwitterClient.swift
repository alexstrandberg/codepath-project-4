//
//  TwitterClient.swift
//  Chirpy
//
//  Created by Alexander Strandberg on 6/27/16.
//  Copyright © 2016 Alexander Strandberg. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

enum JSONURLs: String {
    case Timeline = "1.1/statuses/home_timeline.json"
    case VerifyCredentials = "1.1/account/verify_credentials.json"
    case Favorite = "1.1/favorites/create.json?id="
    case Unfavorite = "1.1/favorites/destroy.json?id="
    case Retweet = "1.1/statuses/retweet/"
    case PostTweet = "1.1/statuses/update.json?status="
    case Mentions = "1.1/statuses/mentions_timeline.json"
    case UnRetweet = "1.1/statuses/unretweet/"
    case UserFromScreenname = "1.1/users/show.json?screen_name="
}

enum TokenURLs: String {
    case AccessToken = "oauth/access_token"
    case RequestToken = "oauth/request_token"
    case AuthorizeTokenBase = "https://api.twitter.com/oauth/authorize?oauth_token="
}

enum Observers: String {
    case Logout = "UserDidLogout"
    case Login = "UserDidLogin"
}

extension String {
    // Taken from: http://useyourloaf.com/blog/how-to-percent-encode-a-url-string/
    func stringByAddingPercentEncodingForRFC3986() -> String? {
        let unreserved = "-._~/?"
        let allowed = NSMutableCharacterSet.alphanumericCharacterSet()
        allowed.addCharactersInString(unreserved)
        return stringByAddingPercentEncodingWithAllowedCharacters(allowed)
    }    
}

class TwitterClient: BDBOAuth1SessionManager {
    static let sharedInstance = TwitterClient(baseURL: NSURL(string: "https://api.twitter.com"), consumerKey: "FI23KQjr7CC77AnJQSIIFWv95", consumerSecret: "XBQczsq9YfWQFKm2HM86Kd5jdpdEgMvmbbTwT0IGeEX4Oda4PT")
    
    var loginSuccess: (() -> ())?
    var loginFailure: ((NSError) -> ())?
    
    func login(success: () -> (), failure: (NSError) -> ()) {
        loginSuccess = success
        loginFailure = failure
        
        deauthorize()
        fetchRequestTokenWithPath(TokenURLs.RequestToken.rawValue, method: "GET", callbackURL: NSURL(string: "chirpy://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) -> Void in
            let url = NSURL(string: TokenURLs.AuthorizeTokenBase.rawValue + requestToken.token)!
            UIApplication.sharedApplication().openURL(url)
            }, failure: {(error: NSError!) -> Void in
                print("error: \(error.localizedDescription)")
                self.loginFailure?(error)
        })
    }
    
    func logout() {
        User.currentUser = nil
        deauthorize()
        NSNotificationCenter.defaultCenter().postNotificationName(Observers.Logout.rawValue, object: nil)
    }
    
    func handleOpenURL(url: NSURL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        fetchAccessTokenWithPath(TokenURLs.AccessToken.rawValue, method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential!) -> Void in
                self.currentAccount({ ( user: User) in
                    User.currentUser = user
                    }, failure: { (error: NSError) in
                        self.loginFailure?(error)
                })
                self.loginSuccess?()
            }, failure: { (error: NSError!) in
                self.loginFailure?(error)
        })
    }
    
    func timeline(maxID: String = "", timelineType: String = "home", success: ([Tweet], Bool) -> (), failure: NSError -> ()) {
        var url = ""
        var shouldClearArray = true
        if timelineType == "home" {
            url = JSONURLs.Timeline.rawValue
        } else if timelineType == "mentions" {
            url = JSONURLs.Mentions.rawValue
        }
        
        if maxID != "" {
            url += "?max_id="+maxID
            url += "&count=21" // First tweet returned will be a duplicate
            shouldClearArray = false
        }
        
        TwitterClient.sharedInstance.GET(url, parameters: nil, progress: nil, success: {(task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                let dictionaries = response as! [NSDictionary]
                var tweets = Tweet.tweetsWithArray(dictionaries)
                if maxID != "" {
                    tweets.removeAtIndex(0) // If loading more tweets into existing tableView, remove the first tweet (duplicated)
                }
                success(tweets, shouldClearArray)
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
        })
    }
    
    func currentAccount(success: User -> (), failure: NSError -> ()) {
        TwitterClient.sharedInstance.GET(JSONURLs.VerifyCredentials.rawValue, parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) in
                let userDictionary = response as! NSDictionary
                let user = User(dictionary: userDictionary)
                success(user)
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) in
                failure(error)
        })
        
    }
    
    func userFromScreenname(screenname: String, success: User -> (), failure: NSError -> ()) {
        let url = JSONURLs.UserFromScreenname.rawValue + screenname
        TwitterClient.sharedInstance.GET(url, parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) in
            let userDictionary = response as! NSDictionary
            let user = User(dictionary: userDictionary)
            success(user)
        }, failure: { (task: NSURLSessionDataTask?, error: NSError) in
            failure(error)
        })
    }
    
    func favorite(tweet: Tweet, success: (Tweet) -> (), failure: NSError -> ()) {
        let url = JSONURLs.Favorite.rawValue + tweet.idStr!
        TwitterClient.sharedInstance.POST(url, parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) in
            success(Tweet(dictionary: response as! NSDictionary))
        }) { (task: NSURLSessionDataTask?, error: NSError) in
            failure(error)
        }
    }
    
    func unfavorite(tweet: Tweet, success: (Tweet) -> (), failure: NSError -> ()) {
        let url = JSONURLs.Unfavorite.rawValue + tweet.idStr!
        TwitterClient.sharedInstance.POST(url, parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) in
            success(Tweet(dictionary: response as! NSDictionary))
        }) { (task: NSURLSessionDataTask?, error: NSError) in
            failure(error)
        }
    }
    
    func retweet(tweet: Tweet, success: (Tweet) -> (), failure: NSError -> ()) {
        let url = JSONURLs.Retweet.rawValue + tweet.idStr! + ".json"
        TwitterClient.sharedInstance.POST(url, parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) in
            success(Tweet(dictionary: response as! NSDictionary))
        }) { (task: NSURLSessionDataTask?, error: NSError) in
            failure(error)
        }
    }
    
    func unretweet(tweet: Tweet, success: (Tweet) -> (), failure: NSError -> ()) {
        let url = JSONURLs.UnRetweet.rawValue + tweet.idStr! + ".json"
        TwitterClient.sharedInstance.POST(url, parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) in
            success(Tweet(dictionary: response as! NSDictionary))
        }) { (task: NSURLSessionDataTask?, error: NSError) in
            failure(error)
        }
    }
    
    func postTweet(replyStatusID replyStatusID: String = "", message: String, success: (Tweet) -> (), failure: NSError -> ()) {
        var url = JSONURLs.PostTweet.rawValue + message.stringByAddingPercentEncodingForRFC3986()!
        if replyStatusID != "" {
            url += "&in_reply_to_status_id=" + replyStatusID
        }
        TwitterClient.sharedInstance.POST(url, parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) in
            success(Tweet(dictionary: response as! NSDictionary))
        }) { (task: NSURLSessionDataTask?, error: NSError) in
            failure(error)
        }
    }
}
