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

/// A class responsible for the more tab in the tab bar controller
internal class MoreTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UserCredentialsProtocol {
    
    // MARK: - Variables
    
    /// The sections of the table view
    private let sections: [[String]] = [["Data Debits"], ["Past Notifications"], ["Storage Info", "Change Password", "Open HAT App"], ["Show Data", "Location Settings"], [/*"Release Notes",*/ "Privacy policy", "HAT Terms of Service"], ["Report Problem"], ["Clear Cache"], ["Log Out", "Version"]]
    /// The headers of the table view
    private let headers: [String] = ["Data Debits", "Notifications", "HAT", "Location", "About", "", "", ""]
    private let footers: [String] = ["", "", "", "", "", "HATs are distributed systems and being private also means no one will know if you have a problem. If you have an issue with your HAT or this dashboard, please report it here", "", ""]
    
    /// The file url, used to show the pdf file for terms of service
    private var fileURL: String?
    
    /// A mail ViewController helper
    private let mailVC: MailHelper = MailHelper()
    
    // MARK: - IBOutlets

    /// An IBOutlet for handling the table view
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - View controller methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationController?.navigationBar.isOpaque = true
        self.navigationController?.navigationBar.isTranslucent = true
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view methods

    func numberOfSections(in tableView: UITableView) -> Int {
        
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sections[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.optionsCell, for: indexPath)

        return setUpCell(cell: cell, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                
                self.performSegue(withIdentifier: "dataStoreToDataDebitsSegue", sender: self)
            }
        } else if indexPath.section == 1 {
            
            if indexPath.row == 0 {
                
                self.performSegue(withIdentifier: Constants.Segue.notificationsSegue, sender: self)
            }
        } else if indexPath.section == 2 {
            
            if indexPath.row == 1 {
                
                self.performSegue(withIdentifier: Constants.Segue.moreToResetPasswordSegue, sender: self)
            } else if indexPath.row == 2 {
                
                guard let url = URL(string: "hatapp://") else {
                    
                    return
                }
                
                if UIApplication.shared.canOpenURL(url) {
                    
                    UIApplication.shared.openURL(url)
                } else {
                    
                    if let url: URL = URL(string: "https://itunes.apple.com/us/app/hat-app/id1303181222?l=el&ls=1&mt=8"),
                        UIApplication.shared.canOpenURL(url) {
                        
                        UIApplication.shared.openURL(url)
                    }
                }
            }
        } else if indexPath.section == 3 {
            
            if self.sections[indexPath.section][indexPath.row] == "Show Data" {
                
                self.performSegue(withIdentifier: Constants.Segue.dataSegue, sender: self)
            } else if self.sections[indexPath.section][indexPath.row] == "Location Settings" {
                
                self.performSegue(withIdentifier: Constants.Segue.locationsSettingsSegue, sender: self)
            }
        } else if indexPath.section == 4 {
            
            if self.sections[indexPath.section][indexPath.row] == "Privacy policy" {
                
                self.fileURL = Constants.TermsURL.privacyPolicy
                self.performSegue(withIdentifier: Constants.Segue.moreToTermsSegue, sender: self)
            } else if self.sections[indexPath.section][indexPath.row] == "HAT Terms of Service" {
                
                self.fileURL = Constants.TermsURL.termsAndConditions
                self.performSegue(withIdentifier: Constants.Segue.moreToTermsSegue, sender: self)
            }
        } else if indexPath.section == 5 {
            
            if self.sections[indexPath.section][indexPath.row] == "Report Problem" {
                
                self.mailVC.sendEmail(atAddress: "contact@hatdex.org", onBehalf: self)
            } else if self.sections[indexPath.section][indexPath.row] == "Log Out" {
                
                TabBarViewController.logoutUser(from: self)
            }
        } else if indexPath.section == 6 {
            
            if self.sections[indexPath.section][indexPath.row] == "Clear Cache" {
                
                let cacheSize = CachingHelper.getTotalCacheSize()
                
                if cacheSize > 0 {
                    
                    let newSize = cacheSize / 1024 / 1024
                    self.createClassicAlertWith(
                        alertMessage: "By clearing cache you will free up \(String(newSize)) MB",
                        alertTitle: "Do you want to clear cache?",
                        cancelTitle: "Cancel",
                        proceedTitle: "Clear",
                        proceedCompletion: { CachingHelper.deleteCache() },
                        cancelCompletion: {})
                }
            }
        } else if indexPath.section == 7 {
            
            if self.sections[indexPath.section][indexPath.row] == "Log Out" {
                
                TabBarViewController.logoutUser(from: self)
            }
        }
        
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section < self.headers.count {
            
            return self.headers[section]
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        if section < self.footers.count {
            
            return self.footers[section]
        }
        
        return nil
    }
    
