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

import FBAnnotationClusteringSwift
import HatForIOS
import MapKit
import SwiftyJSON

// MARK: Class

/// The MapView to render the DataPoints
internal class MapViewController: UIViewController, MKMapViewDelegate, MapSettingsDelegate, UserCredentialsProtocol {

    // MARK: - IBOutlets
    
    /// An IBOutlet for handling the mapView MKMapView
    @IBOutlet private weak var mapView: MKMapView!
    
    /// An IBOutlet for handling the buttonYesterday UIButton
    @IBOutlet private weak var buttonYesterday: UIButton!
    /// An IBOutlet for handling the buttonToday UIButton
    @IBOutlet private weak var buttonToday: UIButton!
    /// An IBOutlet for handling the buttonLastWeek UIButton
    @IBOutlet private weak var buttonLastWeek: UIButton!
    /// An IBOutlet for handling the infoPopUpButton UIButton
    @IBOutlet private weak var infoPopUpButton: UIButton!
    
    /// An IBOutlet for handling the calendarImageView UIImageView
    @IBOutlet private weak var calendarImageView: UIImageView!
    
    /// An IBOutlet for handling the hidden textField UITextField
    @IBOutlet private weak var textField: UITextField!
    
    // MARK: - Variables
    
    var prefferedInfoMessage: String = "Check back where you were by using the date picker!"

    /// The FBClusteringManager object constant
    private let clusteringManager: FBClusteringManager = FBClusteringManager()
    
    /// The selected enum category of Helper.TimePeriodSelected object
    private var timePeriodSelectedEnum: TimePeriodSelected = TimePeriodSelected.none
    
    /// A static let variable pointing to the AuthoriseUserViewController for checking if token is active or not
    private static let authoriseVC: AuthoriseUserViewController = AuthoriseUserViewController()
    
    /// The uidatepicker used in toolbar
    private var datePicker: UIDatePicker?
    
    /// The uidatepicker used in toolbar
    private var segmentControl: UISegmentedControl?
    
    /// The start date to filter for points
    private var filterDataPointsFrom: Date? = Date().startOfDate()
    private var filterDataPointsTo: Date? = Date().endOfDate()
    
    /// The popUpView while downloading locations from hat
    private var popUpView: UIView?
    /// The popUpView while downloading locations from hat
    private var gettingLocationsView: UIView?
    
    /// A dark view covering the collection view cell
    private var darkView: UIVisualEffectView?
    
    @IBAction func showPopUp(_ sender: Any) {
        
        self.showInfoViewController(text: prefferedInfoMessage)
        self.infoPopUpButton.isUserInteractionEnabled = false
    }
    
    // MARK: - Auto generated methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // view controller title
        self.title = "Locations"
        
