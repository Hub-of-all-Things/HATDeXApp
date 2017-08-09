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

internal class DataDebitsTableViewController: UITableViewController, UserCredentialsProtocol {
    
    // MARK: - Variables
    
    private var dataDebits: [DataDebitObject] = []
    
    // MARK: - Auto generated methods

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.getDataDebits()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.dataDebits.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "dataDebitCell", for: indexPath) as? DataDebitTableViewCell

        return cell!.setUpCell(cell: cell!, dataDebit: dataDebits[indexPath.row])
    }
    
    // MARK: - Get data debits
    
    private func getDataDebits() {
        
        func gotDataDebits(dataDebitsArray: [DataDebitObject], newToken: String?) {
            
            self.dataDebits = dataDebitsArray
            self.tableView.reloadData()
        }
        
        func failedGettingDataDebits(error: DataPlugError) {
            
            CrashLoggerHelper.dataPlugErrorLog(error: error)
        }
        
        HATDataDebitsService.getAvailableDataDebits(
            userToken: userToken,
            userDomain: userDomain,
            succesfulCallBack: gotDataDebits,
            failCallBack: failedGettingDataDebits)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}