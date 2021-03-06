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

import UIKit

// MARK: Class

/// The Page view controller child. Shows info about hat and what you can do
internal class HATCapabilitiesViewController: UIViewController {
    
    // MARK: - Variables

    /// a variable to know the page number of the view
    var pageIndex: Int = 0
    
    // MARK: - IBOutlets
    
    /// An IBOutlet to handle the titleLabel
    @IBOutlet private weak var titleLabel: UILabel!
    /// An IBOutlet to handle the infoLabel
    @IBOutlet private weak var infoLabel: UILabel!
    
    /// An IBOutlet to handle the imageView
    @IBOutlet private weak var image: UIImageView!
    
    // MARK: - Autogenerated methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // init the data object and refresh the labels and imageView
        let dataObject = LearnMoreObject(pageNumber: pageIndex + 10)
        self.titleLabel.text = dataObject.title
        self.infoLabel.text = dataObject.info
        self.image.image = dataObject.image
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - IBActions
    
    /**
     Hides the second page view controller
     
     - parameter sender: The object that calls this method
     */
    @IBAction func cancelButton(_ sender: Any) {
        
        NotificationCenter.default.post(name: Notification.Name(Constants.NotificationNames.enablePageControll), object: nil)
        NotificationCenter.default.post(name: Notification.Name(Constants.NotificationNames.hideCapabilitiesPageViewContoller), object: nil)
    }
}
