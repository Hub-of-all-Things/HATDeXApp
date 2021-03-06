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

internal class ListDataOffersCollectionViewCell: UICollectionViewCell, UserCredentialsProtocol {
    
    // MARK: - IBOutlets
    
    /// An IBOutlet for handling the vendor name UILabel
    @IBOutlet private weak var offerVendorNameLabel: UILabel!
    /// An IBOutlet for handling the expiry date for the offer UILabel
    @IBOutlet private weak var dateLabel: UILabel!
    /// An IBOutlet for handling the reward type UILabel
    @IBOutlet private weak var rewardTypeLabel: UILabel!
    
    /// An IBOutlet for handling the ring progress bar whilst downloading the image
    @IBOutlet private weak var ringProgressBar: RingProgressCircle!

    /// An IBOutlet for handling the url of the offer UITextView
    @IBOutlet private weak var offerVendorURLTextView: UITextView!
    
    /// An IBOutlet for handling the UIImageView of the offer
    @IBOutlet private weak var offerImageView: UIImageView!

    // MARK: - Set up cell
    
    /**
     Sets up the cell to show the data we need
     
     - parameter cell: The cell to set up
     - parameter dataOffer: The data to set up the cell from
     - parameter completion: An optional function to execute returning the downloaded image
     
     - returns: An UICollectionViewCell already been set up
     */
    func setUpCell(cell: ListDataOffersCollectionViewCell, dataOffer: DataOfferObject, completion: ((UIImage) -> Void)?) -> UICollectionViewCell {
        
        self.setUpCellUI(cell: cell, dataOffer: dataOffer)
        
        if dataOffer.image == nil {
            
            self.downloadOfferImage(url: dataOffer.illustrationURL, cell: cell, completion: completion)
        }
        
        return cell
    }
    
    /**
     Updates the cell's UI
     
     - parameter cell: The cell to update the UI
     - parameter dataOffer: The dataOffer object holding the data we need in order to update the cell
     */
    private func setUpCellUI(cell: ListDataOffersCollectionViewCell, dataOffer: DataOfferObject) {
        
        let date = Date(timeIntervalSince1970: TimeInterval(dataOffer.offerExpires / 1000))
        let dateString = FormatterHelper.formatDateStringToUsersDefinedDate(
            date: date,
            dateStyle: .short,
            timeStyle: .none)
        
        cell.rewardTypeLabel.text = "Reward type: \(dataOffer.reward.rewardType)"
        cell.offerVendorURLTextView.text = dataOffer.reward.vendorURL
        cell.offerVendorNameLabel.text = dataOffer.reward.vendor
        cell.dateLabel.text = "Expires: \(dateString)"
        cell.offerImageView.image = dataOffer.image
        
        cell.ringProgressBar.ringColor = .white
        cell.ringProgressBar.ringRadius = 45
        cell.ringProgressBar.ringLineWidth = 4
        cell.ringProgressBar.animationDuration = 0.2
        cell.ringProgressBar.isHidden = true
        
        cell.layer.cornerRadius = 5
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.dataOffersBorderColor.cgColor
        
        if let codes = dataOffer.reward.codes {
            
            if dataOffer.reward.rewardType == "Voucher" && codes.isEmpty && cell.offerVendorURLTextView.text != nil {
                
                let code = codes[0]
                let text = cell.offerVendorURLTextView.text!
                cell.offerVendorURLTextView.text = "\(text) \n\(code)!)"
            }
        }
    }
    
    // MARK: - Update progressBar
    
    /**
     Updates the progress bar according to the completion status
     
     - parameter completion: The download completion status
     */
    private func updateProgressBar(completion: Double) {
        
        ringProgressBar.updateCircle(end: CGFloat(completion), animate: 0.2, removePreviousLayer: true)
    }
    
    // MARK: - Download image
    
    /**
     Downloads the offer image
     
     - parameter url: The url to connect to in order to get the image
     - parameter cell: The cell to download the image to
     - parameter completion: A completion handler to execute after the image download has been completed
     */
    private func downloadOfferImage(url: String, cell: ListDataOffersCollectionViewCell, completion: ((UIImage) -> Void)?) {
        
        func showDefaultImage() {
            
            cell.ringProgressBar.isHidden = true
            completion?(cell.offerImageView.image!)
        }
        
        cell.offerImageView.image = UIImage(named: Constants.ImageNames.placeholderImage)
        
        if let unwrappedURL = URL(string: url) {
            
            cell.ringProgressBar.isHidden = false
            cell.offerImageView.downloadedFrom(
                url: unwrappedURL,
                userToken: self.userToken,
                progressUpdater: updateProgressBar,
                completion: showDefaultImage)
        } else {
            
            showDefaultImage()
        }
    }
}
