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

import RealmSwift

// MARK: Class

/// The DataPoint object representation
public class DataPoint: Object {
    
    // MARK: - Variables
    
    /// The latitude of the point
    @objc dynamic var lat: Double = 0
    /// The longitude of the point
    @objc dynamic var lng: Double = 0
    /// The accuracy of the point
    @objc dynamic var accuracy: Double = 0
    
    /// The added point date of the point
    @objc dynamic var dateAdded: Date = Date()
    /// The last sync date of the point
    @objc dynamic var lastSynced: Date?
}
