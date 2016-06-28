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
}

enum TokenURLs: String {
    case AccessToken = "oauth/access_token"
    case RequestToken = "oauth/request_token"
    case AuthorizeTokenBase = "https://api.twitter.com/oauth/authorize?oauth_token="
}

enum Observers: String {
    case Logout = "UserDidLogout"
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
    
    func homeTimeline(success: [Tweet] -> (), failure: NSError -> ()) {
        TwitterClient.sharedInstance.GET(JSONURLs.Timeline.rawValue, parameters: nil, progress: nil, success: {(task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                let dictionaries = response as! [NSDictionary]
                let tweets = Tweet.tweetsWithArray(dictionaries)
                success(tweets)
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
}
