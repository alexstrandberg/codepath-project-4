//
//  Tweet.swift
//  Chirpy
//
//  Created by Alexander Strandberg on 6/27/16.
//  Copyright © 2016 Alexander Strandberg. All rights reserved.
//

import UIKit

extension String {
    // Taken from: http://stackoverflow.com/a/34245313
    init(htmlEncodedString: String) {
        if let encodedData = htmlEncodedString.dataUsingEncoding(NSUTF8StringEncoding){
            let attributedOptions : [String: AnyObject] = [
                NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding
            ]
            
            do{
                if let attributedString:NSAttributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil){
                    self.init(attributedString.string)
                }else{
                    print("error")
                    self.init(htmlEncodedString)     //Returning actual string if there is an error
                }
            }catch{
                print("error: \(error)")
                self.init(htmlEncodedString)     //Returning actual string if there is an error
            }
            
        }else{
            self.init(htmlEncodedString)     //Returning actual string if there is an error
        }
    }
}

class Tweet: NSObject {
    var text: String?
    var timestamp: NSDate?
    var retweetCount: Int = 0
    var favoritesCount: Int = 0
    var user: User?
    var idStr: String?
    var favorited: Int = 0
    var retweeted: Int = 0
    
    enum TweetKeys: String {
        case Text = "text"
        case Timestamp = "created_at"
        case RetweetCount = "retweet_count"
        case FavoritesCount = "favorite_count"
        case User = "user"
        case IDStr = "id_str"
        case Favorited = "favorited"
        case Retweeted = "retweeted"
    }
    
    init (dictionary: NSDictionary) {
        text = dictionary[TweetKeys.Text.rawValue] as? String
        if let text = text {
            self.text = String(htmlEncodedString: text)
        }
        
        retweetCount = dictionary[TweetKeys.RetweetCount.rawValue] as? Int ?? 0
        favoritesCount = dictionary[TweetKeys.FavoritesCount.rawValue] as? Int ?? 0
        
        let timestampString = dictionary[TweetKeys.Timestamp.rawValue] as? String
        
        if let timestampString = timestampString {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            timestamp = formatter.dateFromString(timestampString)
        }
        
        idStr = dictionary[TweetKeys.IDStr.rawValue] as? String
        
        favorited = dictionary[TweetKeys.Favorited.rawValue] as? Int ?? 0
        retweeted = dictionary[TweetKeys.Retweeted.rawValue] as? Int ?? 0
        
        if let userData = dictionary[TweetKeys.User.rawValue] as? NSDictionary {
            self.user = User(dictionary: userData)
        }
    }
    
    class func tweetsWithArray(dictionaries: [NSDictionary]) -> [Tweet] {
        var tweets: [Tweet] = []
        
        for dictionary in dictionaries {
            tweets.append(Tweet(dictionary: dictionary))
        }
        
        return tweets
    }
    
    // Code adapted from: https://github.com/zemirco/swift-timeago
    class func timeAgoSince(date: NSDate) -> String {
        
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        let unitFlags: NSCalendarUnit = [.Second, .Minute, .Hour, .Day, .WeekOfYear, .Month, .Year]
        let components = calendar.components(unitFlags, fromDate: date, toDate: now, options: [])
        
        if components.year > 0 {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "MMM d yyyy"
            return formatter.stringFromDate(date)
        }
        
        if components.day >= 1 {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.stringFromDate(date)
        }
        
        if components.hour >= 1 {
            return "\(components.hour)h"
        }
        
        if components.minute >= 1 {
            return "\(components.minute)m"
        }
        
        if components.second >= 3 {
            return "\(components.second)s"
        }
        
        return "1s"
        
    }
    
    func favorite(success: () -> (), failure: (NSError) -> ()) {
        TwitterClient.sharedInstance.favorite(self, success: { (tweet: Tweet) in
            self.favoritesCount = tweet.favoritesCount
            self.favorited = tweet.favorited
            success()
        }) { (error: NSError) in
            failure(error)
        }
    }
    
    func unfavorite(success: () -> (), failure: (NSError) -> ()) {
        TwitterClient.sharedInstance.unfavorite(self, success: { (tweet: Tweet) in
            self.favoritesCount = tweet.favoritesCount
            self.favorited = tweet.favorited
            success()
        }) { (error: NSError) in
            failure(error)
        }
    }
    
    func retweet(success: () -> (), failure: (NSError) -> ()) {
        TwitterClient.sharedInstance.retweet(self, success: { (tweet: Tweet) in
            self.retweetCount = tweet.retweetCount
            self.retweeted = tweet.retweeted
            success()
        }) { (error: NSError) in
            failure(error)
        }
    }
}
