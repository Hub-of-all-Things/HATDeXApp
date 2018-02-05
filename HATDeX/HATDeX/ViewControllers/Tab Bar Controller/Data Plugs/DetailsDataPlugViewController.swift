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
import SwiftyJSON

// MARK: Class

internal class DetailsDataPlugViewController: UIViewController, UserCredentialsProtocol, UITableViewDataSource {
    
    // MARK: - Model
    
    /// A struct to hold the name and the value of the plug
    private struct PlugDetails {
        
        var name: String = ""
        var value: String = ""
    }
    
    // MARK: - Variables

    /// The plug name, passed on from previous view controller
    var plug: String = ""
    /// The plug url, passed on from previous view controller
    var plugURL: String = ""
    
    /// The safari view controller reference
    private var safariVC: SFSafariViewController?
    
    /// The plug details
    private var plugDetailsArray: [[PlugDetails]] = []
    
    /// Table view sections
    private var sections: [String] = []
    
    private var skipParameter: Int = 0
    
    // MARK: - IBOutlets
    
    /// An IBOutlet fon handling the tableView UITableView
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var showFeedButton: UIButton!
    
    // MARK: - IBActions
    
    /**
     Connects the plug
     
     - parameter sender: The object that calls this method
     */
    @IBAction func connectPlug(_ sender: Any) {
        
        self.safariVC = SFSafariViewController.openInSafari(url: plugURL, on: self, animated: true, completion: nil)
    }
    
    /**
     View data plug details
     
     - parameter sender: The object that calls this method
     */
    @IBAction func viewDataPlugData(_ sender: Any) {
        
        if plug == "Fitbit" {
            
            self.performSegue(withIdentifier: "fitbitFeedSegue", sender: self)
        } else {
            
            self.performSegue(withIdentifier: Constants.Segue.detailsToSocialFeed, sender: self)
        }
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
    }
    
    @objc
    private func dismissSafari() {
        
        self.safariVC?.dismissSafari(animated: true, completion: nil)
    }
    
