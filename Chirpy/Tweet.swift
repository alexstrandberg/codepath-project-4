//
//  Tweet.swift
//  Chirpy
//
//  Created by Alexander Strandberg on 6/27/16.
//  Copyright © 2016 Alexander Strandberg. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    var text: String?
    var timestamp: NSDate?
    var retweetCount: Int = 0
    var favoritesCount: Int = 0
    var user: User?
    
    enum TweetKeys: String {
        case Text = "text"
        case Timestamp = "created_at"
        case RetweetCount = "retweet_count"
        case FavoritesCount = "favorites_count"
        case User = "user"
    }
    
    init (dictionary: NSDictionary) {
        text = dictionary[TweetKeys.Text.rawValue] as? String
        
        retweetCount = dictionary[TweetKeys.RetweetCount.rawValue] as? Int ?? 0
        favoritesCount = dictionary[TweetKeys.FavoritesCount.rawValue] as? Int ?? 0
        
        let timestampString = dictionary[TweetKeys.Timestamp.rawValue] as? String
        
        if let timestampString = timestampString {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            timestamp = formatter.dateFromString(timestampString)
        }
        
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
}
