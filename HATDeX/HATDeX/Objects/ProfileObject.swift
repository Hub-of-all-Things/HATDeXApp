//
//  ProfileObject.swift
//  hat-mobile-ios
//
//  Created by Marios-Andreas Tsekis on 21/12/17.
//  Copyright © 2017 HATDeX. All rights reserved.
//

import HatForIOS
import SwiftyJSON

internal struct ProfileObject: HatApiType {
    
    public init() {
        
    }

    var profile: HATProfileObject = HATProfileObject()
    var shareOptions: Dictionary<String, String> = [:]
    
    public mutating func initialaze(dict: Dictionary<String, JSON>) {
        
        if let tempProfile = dict["profile"]?.dictionaryValue {
            
            profile = HATProfileObject(from: tempProfile)
        }
        
        if let tempShareOptions = dict["shareOptions"]?.dictionaryObject as? Dictionary<String, String> {
            
            self.shareOptions = tempShareOptions
        }
    }
    
    func toJSON() -> Dictionary<String, Any> {
        
        return [
            "profile": self.profile.toJSON(),
            "shareOptions": self.shareOptions
        ]
    }
    
    mutating func initialize(fromCache: Dictionary<String, Any>) {
        
        let json = JSON(fromCache)
        self.initialaze(dict: json.dictionaryValue)
    }
}
