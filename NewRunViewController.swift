//
//  ViewController.swift
//  SpeedRacer
//
//  Created by Dev on 19/08/15.
//  Copyright (c) 2015 LA. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import MapKit

class NewRunViewController: UIViewController {
    var managedObjectContext: NSManagedObjectContext?
    
    var race: Run!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var velocity: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var noticeLabel: UILabel!
    
    enum ReadyStart  {
        case Ready
        case NotReady
    }
    
    enum CorrectSpeed  {
        case On
        case Off
    }
    
    let DetailSegueName = "RaceDetails"
    var units : Unit = Unit(NSUserDefaults.standardUserDefaults().integerForKey(kUnitsSegmetedControl))!
    var seconds = 0
    var distance = 0.0
    var flagReady = ReadyStart.NotReady
    var corectSpeed = CorrectSpeed.Off {
        didSet {
            if oldValue != corectSpeed {
                switch corectSpeed {
                case .On :
                    noticeLabel.hidden = true
                    startButton.enabled = true
                    break
                case .Off :
                    settingViewWait()
                    break
                }
            }
        }
    }
    
    var maxSpeed = 0.0
    var startTime :NSTimeInterval = 0.0
    
    let speedLimit = UtilityClass.calculateLimitSpeed()
    
    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        _locationManager.activityType = .AutomotiveNavigation
        _locationManager.distanceFilter = kCLLocationAccuracyBestForNavigation
        return _locationManager
        }()
    
    lazy var locations = [CLLocation]()
    lazy var timer = NSTimer()
    
    // MARK: - Load
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestAlwaysAuthorization()
        settingViewWait()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        SpeedNotifications.askAlertPermission()
        maxSpeed=0.0
        distanceLabel.hidden = true
        timeLabel.hidden = true
        stopButton.hidden = true
        startButton.hidden = false
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }
    
    // MARK: - Timer
    func eachSecond(timer: NSTimer) {
        seconds++
        settingView()
    }
    

    
    // MARK: -  Actions
    @IBAction func racePressed(sender: AnyObject) {

        startTime = NSDate.timeIntervalSinceReferenceDate()
        
        seconds = 0
        distance = 0.0
        flagReady = .Ready;
        
        distanceLabel.hidden = false
        timeLabel.hidden = false
        noticeLabel.hidden = true
        startButton.hidden = true
        stopButton.hidden = false
        settingView()
        
        locations.removeAll(keepCapacity: false)
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "eachSecond:", userInfo: nil, repeats: true)
    }
    
    @IBAction func stopPressed(sender: AnyObject) {
        saveRun()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let detailViewController = segue.destinationViewController as? DetailViewController {
            detailViewController.race = race
        }
    }
    
    func saveRun() {
        
        SpeedNotifications.addNotification()
        
        flagReady = .NotReady
        
        let savedRace = NSEntityDescription.insertNewObjectForEntityForName("Run", inManagedObjectContext: managedObjectContext!) as!  Run
        savedRace.distance = distance
        savedRace.duration = NSDate.timeIntervalSinceReferenceDate() - startTime
        savedRace.timestamp = NSDate()
        savedRace.speed = maxSpeed
        
        var savedLocations = [Location]()
        for location in locations {
            let savedLocation = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: managedObjectContext!) as! Location
            savedLocation.timestamp = location.timestamp
            savedLocation.latitude = location.coordinate.latitude
            savedLocation.longitude = location.coordinate.longitude
            savedLocations.append(savedLocation)
        }
        
        savedRace.locations = NSOrderedSet(array: savedLocations)
        race = savedRace
        
        var error: NSError?
        let success = managedObjectContext!.save(&error)
        if !success {
            println("Could not save the race!")
        } else {
            performSegueWithIdentifier(DetailSegueName, sender: nil)
        }
    }
    // MARK: UI
    func settingView () {
        timeLabel.text =  seconds.timeToString
        distanceLabel.text = UtilityClass.distanceToString(distance)
    }
    func settingViewWait () {
        noticeLabel.text = NSLocalizedString("noticeLabelWait", comment: "Wait")
        noticeLabel.hidden = false
        startButton.enabled = false
        velocity.text =  "..."
        velocity.textColor = UIColor.whiteColor()
    }
    
    
    func speedChanged (speed: Double){
        velocity.text = UtilityClass.speedToString(speed)
        switch speed {
        case let speedBinding where speedBinding  < speedLimit:
            velocity.textColor = UIColor.whiteColor()
            break
            
        case let speedBinding where speedBinding >= speedLimit && flagReady == .NotReady:
            velocity.textColor = UIColor.redColor()
            break
            
        case let speedBinding where speedBinding >= speedLimit && flagReady == .Ready:
            velocity.textColor = UIColor.redColor()
            maxSpeed = (speed > maxSpeed) ? speed : maxSpeed
            UtilityClass.playSuccessSound()
            SpeedNotifications.addNotification()
            break
            
        default:break
        }
    }
}

// MARK: - MKMapViewDelegate
extension NewRunViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if !overlay.isKindOfClass(MKPolyline) {
            return nil
        }
        
        let polyline = overlay as! MKPolyline
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 3
        return renderer
    }
}

// MARK: - CLLocationManagerDelegate
extension NewRunViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        for location in locations as! [CLLocation] {
            
            if location.speed < 0 {
                    corectSpeed = .Off
            } else {
            
            let howRecent = location.timestamp.timeIntervalSinceNow
            if abs(howRecent) < 10 && location.horizontalAccuracy < 20 {
                
                //update distance
                if self.locations.count > 0 {
                    corectSpeed = .On
                    distance += location.distanceFromLocation(self.locations.last)
            
                    var coords = [CLLocationCoordinate2D]()
                    coords.append(self.locations.last!.coordinate)
                    coords.append(location.coordinate)
                    
                    let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500)
                    mapView.setRegion(region, animated: true)
                    mapView.addOverlay(MKPolyline(coordinates: &coords, count: coords.count))
                    
                    speedChanged(location.speed)
                }
                
                //save location
                self.locations.append(location)
                }
            }
        }
    }
}


