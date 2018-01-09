/**
 * Copyright (C) 2017 HAT Data Exchange Ltd
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

/// A struct representing the profile data About object from the received profile JSON file
public struct HATProfileDataProfileAboutObject: Comparable {
    
    // MARK: - Fields
    
    struct Fields {
        
        static let isPrivate: String = "private"
        static let isPrivateID: String = "privateID"
        static let title: String = "title"
        static let titleID: String = "titleID"
        static let body: String = "body"
        static let bodyID: String = "bodyID"
        static let name: String = "name"
        static let fieldID: String = "id"
        static let values: String = "values"
        static let value: String = "value"
    }
    
    // MARK: - Comparable protocol
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: HATProfileDataProfileAboutObject, rhs: HATProfileDataProfileAboutObject) -> Bool {
        
        return (lhs.isPrivate == rhs.isPrivate && lhs.title == rhs.title && lhs.body == rhs.body)
    }
    
    /// Returns a Boolean value indicating whether the value of the first
    /// argument is less than that of the second argument.
    ///
    /// This function is the only requirement of the `Comparable` protocol. The
    /// remainder of the relational operator functions are implemented by the
    /// standard library for any type that conforms to `Comparable`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func < (lhs: HATProfileDataProfileAboutObject, rhs: HATProfileDataProfileAboutObject) -> Bool {
        
        return lhs.title < rhs.title
    }
    
    // MARK: - Variables
    
    /// Indicates if the object, HATProfileDataProfileAboutObject, is private
    public var isPrivate: Bool = true {
        
        didSet {
            
            isPrivateTuple = (isPrivate, isPrivateTuple.1)
        }
    }
    
    /// The title of the about section
    public var title: String = "" {
        
        didSet {
            
            titleTuple = (title, titleTuple.1)
        }
    }
    
    /// The body of the about section
    public var body: String = "" {
        
        didSet {
            
            bodyTuple = (body, bodyTuple.1)
        }
    }
    
    /// A tuple containing the isPrivate and the ID of the value
    var isPrivateTuple: (Bool, Int) = (true, 0)
    
    /// A tuple containing the value and the ID of the value
    var titleTuple: (String, Int) = ("", 0)
    
    /// A tuple containing the value and the ID of the value
    var bodyTuple: (String, Int) = ("", 0)
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    public init() {
        
        isPrivate = true
        title = ""
        body = ""
        
        isPrivateTuple = (true, 0)
        titleTuple = ("", 0)
        bodyTuple = ("", 0)
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    public init(from array: [JSON]) {
        
        for json in array {
            
            let dict = json.dictionaryValue
            
            if let tempName = (dict[Fields.name]?.stringValue), let id = dict[Fields.fieldID]?.intValue {
                
                if tempName == "private" {
                    
                    if let tempValues = dict[Fields.values]?.arrayValue {
                        
                        if let stringValue = tempValues[0].dictionaryValue[Fields.value]?.stringValue {
                            
                            if let result = Bool(stringValue) {
                                
                                isPrivate = result
                            } else {
                                
                                isPrivate = false
                            }
                            
                            isPrivateTuple = (isPrivate, id)
                        }
                    }
                }
                
                if tempName == "title" {
                    
                    if let tempValues = dict[Fields.values]?.arrayValue {
                        
                        if let stringValue = tempValues[0].dictionaryValue[Fields.value]?.stringValue {
                            
                            title = stringValue
                            titleTuple = (title, id)
                        }
                    }
                }
                
                if tempName == "body" {
                    
                    if let tempValues = dict[Fields.values]?.arrayValue {
                        
                        if let stringValue = tempValues[0].dictionaryValue[Fields.value]?.stringValue {
                            
                            body = stringValue
                            bodyTuple = (body, id)
                        }
                    }
                }
            }
        }
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    public init(alternativeArray: [JSON]) {
        
        for json in alternativeArray {
            
            let dict = json.dictionaryValue
            
            if let tempName = (dict[Fields.name]?.stringValue), let id = dict[Fields.fieldID]?.intValue {
                
                if tempName == "private" {
                    
                    isPrivate = true
                    isPrivateTuple = (isPrivate, id)
                }
                
                if tempName == "title" {
                    
                    title = ""
                    titleTuple = (title, id)
                }
                
                if tempName == "body" {
                    
                    body = ""
                    bodyTuple = (body, id)
                }
            }
        }
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    public init (fromCache: Dictionary<String, JSON>) {
        
        if let tempPrivate = (fromCache[Fields.isPrivate]?.stringValue) {
            
            if let isPrivateResult = Bool(tempPrivate) {
                
                isPrivate = isPrivateResult
            }
        }
        
        if let tempPrivateID = (fromCache[Fields.isPrivateID]?.intValue) {
            
            isPrivateTuple = (isPrivate, tempPrivateID)
        }
        
        if let tempTitle = (fromCache[Fields.title]?.stringValue) {
            
            title = tempTitle
        }
        
        if let tempTitleID = (fromCache[Fields.titleID]?.intValue) {
            
            titleTuple = (title, tempTitleID)
        }
        
        if let tempBody = (fromCache[Fields.body]?.stringValue) {
            
            body = tempBody
        }
        
        if let tempBodyID = (fromCache[Fields.bodyID]?.intValue) {
            
            bodyTuple = (body, tempBodyID)
        }
    }
    
    // MARK: - JSON Mapper
    
    /**
     Returns the object as Dictionary, JSON
     
     - returns: Dictionary<String, String>
     */
    public func toJSON() -> Dictionary<String, Any> {
        
        return [
            
            Fields.isPrivate: String(describing: self.isPrivate),
            Fields.isPrivateID: isPrivateTuple.1,
            Fields.title: self.title,
            Fields.titleID: titleTuple.1,
            Fields.body: self.body,
            Fields.bodyID: bodyTuple.1
        ]
    }
    
}