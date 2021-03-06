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

internal class PHATASettingsTableViewController: UITableViewController, UserCredentialsProtocol {

    // MARK: - Variables
    
    /// The sections of the table view
    private let sections: [[String]] = [["", "Enable your public profile page?"]]
    /// The headers of the table view
    private let headers: [String] = ["View Settings"]
    /// The loading view pop up
    private var loadingView: UIView = UIView()
    /// A dark view covering the collection view cell
    private var darkView: UIView = UIView()
    
    /// User's profile passed on from previous view controller
    var profile: ProfileObject?
    
    // MARK: - IBActions
    
    /**
     Sends the profile data to hat
     
     - parameter sender: The object that calls this function
     */
    @IBAction func saveButtonAction(_ sender: Any) {
        
        self.darkView = UIView(frame: self.view.frame)
        self.darkView.backgroundColor = .black
        self.darkView.alpha = 0.4
        
        self.view.addSubview(self.darkView)
        
        self.loadingView = UIView.createLoadingView(
            with: CGRect(x: (self.view?.frame.midX)! - 70, y: (self.view?.frame.midY)! - 15, width: 140, height: 30),
            color: .teal,
            cornerRadius: 15,
            in: self.view,
            with: "Updating profile...",
            textColor: .white,
            font: UIFont(name: Constants.FontNames.openSans, size: 12)!)
        
        var cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? PhataTableViewCell
        
        if cell == nil {
            
            let indexPath = IndexPath(row: 1, section: 0)
            cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.phataSettingsCell, for: indexPath) as? PhataTableViewCell
            cell = self.setUpCell(cell: cell!, indexPath: indexPath) as? PhataTableViewCell
        }
        
        profile?.profile.data.shared = (cell!.getSwitchValue())
        if (profile?.profile.data.shared)! && cell!.getSwitchValue() {
            
            profile?.profile.data.shared = false
        }
        if !(cell!.getSwitchValue()) {
            
            self.profile?.shareOptions = [:]
        }
        
        ProfileCachingHelper.postProfile(
            profile: self.profile!,
            userToken: userToken,
            userDomain: userDomain,
            successCallback: { [weak self] in
                
                self?.loadingView.removeFromSuperview()
                self?.darkView.removeFromSuperview()
                
                self?.navigationController?.popViewController(animated: true)
            },
            errorCallback: { [weak self] error in
                
                self?.loadingView.removeFromSuperview()
                self?.darkView.removeFromSuperview()
                
                self?.createClassicOKAlertWith(
                    alertMessage: "There was an error posting profile",
                    alertTitle: "Error",
                    okTitle: "OK",
                    proceedCompletion: {})
                CrashLoggerHelper.hatTableErrorLog(error: error)
            }
        )
    }
    
    // MARK: - View Contoller functions
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if self.profile == nil {
            
            self.profile = ProfileObject()
        }
        
        self.tableView.addBackgroundTapRecogniser()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.sections[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.phataSettingsCell, for: indexPath) as? PhataTableViewCell {
            
            return self.setUpCell(cell: cell, indexPath: indexPath)
        }
        
        return tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.phataSettingsCell, for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return self.headers[section]
    }
    
    // MARK: - Set up cell
    
    /**
     Updates and formats the cell accordingly
     
     - parameter cell: The PhataTableViewCell to update and format
     - parameter indexPath: The indexPath of the cell
     
     - returns: A UITableViewCell cell already updated and formatted accordingly
     */
    private func setUpCell(cell: PhataTableViewCell, indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            cell.enableLink(string: "https://\(self.userDomain)")
            cell.isSwitchHidden(true)
        } else if indexPath.row == 1 {
            
            cell.setTextToTextField(text: self.sections[indexPath.section][indexPath.row])
            cell.setSwitchValue(isOn: self.profile!.profile.data.shared)
            cell.isUserInteractionEnabled = true
            cell.setTextColorInTextField(color: .black)
            cell.isSwitchHidden(false)
        }
        
        return cell
    }

}