    // MARK: - Update cell
    
    /**
     Sets up the cell based on indexPath
     
     - parameter cell: The UITableViewCell to set up
     - parameter indexPath: the indexPath of the cell

     - returns: A set up UITableViewCell
     */
    func setUpCell(cell: UITableViewCell, indexPath: IndexPath) -> UITableViewCell {
        
        cell.textLabel?.text = self.sections[indexPath.section][indexPath.row]

        if indexPath.section == 0 || indexPath.section == 1 {
            
            cell.accessoryType = .disclosureIndicator
            
            cell.textLabel?.textColor = .black
            cell.isUserInteractionEnabled = true
        } else if indexPath.section == 2 {
            
            cell.textLabel?.textColor = .black
            
            cell.accessoryType = .none
            
            cell.isUserInteractionEnabled = true
            
            if self.sections[indexPath.section][indexPath.row] == "Storage Info" {
                
                cell.textLabel?.textColor = .lightGray
                cell.isUserInteractionEnabled = false
                cell.textLabel?.text = "Getting storage info..."
                
                HATService.getSystemStatus(
                    userDomain: userDomain,
                    userToken: userToken,
                    completion: self.updateSystemStatusLabel(cell: cell),
                    failCallBack: {error in
                    
                        cell.textLabel?.text = "Unable to get storage info"
                        CrashLoggerHelper.JSONParsingErrorLogWithoutAlert(error: error)
                    }
                )
            } else if self.sections[indexPath.section][indexPath.row] == "Change Password" {
                
                cell.accessoryType = .disclosureIndicator
            }
        } else if indexPath.section == 3 {
            
            cell.textLabel?.textColor = .black
            
            cell.accessoryType = .disclosureIndicator
            
            cell.isUserInteractionEnabled = true
        } else if indexPath.section == 4 {
            
            cell.textLabel?.textColor = .black
            
            cell.accessoryType = .disclosureIndicator
            
            cell.isUserInteractionEnabled = true
        } else if indexPath.section == 5 {
            
            cell.accessoryType = .none
            cell.isUserInteractionEnabled = true
            
            if self.sections[indexPath.section][indexPath.row] == "Report Problem" {
                
                cell.textLabel?.textColor = .teal
            }
        } else if indexPath.section == 6 {
            
            cell.accessoryType = .none
            cell.isUserInteractionEnabled = true
            cell.textLabel?.textColor = .black
        } else if indexPath.section == 7 {
            
            cell.accessoryType = .none
            
            if self.sections[indexPath.section][indexPath.row] == "Log Out" {
                
                cell.textLabel?.textColor = .red
                cell.isUserInteractionEnabled = true
            } else if self.sections[indexPath.section][indexPath.row] == "Version" {
                
                cell.textLabel?.textColor = .lightGray
                cell.isUserInteractionEnabled = false
                
                // app version
                if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                    
                    cell.textLabel?.text = "Version " + version
                }
            }
        }
        
        return cell
    }
    
    // MARK: - Update system status
    
    /**
     Updates the stats for the hat
     
     - parameter cell: The UITableViewCell to update
     
     - returns: A tuple with the HATSystemStatusObject and the renewed token
     */
    func updateSystemStatusLabel(cell: UITableViewCell) -> (([HATSystemStatusObject], String?) -> Void) {
        
        return { (systemStatusFile, renewedUserToken) in
        
            if !systemStatusFile.isEmpty {
                
                let totalSpaceAvailable = systemStatusFile[2].kind.metric + " " + systemStatusFile[2].kind.units!
                let usedSpace = String(describing: Int(Float(systemStatusFile[4].kind.metric)!)) + " " + systemStatusFile[4].kind.units!
                let freeSpace = (Float(systemStatusFile[2].kind.metric)! * 1024) - Float(systemStatusFile[4].kind.metric)!.rounded()
                
                if freeSpace < 1024 {
                    
                    cell.textLabel?.text = "\(usedSpace) / \(totalSpaceAvailable) (\(Int(freeSpace)) MB available)"
                } else {
                    
                    let formattedFreeSpace = floor((freeSpace / 1024) / 0.01) * 0.01
                    cell.textLabel?.text = "\(usedSpace) / \(totalSpaceAvailable) (\(formattedFreeSpace) GB available)"
                }
            }
            
            // refresh user token
            KeychainHelper.setKeychainValue(key: Constants.Keychain.userToken, value: renewedUserToken)
        }
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Constants.Segue.moreToTermsSegue && self.fileURL != nil {
            
            // pass data to next view
            if let termsVC = segue.destination as? TermsAndConditionsViewController {
                
                termsVC.url = self.fileURL!
            }
        }
    }
    
}
