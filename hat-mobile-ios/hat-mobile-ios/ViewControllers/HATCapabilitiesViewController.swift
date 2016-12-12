//
//  HATCapabilitiesViewController.swift
//  hat-mobile-ios
//
//  Created by Marios-Andreas Tsekis on 9/12/16.
//  Copyright © 2016 Green Custard Ltd. All rights reserved.
//

import UIKit

// MARK: Class

/// The Page view controller child. Shows info about hat and what you can do
class HATCapabilitiesViewController: UIViewController {
    
    // MARK: - Variables

    /// a variable to know the page number of the view
    var pageIndex: Int = 0
    
    // MARK: - IBOutlets
    
    /// An IBOutlet to handle the titleLabel
    @IBOutlet weak var titleLabel: UILabel!
    /// An IBOutlet to handle the imageView
    @IBOutlet weak var image: UIImageView!
    /// An IBOutlet to handle the infoLabel
    @IBOutlet weak var infoLabel: UILabel!
    
    // MARK: - Autogenerated methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // init the data object and refresh the labels and imageView
        let dataObject = LearnMoreObject(pageNumber: pageIndex + 10)
        titleLabel.text = dataObject.title
        infoLabel.text = dataObject.info
        image.image = dataObject.image
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBActions
    
    /**
     Hides the second page view controller
     
     - parameter sender: The object that calls this method
     */
    @IBAction func cancelButton(_ sender: Any) {
        
        NotificationCenter.default.post(name: Notification.Name("enablePageControll"), object: nil)
        NotificationCenter.default.post(name: Notification.Name("hidePageViewContoller"), object: nil)
    }
}
