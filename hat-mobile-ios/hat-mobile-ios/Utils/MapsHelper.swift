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

import CoreLocation

// MARK: Struct

/// A struct for working with the Maps
struct MapsHelper {
    
    // MARK: - Maps settings
    
    /**
     Check the user preferences for accuracy setting
     
     - returns: The defined accuracy set by the user
     */
    static func GetUserPreferencesAccuracy() -> CLLocationAccuracy {
        
        let preferences = UserDefaults.standard
        
        if preferences.object(forKey: Constants.Preferences.UserNewDefaultAccuracy) != nil {
            
            // already done
        } else {
            
            // if none, best or 10m we go to 100m accuracy instead
            let existingAccuracy:CLLocationAccuracy = preferences.object(forKey: Constants.Preferences.MapLocationAccuracy) as? CLLocationAccuracy ?? kCLLocationAccuracyHundredMeters
            
            if ((existingAccuracy == kCLLocationAccuracyBest) || (existingAccuracy == kCLLocationAccuracyNearestTenMeters)) {
                
                preferences.set(kCLLocationAccuracyHundredMeters, forKey: Constants.Preferences.MapLocationAccuracy)
            }
            
            // set user delta
            preferences.set("UserNewDefaultAccuracy", forKey: Constants.Preferences.UserNewDefaultAccuracy)
        }
        
        let newAccuracy:CLLocationAccuracy = preferences.object(forKey: Constants.Preferences.MapLocationAccuracy) as? CLLocationAccuracy ?? kCLLocationAccuracyHundredMeters
        
        return newAccuracy
    }
    
    /**
     Check the user preferences for distance setting
     
     - returns: The defined desired distance set by the user
     */
    static func GetUserPreferencesDistance() -> CLLocationDistance {
        
        let minValue: CLLocationDistance = 100
        
        let preferences = UserDefaults.standard
        var newDistance: CLLocationDistance = preferences.object(forKey: Constants.Preferences.MapLocationDistance) as? CLLocationDistance ?? minValue
        
        // We will clip the lowest value up to a default, this can happen via a previous version of the app
        if newDistance < minValue {
            
            newDistance = minValue
        }
        
        return newDistance
    }
    
    // MARK: - Add locations to database
    
    /**
     Adds the locations passed to database
     
     - parameter locationManager: The location manager used
     - parameter locations: The locations to add
     */
    static func addLocationsToDatabase(locationManager: CLLocationManager, locations: [CLLocation]) {
        
        //get last location
        let latestLocation: CLLocation = locations[locations.count - 1]
        var dblocation: CLLocation? = nil
        var timeInterval: TimeInterval = TimeInterval()
        
        if let dbLastPoint = RealmHelper.getLastDataPoint() {
            
            dblocation = CLLocation(latitude: (dbLastPoint.lat), longitude: (dbLastPoint.lng))
            let lastRecordedDate = dbLastPoint.dateAdded
            timeInterval = Date().timeIntervalSince(lastRecordedDate)
        }
        
        // test that the horizontal accuracy does not indicate an invalid measurement
        if (latestLocation.horizontalAccuracy < 0) {
            
            return
        }
        
        print("time interval: \(timeInterval)")
        // check we have a measurement that meets our requirements,
        if ((latestLocation.horizontalAccuracy <= locationManager.desiredAccuracy)) || !(timeInterval.isLess(than: 10)) {
            
            if (dblocation != nil) {
                
                //calculate distance from previous spot
                let distance = latestLocation.distance(from: dblocation!)
                if !distance.isLess(than: locationManager.distanceFilter - (latestLocation.horizontalAccuracy + dblocation!.horizontalAccuracy)) {
                    
                    print("added")
                    // add data
                    _ = RealmHelper.addData(Double(latestLocation.coordinate.latitude), longitude: Double(latestLocation.coordinate.longitude), accuracy: Double(latestLocation.horizontalAccuracy))
                    let syncHelper = SyncDataHelper()
                    _ = syncHelper.CheckNextBlockToSync()
                }
            } else {
                
                print("added")
                // add data
                _ = RealmHelper.addData(Double(latestLocation.coordinate.latitude), longitude: Double(latestLocation.coordinate.longitude), accuracy: Double(latestLocation.horizontalAccuracy))
                let syncHelper = SyncDataHelper()
                _ = syncHelper.CheckNextBlockToSync()
            }
        }
    }

}
