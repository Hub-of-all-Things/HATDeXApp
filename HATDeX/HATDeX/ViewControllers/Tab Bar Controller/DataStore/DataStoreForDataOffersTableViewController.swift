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
import SwiftyJSON

// MARK: Class

/// A class responsible for the profile name, in dataStore ViewController
internal class DataStoreForDataOffersTableViewController: UITableViewController, UserCredentialsProtocol {
    
    // MARK: - Variables
    
    /// The sections of the table view
    private let sections: [[String]] = [["Education"], ["Info"], ["Locale"], ["Employment Status"], ["Living Info"], ["My Priorities"], ["My Interests"]]
    /// The headers of the table view
    private var headers: [String] = ["Complete your profile and preferences to unlock more exclusive and personalised offers for your data (Coming Soon) ", "", "", "", "", "", ""]
    
    /// The preffered title of the view controller
    var prefferedTitle: String = "For Data Offers"
    /// The preffered info pop up message
    var prefferedInfoMessage: String = "Fill up your preference profile so that it can be matched with products and services out there"
    
    /// A dark view covering the collection view cell
    private var darkView: UIVisualEffectView?
    
    private var profile: ProfileObject?
    
    private var loadingView: UIView?
    
    // MARK: - IBOutlets
    
    /// An IBOutlet for handling the info pop up UIButton
    @IBOutlet private weak var infoPopUpButton: UIButton!
    
    // MARK: - IBActions
    
    /**
     It slides the pop up view controller from the bottom of the screen
     
     - parameter sender: The object that calls this method
     */
    @IBAction func infoPopUp(_ sender: Any) {
        
        DispatchQueue.main.async { [weak self] in
            
            guard let weakSelf = self else {
                
                return
            }
            weakSelf.showInfoViewController(text: weakSelf.prefferedInfoMessage)
            weakSelf.infoPopUpButton.isUserInteractionEnabled = false
        }
    }
    
    // MARK: - Remove pop up
    
    /**
     Hides pop up presented currently
     */
    @objc
    private func hidePopUp() {
        
        DispatchQueue.main.async { [weak self] in
            
            self?.darkView?.removeFromSuperview()
            self?.infoPopUpButton.isUserInteractionEnabled = true
        }
    }
    
    // MARK: - Add blur View
    
