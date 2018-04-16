//
/**
 * Copyright (C) 2018 HAT Data Exchange Ltd
 *
 * SPDX-License-Identifier: MPL2
 *
 * This file is part of the Hub of All Things project (HAT).
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/
 */

import SwiftyJSON

// MARK: Struct

public struct HATFacebookDataPostsPlaceSocialFeedObject: HATObject, HatApiType {
    
    // MARK: - Fields
    
    /// The possible Fields of the JSON struct
    public struct Fields {
        
        static let id: String = "id"
        static let name: String = "name"
        static let location: String = "location"
    }
    
    public var id: String = ""
    public var name: String = ""
    public var location: HATFacebookDataPostsPlaceLocationSocialFeedObject = HATFacebookDataPostsPlaceLocationSocialFeedObject()
    
    public init() {
        
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     
     - dictionary: The JSON file received
     */
    public init(from dictionary: Dictionary<String, JSON>) {
        
        self.inititialize(dict: dictionary)
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     
     - dict: The JSON file received
     */
    public mutating func inititialize(dict: Dictionary<String, JSON>) {
        
        if let tempID = dict[Fields.id]?.stringValue {
            
            id = tempID
        }
        if let tempName = dict[Fields.name]?.stringValue {
            
            name = tempName
        }
        if let tempLocation = dict[Fields.location]?.dictionaryValue {
            
            location = HATFacebookDataPostsPlaceLocationSocialFeedObject(from: tempLocation)
        }
    }
    
    public func toJSON() -> Dictionary<String, Any> {
        
        return [
            
            Fields.id: self.id,
            Fields.name: self.name,
            Fields.location: self.location.toJSON()
        ]
    }
    
    public mutating func initialize(fromCache: Dictionary<String, Any>) {
        
        let dictionary = JSON(fromCache)
        self.inititialize(dict: dictionary.dictionaryValue)
    }

}
