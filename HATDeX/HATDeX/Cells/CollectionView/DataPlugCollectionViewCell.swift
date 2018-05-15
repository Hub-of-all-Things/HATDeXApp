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

import HatForIOS

// MARK: Class

/// The collection view cell class for data plugs screen
internal class DataPlugCollectionViewCell: UICollectionViewCell, UserCredentialsProtocol {
    
    // MARK: - Variables
    
    private var dataPlug: HATApplicationObject?
    
    // MARK: - IBOutlets
    
    /// The image for the data plug
    @IBOutlet private weak var dataPlugImage: UIImageView!
    /// The checkmark image for the data plug. It's hidden if it's not active
    @IBOutlet private weak var checkMarkImage: UIImageView!
    
    /// The title for the data plug
    @IBOutlet private weak var dataPlugTitleLabel: UILabel!
    /// Some details for the data plug
    @IBOutlet private weak var dataPlugDetailsLabel: UILabel!
    
    // MARK: - Set up cell
    
    /**
     Sets up a cell according to our needs
     
     - parameter cell: The UICollectionViewCell to set up
     - parameter indexPath: The index path of the cell
     - parameter dataPlug: The HATDataPlugObject to take the values from
     - parameter orientation: The current orientation of the phone
     
     - returns: An UICollectionViewCell
     */
    class func setUp(cell: DataPlugCollectionViewCell, indexPath: IndexPath, dataPlug: HATApplicationObject, orientation: UIInterfaceOrientation) -> UICollectionViewCell {
        
        // Configure the cell
        cell.checkMarkImage.isHidden = true
        cell.dataPlugTitleLabel.text = dataPlug.application.id.capitalized
        cell.dataPlugDetailsLabel.text = dataPlug.application.info.description.text
        cell.dataPlug = dataPlug
        if let url = URL(string: dataPlug.application.info.graphics.logo.normal) {
            
            cell.dataPlugImage.downloadedFrom(
                url: url,
                userToken: userToken,
                progressUpdater: nil,
                completion: nil)
        }
        
        cell.checkDataPlugsIfActive()
        cell.backgroundColor = self.backgroundColorOfCellForIndexPath(indexPath, in: orientation)
        
        // return cell
        return cell
    }
    
    // MARK: - Check if data plugs are active
    
    /**
     Checks if both data plugs are active
     */
    private func checkDataPlugsIfActive() {
        
        guard let plug = self.dataPlug else {
            
            self.checkMarkImage.isHidden = true
            return
        }
        
        if plug.active && plug.setup && !(plug.needsUpdating ?? false) {
            
            self.checkMarkImage.isHidden = false
        } else {
            
            self.checkMarkImage.isHidden = true
        }
    }
    
    // MARK: - Decide background color
    
    /**
     Decides the colof of the cell based on the index path and the device orientation
     
     - parameter indexPath: The index path of the cell
     - parameter orientation: The device current orientation
     
     - returns: The color of the cell based on the index path and the device orientation
     */
    private class func backgroundColorOfCellForIndexPath(_ indexPath: IndexPath, in orientation: UIInterfaceOrientation) -> UIColor {
        
        let model = UIDevice.current.model
        if model == "iPhone" {
            
            if orientation.isPortrait {
                
                // create this zebra like color based on the index of the cell
                if (indexPath.row % 4 == 0) || (indexPath.row % 3 == 0) {
                    
                    return .rumpelVeryLightGray
                }
            } else {
                
                // create this zebra like color based on the index of the cell
                if indexPath.row % 2 == 0 {
                    
                    return .rumpelVeryLightGray
                }
            }
            
            return .white
        } else {
            
            if orientation.isPortrait {
                
                // create this zebra like color based on the index of the cell
                if indexPath.row % 5 == 0 || indexPath.row % 5 == 2 {
                    
                    return .rumpelVeryLightGray
                }
            } else {
                
                // create this zebra like color based on the index of the cell
                if indexPath.row % 7 == 0 || indexPath.row % 7 == 2 || indexPath.row % 7 == 4 {
                    
                    return .rumpelVeryLightGray
                }
            }
            
            return .white
        }
    }
    
    // MARK: - Get Plug Object
    
    /**
     Returns the dataPlug object of the cell
     
     - returns: The dataPlug object of the cell
     */
    func getCellPlugObject() -> HATApplicationObject? {
        
        return self.dataPlug
    }
}
