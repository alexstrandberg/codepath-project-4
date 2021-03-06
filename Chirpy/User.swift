//
//  User.swift
//  Chirpy
//
//  Created by Alexander Strandberg on 6/27/16.
//  Copyright © 2016 Alexander Strandberg. All rights reserved.
//

import UIKit

class User: NSObject {
    var name: String?
    var screenname: String?
    var profileURL: NSURL?
    var profileURLBigger: NSURL?
    var tagline: String?
    var following: Int = 0
    var followers: Int = 0
    var profileBannerURL: NSURL?
    
    var dictionary: NSDictionary?
    
    enum UserKeys: String {
        case UserName = "name"
        case ScreenName = "screen_name"
        case ProfileURL = "profile_image_url_https"
        case Tagline = "description"
        case CurrentUserDataDefaults = "currentUserData"
        case Following = "friends_count"
        case Followers = "followers_count"
        case ProfileBannerURL = "profile_banner_url"
    }
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        
        name = dictionary[UserKeys.UserName.rawValue] as? String
        screenname = dictionary[UserKeys.ScreenName.rawValue] as? String
        
        let profileURLString = dictionary[UserKeys.ProfileURL.rawValue] as? String
        if let profileURLString = profileURLString {
            profileURL = NSURL(string: profileURLString)
            let modifiedProfileURLString = profileURLString.stringByReplacingOccurrencesOfString("_normal", withString: "_bigger")
            profileURLBigger = NSURL(string: modifiedProfileURLString)
        }
        
        tagline = dictionary[UserKeys.Tagline.rawValue] as? String
        
        following = dictionary[UserKeys.Following.rawValue] as? Int ?? 0
        
        followers = dictionary[UserKeys.Followers.rawValue] as? Int ?? 0
        
        let profileBannerURLString = dictionary[UserKeys.ProfileBannerURL.rawValue] as? String
        if let profileBannerURLString = profileBannerURLString {
            profileBannerURL = NSURL(string: profileBannerURLString)
        }
    }
    
    static var _currentUser: User?
    
    class var currentUser: User? {
        get {
            if _currentUser == nil {
            
                let defaults = NSUserDefaults.standardUserDefaults()
                let userData = defaults.objectForKey(UserKeys.CurrentUserDataDefaults.rawValue) as? NSData
                
                if let userData = userData {
                    let dictionary = try! NSJSONSerialization.JSONObjectWithData(userData, options: []) as! NSDictionary
                    _currentUser = User(dictionary: dictionary)
                }
            }
            
            return _currentUser
        } set(user) {
            let defaults = NSUserDefaults.standardUserDefaults()
            
            if let user = user {
                let data = try! NSJSONSerialization.dataWithJSONObject(user.dictionary!, options: [])
                defaults.setObject(data, forKey: UserKeys.CurrentUserDataDefaults.rawValue)
            } else {
                defaults.setObject(nil, forKey: UserKeys.CurrentUserDataDefaults.rawValue)
            }
            
            defaults.synchronize()
        }
    }
}