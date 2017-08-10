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
import SafariServices

// MARK: Class

/// The data plugs View in the tab bar view controller
internal class DataPlugsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UserCredentialsProtocol {
    
    // MARK: - Variables
    
    /// An array with the available data plugs
    private var dataPlugs: [HATDataPlugObject] = []
    
    /// A dark view covering the collection view cell
    private var darkView: UIVisualEffectView?
    
    private var selectedlPlug: String = ""
    private var plugURL: String = ""
    var prefferedTitle: String = "Data Plugs"
    var prefferedInfoMessage: String = "Pull in your data with the HAT data Plugs"

    /// A view to show that app is loading, fetching data plugs
    private var loadingView: UIView = UIView()
    
    /// A reference to safari view controller in order to be able to show or hide it
    private var safariVC: SFSafariViewController?
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var infoPopUpButton: UIButton!
    
    // MARK: - IBActions

    @IBAction func infoPopUp(_ sender: Any) {
        
        self.showInfoViewController(text: prefferedInfoMessage)
        self.infoPopUpButton.isUserInteractionEnabled = false
    }
    
    // MARK: - View controller methods

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = self.prefferedTitle
        
        // add notification observer for response from server
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showAlertForDataPlug),
            name: Notification.Name(Constants.NotificationNames.dataPlug),
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hidePopUp),
            name: NSNotification.Name(Constants.NotificationNames.hideDataServicesInfo),
            object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.dataPlugs.removeAll()
        self.collectionView?.reloadData()
        self.getDataPlugs()
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        
        self.collectionView?.reloadData()
    }
    
    // MARK: - Get Plugs
    
    /**
     Gets available data plugs
     */
    private func getDataPlugs() {
        
        /// method to execute on a successful callback
        func successfullCallBack(data: [HATDataPlugObject], renewedUserToken: String?) {
            
            // remove the existing dataplugs from array
            self.dataPlugs = HATDataPlugsService.filterAvailableDataPlugs(dataPlugs: data)
            
            // check if dataplugs are active
            self.checkDataPlugsIfActive()
            
            // refresh user token
            KeychainHelper.setKeychainValue(key: Constants.Keychain.userToken, value: renewedUserToken)
        }
        
        /// method to execute on a failed callback
        func failureCallBack(error: DataPlugError) {
            
            // remove the loading screen from the view
            self.loadingView.removeFromSuperview()
            CrashLoggerHelper.dataPlugErrorLog(error: error)
        }
        
        // create loading pop up screen
        self.loadingView = UIView.createLoadingView(
            with: CGRect(x: (self.collectionView?.frame.midX)! - 70, y: (self.collectionView?.frame.midY)! - 15, width: 140, height: 30),
            color: .teal,
            cornerRadius: 15,
            in: self.view,
            with: "Getting data plugs...",
            textColor: .white,
            font: UIFont(name: Constants.FontNames.openSans, size: 12)!)
        
        // get available data plugs from server
        HATDataPlugsService.getAvailableDataPlugs(
            succesfulCallBack: successfullCallBack,
            failCallBack: failureCallBack)
        
        self.checkFacebookPlugIfExpired()
    }
    
    // MARK: - Check facebook if expired
    
    /**
     Checks facebook plug if expired and sets up a notification
     */
    private func checkFacebookPlugIfExpired() {
        
        func appTokenReceived(appToken: String, usersToken: String?) {
            
            func setUpNotificationOnExpiry(date: String) {
                
                if let date = HATFormatterHelper.formatStringToDate(string: date) {
                    
                    let notification = UILocalNotification()
                    notification.fireDate = date
                    notification.alertBody = "Facebook Data Plug expired!"
                    notification.alertAction = "Please enable it!"
                    notification.soundName = UILocalNotificationDefaultSoundName
                    UIApplication.shared.scheduleLocalNotification(notification)
                }
            }
            
            HATDataPlugsService.checkSocialPlugExpiry(
                succesfulCallBack: setUpNotificationOnExpiry,
                failCallBack: {(error) -> Void in
                
                    CrashLoggerHelper.dataPlugErrorLog(error: error)
                }
            )(appToken)
        }
        
        HATService.getApplicationTokenFor(
            serviceName: Constants.ApplicationToken.Facebook.name,
            userDomain: self.userDomain,
            token: self.userToken,
            resource: Constants.ApplicationToken.Facebook.source,
            succesfulCallBack: appTokenReceived,
            failCallBack: {error in
            
                CrashLoggerHelper.JSONParsingErrorLog(error: error)
            }
        )
    }
    
    // MARK: - Notification observer method
    
    /**
     Hides safari view controller
     
     - parameter notif: The notification object sent
     */
    @objc
    private func showAlertForDataPlug(notif: Notification) {
        
        // check that safari is not nil, if it's not hide it
        self.safariVC?.dismissSafari(animated: true, completion: nil)
        self.checkFacebookPlugIfExpired()
    }
    
    // MARK: - Check if data plugs are active

    /**
     Checks if both data plugs are active
     */
    private func checkDataPlugsIfActive() {
        
        func setupCheckMark(onDataPlug: String, value: Bool) {
            
            // search in data plugs array for facebook and enable the checkmark
            if !self.dataPlugs.isEmpty {
                
                for i in 0 ... self.dataPlugs.count - 1 where self.dataPlugs[i].name == onDataPlug {
                    
                    self.dataPlugs[i].showCheckMark = value
                    self.collectionView?.reloadData()
                    self.loadingView.removeFromSuperview()
                }
            }
        }
        
        HATDataPlugsService.checkDataPlugsIfActive(completion: setupCheckMark)
    }

    // MARK: - UICollectionView methods

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.dataPlugs.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let orientation = UIInterfaceOrientation(rawValue: UIDevice.current.orientation.rawValue)!

        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellReuseIDs.dataplug, for: indexPath) as? DataPlugCollectionViewCell {
            
            return DataPlugCollectionViewCell.setUp(cell: cell, indexPath: indexPath, dataPlug: self.dataPlugs[indexPath.row], orientation: orientation)
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellReuseIDs.dataplug, for: indexPath)
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            
            selectedlPlug = "facebook"
        } else {
            
            selectedlPlug = "twitter"
        }
        plugURL = HATDataPlugsService.createURLBasedOn(socialServiceName: self.dataPlugs[indexPath.row].name, socialServiceURL: self.dataPlugs[indexPath.row].url)!
        self.performSegue(withIdentifier: "details", sender: self)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let orientation = UIInterfaceOrientation(rawValue: UIDevice.current.orientation.rawValue)!
        
        // in case of landscape show 3 tiles instead of 2
        if orientation == .landscapeLeft || orientation == .landscapeRight {
            
            return CGSize(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3)
        }
        
        return CGSize(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.width / 2)
    }
    
    // MARK: - Remove pop up
    
    /**
     Hides pop up presented currently
     */
    @objc
    private func hidePopUp() {
        
        self.darkView?.removeFromSuperview()
        self.infoPopUpButton.isUserInteractionEnabled = true
    }
    
    // MARK: - Add blur View
    
    /**
     Adds blur to the view before presenting the pop up
     */
    private func addBlurToView() {
        
        self.darkView = AnimationHelper.addBlurToView(self.view)
    }
    
    /**
     Shows the pop up view controller with the info passed on
     
     - parameter text: A String to show in the view controller
     */
    private func showInfoViewController(text: String) {
        
        // set up page controller
        let textPopUpViewController = TextPopUpViewController.customInit(
            stringToShow: text,
            isButtonHidden: true,
            from: self.storyboard!)
        
        self.tabBarController?.tabBar.isUserInteractionEnabled = false
        
        textPopUpViewController?.view.createFloatingView(
            frame: CGRect(
                x: self.view.frame.origin.x + 15,
                y: (self.collectionView?.frame.maxY)!,
                width: self.view.frame.width - 30,
                height: self.view.frame.height),
            color: .teal,
            cornerRadius: 15)
        
        DispatchQueue.main.async { [weak self] () -> Void in
            
            if let weakSelf = self {
                
                // add the page view controller to self
                weakSelf.addBlurToView()
                weakSelf.addViewController(textPopUpViewController!)
                AnimationHelper.animateView(
                    textPopUpViewController?.view,
                    duration: 0.2,
                    animations: {() -> Void in
                        
                        textPopUpViewController?.view.frame = CGRect(
                            x: weakSelf.view.frame.origin.x + 15,
                            y: (weakSelf.collectionView?.frame.maxY)! - 150,
                            width: weakSelf.view.frame.width - 30,
                            height: 200)
                },
                    completion: { _ in return }
                )
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "details" {
            
            let vc = segue.destination as? DetailsDataPlugViewController
            vc?.plug = self.selectedlPlug
            vc?.plugURL = self.plugURL
        }
    }
    
}
