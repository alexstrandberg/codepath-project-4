//
//  User.swift
//  Chirpy
//
//  Created by Alexander Strandberg on 6/27/16.
//  Copyright © 2016 Alexander Strandberg. All rights reserved.
//

import UIKit

class User: NSObject {
    var name: NSString?
    var screenname: NSString?
    var profileURL: NSURL?
    var tagline: NSString?
    
    var dictionary: NSDictionary?
    
    enum UserKeys: String {
        case UserName = "name"
        case ScreenName = "screen_name"
        case ProfileURL = "profile_image_url_https"
        case Tagline = "description"
        case CurrentUserDataDefaults = "currentUserData"
    }
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        
        name = dictionary[UserKeys.UserName.rawValue] as? String
        screenname = dictionary[UserKeys.ScreenName.rawValue] as? String
        
        let profileURLString = dictionary[UserKeys.ProfileURL.rawValue] as? String
        if let profileURLString = profileURLString {
            profileURL = NSURL(string: profileURLString)
        }
        
        tagline = dictionary[UserKeys.Tagline.rawValue] as? String
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