    /**
     Adds blur to the view before presenting the pop up
     */
    private func addBlurToView() {
        
        DispatchQueue.main.async { [weak self] in
            
            guard let weakSelf = self else {
                
                return
            }
            weakSelf.darkView = AnimationHelper.addBlurToView(weakSelf.view)
        }
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
                y: self.tableView.frame.maxY,
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
                            y: weakSelf.tableView.frame.maxY - 250,
                            width: weakSelf.view.frame.width - 30,
                            height: 300)
                    },
                    completion: { _ in return }
                )
            }
        }
    }
    
    // MARK: - View Controller methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = self.prefferedTitle
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hidePopUp),
            name: NSNotification.Name(Constants.NotificationNames.hideDataServicesInfo),
            object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.getCompleteness()
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sections[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.forDataOffersCell, for: indexPath)
            
        return setUpCell(cell: cell, indexPath: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            self.performSegue(withIdentifier: Constants.Segue.dataStoreToEducationSegue, sender: self)
        } else if indexPath.section == 1 {
            
            self.performSegue(withIdentifier: Constants.Segue.dataStoreToInfoSegue, sender: self)
        } else if indexPath.section == 2 {
            
            self.performSegue(withIdentifier: Constants.Segue.forDataOffersToLocaleSegue, sender: self)
        } else if indexPath.section == 3 {
            
            self.performSegue(withIdentifier: Constants.Segue.dataStoreToEmploymentStatusSegue, sender: self)
        } else if indexPath.section == 4 {
            
            self.performSegue(withIdentifier: Constants.Segue.dataStoreToHouseholdSegue, sender: self)
        } else if indexPath.section == 5 {
            
            self.performSegue(withIdentifier: Constants.Segue.prioritiesSegue, sender: self)
        } else if indexPath.section == 6 {
            
            self.performSegue(withIdentifier: Constants.Segue.interestsSegue, sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section < self.headers.count {
            
            return self.headers[section]
        }
        
        return nil
    }
    
    // MARK: - Update cell
    
    /**
     Sets up the cell accordingly
     
     - parameter cell: The cell to set up
     - parameter indexPath: The index path of the cell
     
     - returns: The set up cell
     */
    func setUpCell(cell: UITableViewCell, indexPath: IndexPath) -> UITableViewCell {
        
        cell.textLabel?.text = self.sections[indexPath.section][indexPath.row]
        
        return cell
    }
    
    // MARK: - Get profile completeness
    
    /**
     Get's the profile completeness stat
     */
    func getCompleteness() {
        
        var count: Int = 0
        var totalQuestions = 0
        
        func success(dataBundleCreated: Bool) {
            
            func profileReceived(profile: [ProfileObject], newToken: String?) {
                
                func countCompletness(matchMe: [MatchMeObject], newFakeToken: String?) {
                    
                    DispatchQueue.main.async { [weak self] in
                        
                        guard let weakSelf = self else {
                            
                            return
                        }
                        
                        weakSelf.tableView.isUserInteractionEnabled = true
                        weakSelf.loadingView?.removeFromSuperview()
                        
                        if profile[0].profile.data.address.city != "" {
                            
                            count += 1
                        }
                        
                        if profile[0].profile.data.address.county != "" {
                            
                            count += 1
                        }
                        
                        if profile[0].profile.data.address.country != "" {
                            
                            count += 1
                        }
                        
                        // 3 fields of profile above
                        totalQuestions += 3
                        
                        if !matchMe.isEmpty {
                            
                            for (key, value) in JSON(matchMe[0].dictionary) {
                                
                                if key == "interests" && !value.arrayValue.isEmpty {
                                    
                                    if let array = value.arrayValue[0].dictionaryValue["data"]?.dictionaryValue {
                                        
                                        var countAdded: Bool = false
                                        var countPossibleAnswers: Int = 0
                                        
                                        for interest in array where interest.key != "unixTimeStamp" {
                                            
                                            totalQuestions += 1
                                            countPossibleAnswers += 1
                                            
                                            if interest.value == 1  && !countAdded {
                                                
                                                countAdded = true
                                            }
                                        }
                                        
                                        if countAdded {
                                            
                                            count += countPossibleAnswers
                                        }
                                        
                                    }
                                } else if key == "interests" && !value.dictionaryValue.isEmpty {
                                    
                                    if let array = value.dictionaryValue["values"]?.dictionaryValue {
                                        
                                        var countAdded: Bool = false
                                        var countPossibleAnswers: Int = 0
                                        
                                        for interest in array where interest.key != "unixTimeStamp" {
                                            
                                            totalQuestions += 1
                                            countPossibleAnswers += 1
                                            
                                            if interest.value == 1  && !countAdded {
                                                
                                                countAdded = true
                                            }
                                        }
                                        
                                        if countAdded {
                                            
                                            count += countPossibleAnswers
                                        }
                                        
                                    }
                                } else if (key == "education" || key == "livingInfo" || key == "profileInfo" || key == "employmentStatus") && !value.arrayValue.isEmpty {
                                    
                                    if let dict = value.arrayValue[0].dictionaryValue["data"]?.dictionaryValue {
                                        
                                        for question in dict where question.key != "unixTimeStamp" && question.key != "numberOfDecendants" {
                                            
                                            totalQuestions += 1
                                            if question.value.stringValue != "" {
                                                
                                                count += 1
                                            }
                                        }
                                    }
                                } else if !value.arrayValue.isEmpty {
                                    
                                    if let array = value.arrayValue[0].dictionaryValue["data"]?.dictionaryValue["array"]?.arrayValue {
                                        
                                        for item in array {
                                            
                                            totalQuestions += 1
                                            if item.dictionaryValue["interest"]?.intValue != 0 {
                                                
                                                count += 1
                                            }
                                        }
                                    } else if let array = value.array {
                                        
                                        for item in array {
                                            
                                            totalQuestions += 1
                                            if item.dictionaryValue["interest"]?.intValue != 0 {
                                                
                                                count += 1
                                            }
                                        }
                                    }
                                } else if (key == "education" || key == "livingInfo" || key == "profileInfo" || key == "employmentStatus") && !value.dictionaryValue.isEmpty {
                                    
                                    if let dict = value.dictionary {
                                        
                                        for question in dict where question.key != "unixTimeStamp" && question.key != "numberOfDecendants" {
                                            
                                            totalQuestions += 1
                                            if question.value.stringValue != "" {
                                                
                                                count += 1
                                            }
                                        }
                                    }
                                } else if !value.dictionaryValue.isEmpty {
                                    
                                    if let array = value.dictionary {
                                        
                                        for item in array {
                                            
                                            totalQuestions += 1
                                            if item.key == "interest" && item.value.intValue != 0 {
                                                
                                                count += 1
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        if !weakSelf.headers.isEmpty {
                            
                            print(totalQuestions)
                            if count > 67 {
                                
                                count = 67
                            }
                            let percent: Double = Double(Double(count) / Double(67))
                            let stringPercentage: String = String(format: "%.2f", percent * 100)
                            
                            weakSelf.headers[0] = "Complete your profile and preferences to unlock more exclusive and personalised offers for your data (Coming Soon).\n\nCompletion level: \(stringPercentage)%, \(count)/67"
                            weakSelf.tableView.reloadData()
                        }
                    }
                    
                }
                
                if dataBundleCreated {
                    
                    MatchMeCachingWrapperHelper.getMatchMeObject(
                        userToken: userToken,
                        userDomain: userDomain,
                        cacheTypeID: "matchMe",
                        successRespond: countCompletness,
                        failRespond: failed)
                }
                
                self.profile = profile[0]
            }
            
            ProfileCachingHelper.getProfile(
                userToken: userToken,
                userDomain: userDomain,
                cacheTypeID: "profile",
                successRespond: profileReceived,
                failRespond: failed)
        }
        
        func failed(error: HATTableError) {
            
            DispatchQueue.main.async { [weak self] in
                
                guard let weakSelf = self else {
                    
                    return
                }
                weakSelf.tableView.isUserInteractionEnabled = true
                weakSelf.loadingView?.removeFromSuperview()
                
                weakSelf.headers[0] = "Couldn't calculate your completion score. Connect to the internet and try again"
                weakSelf.tableView.reloadData()
                
                CrashLoggerHelper.hatTableErrorLog(error: error)
            }
        }
        
        func failedMatchMe(error: HATTableError) {
            
            DispatchQueue.main.async { [weak self] in
                
                guard let weakSelf = self else {
                    
                    return
                }
                
                switch error {
                case .noInternetConnection:
                    
                    success(dataBundleCreated: true)
                default:
                    
                    weakSelf.tableView.isUserInteractionEnabled = true
                    weakSelf.loadingView?.removeFromSuperview()
                    
                    CrashLoggerHelper.hatTableErrorLog(error: error)
                }
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            
            self?.tableView.isUserInteractionEnabled = false
            guard let midX = self?.tableView?.frame.midX,
                let midY = self?.tableView?.frame.midY,
                let font = UIFont(name: Constants.FontNames.openSans, size: 12),
                let weakSelf = self else {
                    
                    return
            }
            
            weakSelf.loadingView?.removeFromSuperview()
            weakSelf.loadingView = UIView.createLoadingView(
                with: CGRect(x: midX - 70, y: midY - 15, width: 160, height: 30),
                color: .teal,
                cornerRadius: 15,
                in: weakSelf.view,
                with: "Loading HAT data...",
                textColor: .white,
                font: font)
            
            HATAccountService.createMatchMeCompletion(
                success: success,
                fail: failedMatchMe)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Constants.Segue.forDataOffersToLocaleSegue {
            
            if let vc = segue.destination as? AddressTableViewController {
                
                vc.profile = self.profile
                vc.isSwitchHidden = true
            }
        }
    }
    
}
