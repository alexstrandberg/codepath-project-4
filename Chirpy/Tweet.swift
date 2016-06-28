//
//  Tweet.swift
//  Chirpy
//
//  Created by Alexander Strandberg on 6/27/16.
//  Copyright © 2016 Alexander Strandberg. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    var text: NSString?
    var timestamp: NSDate?
    var retweetCount: Int = 0
    var favoritesCount: Int = 0
    
    enum TweetKeys: String {
        case Text = "text"
        case Timestamp = "created_at"
        case RetweetCount = "retweet_count"
        case FavoritesCount = "favorites_count"
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
    }
    
    class func tweetsWithArray(dictionaries: [NSDictionary]) -> [Tweet] {
        var tweets: [Tweet] = []
        
        for dictionary in dictionaries {
            tweets.append(Tweet(dictionary: dictionary))
        }
        
        return tweets
    }
}
