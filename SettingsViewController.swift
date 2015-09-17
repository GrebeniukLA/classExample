//
//  ViewController.swift
//  SpeedRacer
//
//  Created by Dev on 19/08/15.
//  Copyright (c) 2015 LA. All rights reserved.
//


import UIKit

enum Unit : Int {
    case KpH
    case MpH
    
    init? (_ value : Int) {
        switch value {
        case 0: self = KpH
        case 1: self = MpH
        default: return nil
        }
    }
}

enum Sound : Int {
    case On
    case Off
}

enum Vibration : Int {
    case On
    case Off
}

let kSpeedPickerViewConstant = "kSpeedPickerViewConstant"
let kUnitsSegmetedControl = "kUnitsSegmetedControl"
let kSoundSegmetedControl = "kSoundSegmetedControl"
let kVibrationSegmetedControl = "kVibrationSegmetedControl"
let stepInSpeedPicker = 5
let numberSpeedValue = 70
let defaultSpeedValue = 100

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var soundSegmentController: UISegmentedControl!
    
    @IBOutlet weak var vibrationSegmetedControl: UISegmentedControl!
    @IBOutlet weak var unitsSegmetedControl: UISegmentedControl!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var speedLabel: UILabel!
    
    
    var sound = Sound(rawValue: NSUserDefaults.standardUserDefaults().integerForKey(kSoundSegmetedControl))!
        {
        didSet {
            NSUserDefaults.standardUserDefaults().setInteger(sound.rawValue, forKey: kSoundSegmetedControl)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    var vibration = Vibration(rawValue: NSUserDefaults.standardUserDefaults().integerForKey(kVibrationSegmetedControl))!
        {
        didSet {
            NSUserDefaults.standardUserDefaults().setInteger(vibration.rawValue, forKey: kVibrationSegmetedControl)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    var unit = Unit(NSUserDefaults.standardUserDefaults().integerForKey(kUnitsSegmetedControl))!
        {
        didSet {
          //  unitsSegmetedControl.selectedSegmentIndex = unit.rawValue;
            NSUserDefaults.standardUserDefaults().setInteger(unit.rawValue, forKey: kUnitsSegmetedControl)
            NSUserDefaults.standardUserDefaults().synchronize()
            setTextForSpeedLavel()
        }
    }
    
    var speed : Int = NSUserDefaults.standardUserDefaults().integerForKey(kSpeedPickerViewConstant) == 0 ? defaultSpeedValue : NSUserDefaults.standardUserDefaults().integerForKey(kSpeedPickerViewConstant)
        {
        didSet {
            NSUserDefaults.standardUserDefaults().setInteger(speed, forKey: kSpeedPickerViewConstant)
            NSUserDefaults.standardUserDefaults().synchronize()
            setTextForSpeedLavel()
        }
    }
    
    var row : Int {
        return (speed / stepInSpeedPicker) - 1
    }
    
    let arraySpeed: [Int] = {
        var array = [Int]()
        for index in 1...numberSpeedValue {
            array.append(index*stepInSpeedPicker)
        }
        return array
    }()
    
    // MARK: - Load
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        pickerView.selectRow(row, inComponent: 0, animated: true)
        unitsSegmetedControl.selectedSegmentIndex = unit.rawValue;
        soundSegmentController.selectedSegmentIndex = sound.rawValue;
        vibrationSegmetedControl.selectedSegmentIndex = vibration.rawValue;
        setTextForSpeedLavel()
    }
    
    func setTextForSpeedLavel (){
        speedLabel.text = UtilityClass.textForSpeedLavel(unit: unit, withSpeed: speed)
    }
    
    
    // MARK: - SegmetedControl
    @IBAction func unitsSegmetedControlChanged(sender: UISegmentedControl)
    {
        unit = Unit(sender.selectedSegmentIndex)!
    }
    @IBAction func soundSegmentedControlChanged(sender: UISegmentedControl) {
        sound = Sound(rawValue: sender.selectedSegmentIndex)!
    }
    
    @IBAction func vibrationSegmentedControlChanged(sender: UISegmentedControl) {
        vibration = Vibration(rawValue: sender.selectedSegmentIndex)!
    }
    // MARK: -  Actions
    @IBAction func linkAction(sender: UIButton) {
        var path: NSURL?
        
        switch sender.tag {
        case 0 : path = NSURL(string: NSLocalizedString("dradRaceLink", comment: "dradRaceLink"))!
        case 1 : path = NSURL(string: NSLocalizedString("calculatorLink", comment: "calculatorLink"))!
        default: break
        }

       UIApplication.sharedApplication().openURL(path!)
        
    }
    // MARK: - Action
    @IBAction func shareAction(sender: AnyObject) {
        let textToShare = UtilityClass.textForSharing()
        if let myWebsite = NSURL(string: NSLocalizedString("shareLink", comment: "shareLink"))
        {
            let objectsToShare = [textToShare, myWebsite]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponentsInPickerView(pickerView: UIPickerView!) -> Int
    {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int
    {
        return arraySpeed.count
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString?
    {
        return NSAttributedString(string: "\(arraySpeed[row])", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        speed =  Int (arraySpeed[row] as NSNumber)
    }
    
}