    // MARK: - Auto-generated methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showAlertForDataPlug),
            name: Notification.Name(Constants.NotificationNames.dataPlug),
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(dismissSafari),
            name: Notification.Name(Constants.NotificationNames.dismissSafari),
            object: nil)
        
        if plug == "facebook" {
            
            self.loadFacebookInfo()
        } else if plug == "twitter" {
            
            self.loadTwitterInfo()
        } else if plug == "Fitbit" {
            
            self.loadFitbitInfo()
        }
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table View methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return plugDetailsArray[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.plugDetailsCell, for: indexPath) as? DataPlugDetailsTableViewCell
        
        if indexPath.row % 2 == 0 {
            
            cell?.backgroundColor = .groupTableViewBackground
        } else {
            
            cell?.backgroundColor = .white
        }
        cell?.setTitleToLabel(title: self.plugDetailsArray[indexPath.section][indexPath.row].name)
        cell?.setDetailsToLabel(details: self.plugDetailsArray[indexPath.section][indexPath.row].value)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return self.sections[section]
    }
    
    // MARK: - Facebook Info
    
    /**
     Get facebook info
     */
    func loadFacebookInfo() {
        
        func gotProfile(profile: [JSON], renewedToken: String?) {
            
            if !profile.isEmpty {
                
                if let profile = profile[0].dictionaryValue["data"]?.dictionaryValue {
                    
                    self.sections.append("Facebook")
                    
                    var arrayToAdd: [PlugDetails] = []
                    
                    for (key, value) in profile {
                        
                        var object = PlugDetails()
                        object.name = key.replacingOccurrences(of: "_", with: " ")
                        object.value = value.stringValue
                        
                        if key == "updated_time" {
                            
                            if let date = HATFormatterHelper.formatStringToDate(string: value.stringValue) {
                                
                                object.value = FormatterHelper.formatDateStringToUsersDefinedDate(
                                    date: date,
                                    dateStyle: .short,
                                    timeStyle: .short)
                            }
                        }
                        
                        arrayToAdd.append(object)
                    }
                    
                    self.plugDetailsArray.append(arrayToAdd)
                    
                    self.tableView.reloadData()
                }
            }
        }
        
        HATAccountService.getHatTableValues(
            token: userToken,
            userDomain: userDomain,
            namespace: "facebook",
            scope: "profile",
            parameters: ["orderBy": "lastUpdated",
                         "ordering": "descending"],
            successCallback: gotProfile,
            errorCallback: { error in
                
                print(error)
        })
    }
    
    // MARK: - Twitter Info
    
    /**
     Get twitter info
     */
    func loadTwitterInfo() {
        
        func gotTweets(tweets: [JSON], newToken: String?) {
            
            guard !tweets.isEmpty else {
                
                return
            }
            let user = tweets[0].dictionaryValue["data"]?["user"]
            self.sections.append("Twitter")
            
            var arrayToAdd: [PlugDetails] = []
            
            for (key, value) in (user?.dictionaryValue)! {
                
                var object = PlugDetails()
                object.name = key.replacingOccurrences(of: "_", with: " ")
                object.value = value.stringValue
                
                arrayToAdd.append(object)
            }
            
            self.plugDetailsArray.append(arrayToAdd)
            
            self.tableView.reloadData()
        }
        
        HATAccountService.getHatTableValues(
            token: userToken,
            userDomain: userDomain,
            namespace: Constants.SocialNetworks.Twitter.name,
            scope: Constants.SocialNetworks.Twitter.tableName,
            parameters: ["take": "1",
                         "orderBy": "id",
                         "ordering": "descending"],
            successCallback: gotTweets,
            errorCallback: { error in
                
                print(error)
            }
        )
    }
    
    // MARK: - Fitbit Info
    
    /**
     Get fitbit info
     */
    func loadFitbitInfo() {
        
        func gotAllFitBitData(profile: [HATFitbitProfileObject], newToken: String?) {
            
            if !profile.isEmpty {
                
                self.parseFitbitData(profile: profile[0])
            }
        }
        
        HATFitbitService.getProfile(
            userDomain: userDomain,
            userToken: userToken,
            parameters: ["take": "1", "orderBy": "dateCreated", "ordering": "descending"],
            successCallback: gotAllFitBitData,
            errorCallback: tableNotFound)
    }
    
    // MARK: - Parse fitbit
    
    private func parseFitbitData(profile: HATFitbitProfileObject) {
        
        var arrayToAdd: [PlugDetails] = []
        var object = PlugDetails()
        
        object.name = "First name"
        object.value = profile.firstName
        arrayToAdd.append(object)
        
        object.name = "Last name"
        object.value = profile.lastName
        arrayToAdd.append(object)
        
        object.name = "Timezone"
        object.value = profile.timezone
        arrayToAdd.append(object)
        
        object.name = "Distance unit"
        if profile.distanceUnit == "METRIC" {
            
            object.value = "Km"
        } else {
            
            object.value = "Miles"
        }
        arrayToAdd.append(object)
        
        object.name = "Date of Birth"
        object.value = profile.dateOfBirth
        arrayToAdd.append(object)
        
        object.name = "Weight"
        if profile.weightUnit == "METRIC" {
            
            object.value = "\(String(describing: profile.weight)) Kg"
        } else {
            
         object.value = "\(String(describing: profile.weight)) lbs"
        }
        arrayToAdd.append(object)
        
        object.name = "Height"
        if profile.heightUnit == "METRIC" {
            
            object.value = "\(String(describing: profile.height)) cm"
        } else {
            
            object.value = "\(String(describing: profile.weight)) ft"
        }
        arrayToAdd.append(object)
        
        object.name = "Member since"
        object.value = profile.memberSince
        arrayToAdd.append(object)
        
        object.name = "Locale"
        object.value = profile.locale
        arrayToAdd.append(object)
        
        object.name = "Gender"
        object.value = profile.gender
        arrayToAdd.append(object)
        
        self.sections.append("Static Data")
        self.plugDetailsArray.append(arrayToAdd)

        DispatchQueue.main.async {
            
            self.tableView.reloadData()
        }
    }
    
    /**
     HAT returned an error while trying to retrieve the data
     
     - parameter error: The HATTableError returned from the HAT
     */
    func tableNotFound(error: HATTableError) {
        
        CrashLoggerHelper.hatTableErrorLog(error: error)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Constants.Segue.detailsToSocialFeed {
        
            if let vc = segue.destination as? SocialFeedViewController {
                
                if plug == "facebook" {
                    
                    vc.filterBy = "Facebook"
                    vc.prefferedTitle = "Facebook Plug"
                } else {
                    
                    vc.filterBy = "Twitter"
                    vc.prefferedTitle = "Twitter Plug"
                }
                
                vc.isFilteringHidden = true
                vc.showNotesButton = false
            }
        }
    }

}