        // add notification observer for refreshUI
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(goToSettings),
            name: NSNotification.Name(Constants.NotificationNames.goToSettings),
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hidePopUp),
            name: NSNotification.Name(Constants.NotificationNames.hideDataServicesInfo),
            object: nil)
        
        let recogniser = UITapGestureRecognizer()
        recogniser.addTarget(self, action: #selector(self.selectDatesToViewLocations(gesture:)))
        self.calendarImageView.isUserInteractionEnabled = true
        self.calendarImageView.addGestureRecognizer(recogniser)
        
        self.createDatePickerAccessoryView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        // add gesture recognizers to today button
        buttonTodayTouchUp(UIBarButtonItem())
        
        // check token
        self.addChildViewController(MapViewController.authoriseVC)
        MapViewController.authoriseVC.checkToken(viewController: self)
        
        let result = KeychainHelper.getKeychainValue(key: Constants.Keychain.trackDeviceKey)
        
        if result != "true" {
            
            self.createClassicOKAlertWith(
                alertMessage: "You have disabled location tracking. To enable location tracking go to settings",
                alertTitle: "Location tracking disabled",
                okTitle: "OK",
                proceedCompletion: {})
        }
    }
    
    deinit {
        
        self.mapView.removeFromSuperview()
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.showsUserLocation = false
        self.mapView.delegate = nil
        self.mapView = nil
        self.removeFromParentViewController()
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Create Date Picker
    
    /**
     Creates the date picker for choosing dates to show location for
     */
    private func createDatePickerAccessoryView() {
        
        datePicker = UIDatePicker(frame: CGRect(x: 0, y: 200, width: view.frame.width, height: 220))
        
        // Set some of UIDatePicker properties
        datePicker!.timeZone = NSTimeZone.local
        datePicker!.backgroundColor = .white
        datePicker!.datePickerMode = .date
        
        // Add an event to call onDidChangeDate function when value is changed.
        datePicker!.addTarget(
            self,
            action: #selector(self.datePickerValueChanged(sender:)),
            for: .valueChanged)
        
        let doneButton = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(self.donePickerButton(sender:)))
        doneButton.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.teal], for: .normal)
        
        let spaceButton = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace,
            target: nil,
            action: nil)
        spaceButton.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.teal], for: .normal)
        
        self.segmentControl = UISegmentedControl(items: ["From", "To"])
        self.segmentControl!.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.teal], for: .normal)
        self.segmentControl!.selectedSegmentIndex = 0
        self.segmentControl!.addTarget(self, action: #selector(segmentedControlDidChange(sender:)), for: UIControlEvents.valueChanged)
        self.segmentControl!.tintColor = .teal
        
        let barButtonSegmentedControll = UIBarButtonItem(customView: segmentControl!)
        
        let spaceButton2 = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace,
            target: nil,
            action: nil)
        spaceButton2.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.teal], for: .normal)
        
        let cancelButton = UIBarButtonItem(
            title: "Cancel",
            style: .done,
            target: self,
            action: #selector(self.cancelPickerButton(sender:)))
        cancelButton.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.teal], for: .normal)
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .toolbarColor
        toolBar.sizeToFit()
        
        toolBar.setItems([cancelButton, spaceButton, barButtonSegmentedControll, spaceButton2, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        self.textField.inputView = datePicker
        self.textField.inputAccessoryView = toolBar
    }
    
    // MARK: - Toolbar methods
    
    /**
     Called everytime the segmented control changes value. Saves the from and to date to filter the locations
     
     - parameter sender: The object that called this method
     */
    @objc
    func segmentedControlDidChange(sender: UISegmentedControl) {
        
        if self.segmentControl!.selectedSegmentIndex == 0 {
            
            if self.filterDataPointsFrom != nil {
                
                self.datePicker!.setDate(self.filterDataPointsFrom!, animated: true)
            }
        } else {
            
            if self.filterDataPointsTo != nil {
                
                self.datePicker!.setDate(self.filterDataPointsTo!, animated: true)
            }
        }
    }

    /**
    The method executed when user taps the done button on the toolbar to filter the locations
 
     - parameter sender: The object that called this method
     */
    @objc
    func donePickerButton(sender: UIBarButtonItem) {
        
        self.textField.resignFirstResponder()
        
        self.popUpView = self.createPopUpWindowWith(text: "Getting locations...")
        
        LocationsWrapperHelper.getLocations(
            userToken: userToken,
            userDomain: userDomain,
            locationsFromDate: self.filterDataPointsFrom,
            locationsToDate: self.filterDataPointsTo,
            successRespond: showLocations,
            failRespond: { [weak self] (error) in
                
                self?.popUpView?.removeFromSuperview()
                CrashLoggerHelper.hatTableErrorLog(error: error)
            }
        )
    }
    
    /**
     The method executed when user taps the cancel button on the toolbar to filter the locations
     
     - parameter sender: The object that called this method
     */
    @objc
    func cancelPickerButton(sender: UIBarButtonItem) {
        
        self.textField.resignFirstResponder()
        self.filterDataPointsFrom = nil
        self.filterDataPointsTo = nil
    }
    
    // MARK: - Create Pop Up View
    
    /**
     Creates a rounded UIView with a UILabel
     
     - parameter text: The text to put on the label
     
     - returns: The UIView just created
     */
    @discardableResult
    private func createPopUpWindowWith(text: String) -> UIView {
        
        gettingLocationsView = UIView()
        gettingLocationsView?.createFloatingView(
            frame: CGRect(
                x: self.view.frame.midX - 60,
                y: self.view.frame.midY - 15,
                width: 120,
                height: 30),
            color: .teal,
            cornerRadius: 15)
        
        let label = UILabel().createLabel(
            frame: CGRect(x: 0, y: 0, width: 120, height: 30),
            text: text,
            textColor: .white,
            textAlignment: .center,
            font: UIFont(name: Constants.FontNames.openSans, size: 12))
        
        gettingLocationsView?.addSubview(label)
        
        self.view.addSubview(gettingLocationsView!)
        
        return view
    }
    
    // MARK: - Show locations
    
    /**
     Shows the locations received from hat
     
     - parameter json: the json received from HAT
     - parameter renewedUserToken: The new user token from HAT
     */
    private func showLocations(array: [HATLocationsObject], renewedUserToken: String?) {
        
        self.clusteringManager.removeAll()
        
        let pins = clusteringManager.createAnnotationsFrom(objects: array)
        clusteringManager.addPointsToMap(annottationArray: pins, mapView: self.mapView)
        
        // refresh user token
        KeychainHelper.setKeychainValue(key: Constants.Keychain.userToken, value: renewedUserToken)
        
        gettingLocationsView?.removeFromSuperview()
        
        if array.isEmpty {
            
            if self.filterDataPointsTo! > Date().endOfDate()! {
                
                self.createClassicOKAlertWith(
                    alertMessage: "There are no points for the selected dates, time travelling mode is deactivated",
                    alertTitle: "No points found",
                    okTitle: "OK",
                    proceedCompletion: {})
            } else {
                
                self.createClassicOKAlertWith(
                    alertMessage: "There are no points for the selected dates",
                    alertTitle: "No points found",
                    okTitle: "OK",
                    proceedCompletion: {})
            }
        }
    }
    
    // MARK: - Date picker method
    
    /**
     The method executed when the picker value changes to save the date to the correct value
     
     - parameter sender: The object that called this method
     */
    @objc
    func datePickerValueChanged(sender: UIDatePicker) {
        
        if self.segmentControl!.selectedSegmentIndex == 0 {
            
            self.filterDataPointsFrom = self.datePicker!.date.startOfDate(date: self.datePicker!.date)
            self.filterDataPointsTo = filterDataPointsFrom?.endOfDate(date: filterDataPointsFrom!)
        } else {
            
            self.filterDataPointsTo = self.datePicker!.date.endOfDate(date: self.datePicker!.date)
        }
    }
    
    // MARK: - Hidden Text Field method
    
    /**
     Init from and to values
     
    - parameter sender: The object that called this method
     */
    @objc
    func selectDatesToViewLocations(gesture: UITapGestureRecognizer) {
        
        self.textField.becomeFirstResponder()
        self.filterDataPointsFrom = Date().startOfDate()
        if let endOfDay = self.filterDataPointsFrom!.endOfDate() {
            
            self.filterDataPointsTo = endOfDay
        }
    }
    
    // MARK: - Notification methods
    
    /**
     Presents the settings view controller
     */
    @objc
    private func goToSettings() {
        
        self.performSegue(withIdentifier: Constants.Segue.settingsSequeID, sender: self)
    }
    
    // MARK: - IBActions
    
    /**
     Today tap event
     Create predicte for 7 days for now
     
     - parameter sender: The UIBarButtonItem that called this method
     */
    @IBAction func buttonLastWeekTouchUp(_ sender: UIBarButtonItem) {
        
        // filter data
        self.timePeriodSelectedEnum = TimePeriodSelected.lastWeek
        
        self.enableButton(self.buttonLastWeek)
        
        self.popUpView = self.createPopUpWindowWith(text: "Getting locations...")
        
        self.filterDataPointsFrom = Date().addingTimeInterval(FutureTimeInterval.init(days: Double(7), timeType: TimeType.past).interval)
        self.filterDataPointsFrom = Date().startOfDate(date: self.filterDataPointsFrom!)
        self.filterDataPointsTo = Date().endOfDate()
        
        LocationsWrapperHelper.getLocations(
            userToken: userToken,
            userDomain: userDomain,
            locationsFromDate: self.filterDataPointsFrom,
            locationsToDate: self.filterDataPointsTo,
            successRespond: showLocations,
            failRespond: { [weak self] (error) in
                
                self?.popUpView?.removeFromSuperview()
                CrashLoggerHelper.hatTableErrorLog(error: error)
            }
        )
    }
    
    /**
     Today tap event
     Create predicte for today
     
     - parameter sender: The UIBarButtonItem that called this method
     */
    @IBAction func buttonTodayTouchUp(_ sender: UIBarButtonItem) {
        
        // filter data
        self.timePeriodSelectedEnum = TimePeriodSelected.today
        
        self.enableButton(self.buttonToday)
        
        self.filterDataPointsFrom = Date().startOfDate()
        self.filterDataPointsTo = Date().endOfDate()
        
        self.popUpView = self.createPopUpWindowWith(text: "Getting locations...")
        
        LocationsWrapperHelper.getLocations(
            userToken: userToken,
            userDomain: userDomain,
            locationsFromDate: self.filterDataPointsFrom,
            locationsToDate: self.filterDataPointsTo,
            successRespond: showLocations,
            failRespond: { [weak self] (error) in
                
                self?.popUpView?.removeFromSuperview()
                CrashLoggerHelper.hatTableErrorLog(error: error)
            }
        )
    }
    
    /**
     Today tap event
     Create predicte for yesterday *only*
     
     - parameter sender: The UIBarButtonItem that called this method
     */
    @IBAction func buttonYesterdayTouchUp(_ sender: UIBarButtonItem) {
        
        // filter data
        self.timePeriodSelectedEnum = TimePeriodSelected.yesterday
        
        self.enableButton(self.buttonYesterday)
        
        self.filterDataPointsFrom = Date().addingTimeInterval(FutureTimeInterval.init(days: Double(1), timeType: TimeType.past).interval) // remove 24hrs
        self.filterDataPointsTo = self.filterDataPointsFrom
        
        self.filterDataPointsFrom = Date().startOfDate(date: self.filterDataPointsFrom!)
        self.filterDataPointsTo = Date().endOfDate(date: self.filterDataPointsTo!)
        
        self.popUpView = self.createPopUpWindowWith(text: "Getting locations...")
        
        LocationsWrapperHelper.getLocations(
            userToken: userToken,
            userDomain: userDomain,
            locationsFromDate: self.filterDataPointsFrom,
            locationsToDate: self.filterDataPointsTo,
            successRespond: showLocations,
            failRespond: { [weak self] (error) in
                
                self?.popUpView?.removeFromSuperview()
                CrashLoggerHelper.hatTableErrorLog(error: error)
            }
        )
    }
    
    // MARK: - MapView delegate methods
    
    /**
     Called when the map region changes...pan..zoom, etc
     
     - parameter mapView: the mapview
     - parameter animated: animated
     */
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        DispatchQueue.main.async { [unowned self] () -> Void in

            let mapBoundsWidth = Double(self.mapView.bounds.size.width)
            if self.textField.isFirstResponder {
                
                self.textField.resignFirstResponder()
                self.filterDataPointsFrom = nil
                self.filterDataPointsTo = nil
            }
            
            OperationQueue().addOperation({ [weak self] () -> Void in
                
                if let wSelf = self {
                    
                    // calculate map size and scale
                    let mapRectWidth: Double = wSelf.mapView.visibleMapRect.size.width
                    let scale: Double = mapBoundsWidth / mapRectWidth
                    let annotationArray = wSelf.clusteringManager.clusteredAnnotations(withinMapRect: wSelf.mapView.visibleMapRect, zoomScale: scale)
                    DispatchQueue.main.sync(
                        execute: { [weak self] () -> Void in
                            
                            if let weakSelf = self {
                                
                                // display map
                                weakSelf.clusteringManager.display(annotations: annotationArray, onMapView: weakSelf.mapView)
                            }
                        }
                    )
                }
            })
        }
    }
    
    /**
     Called through map delegate to update its annotations
     
     - parameter mapView: the maoview object
     - parameter annotation: annotation to render
     
     - returns: An optional object of type MKAnnotationView
     */
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "Pin"
        if annotation.isKind(of: FBAnnotationCluster.self) {
            
            return FBAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId)
        } else {
            
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .green
            return pinView
        }
    }
    
    // MARK: - Protocol methods
    
    func onChanged() {
        
        UpdateLocations.shared.resumeLocationServices()
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
    
    // MARK: - Change background color on buttons
    private func enableButton(_ button: UIButton) {
        
        if self.buttonLastWeek.backgroundColor == .teal {
            
            self.buttonLastWeek.setTitleColor(.teal, for: .normal)
            self.buttonLastWeek.backgroundColor = .white
        } else if self.buttonToday.backgroundColor == .teal {
            
            self.buttonToday.setTitleColor(.teal, for: .normal)
            self.buttonToday.backgroundColor = .white
        } else if self.buttonYesterday.backgroundColor == .teal {
            
            self.buttonYesterday.setTitleColor(.teal, for: .normal)
            self.buttonYesterday.backgroundColor = .white
        }
        
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .teal
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
        
        let calculatedHeight = textPopUpViewController!.getLabelHeight() + 170
        
        self.tabBarController?.tabBar.isUserInteractionEnabled = false
        
        textPopUpViewController?.view.createFloatingView(
            frame: CGRect(
                x: self.view.frame.origin.x + 15,
                y: self.view.frame.maxY,
                width: self.view.frame.width - 30,
                height: calculatedHeight),
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
                            y: weakSelf.view.frame.maxY + 30 - calculatedHeight,
                            width: weakSelf.view.frame.width - 30,
                            height: calculatedHeight)
                    },
                    completion: { _ in return }
                )
            }
        }
    }
}
