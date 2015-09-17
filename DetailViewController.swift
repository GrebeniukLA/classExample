//
//  ViewController.swift
//  SpeedRacer
//
//  Created by Dev on 19/08/15.
//  Copyright (c) 2015 LA. All rights reserved.
//

import UIKit
import MapKit


class DetailViewController: UIViewController {
    var race: Run!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    var units : Unit = Unit(NSUserDefaults.standardUserDefaults().integerForKey(kUnitsSegmetedControl))!
    
    func configureView() {
        
        timeLabel.text = Int (race.duration).timeToString
        
        distanceLabel.text = "\(UtilityClass.distanceToString(Double (race.distance)))"
        

//        speedLabel.text = NSLocalizedString("speedLabel", comment: "timeLabel") +
//                        "\(UtilityClass.speedString(unit: units, speed: race.speed) ))"

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateLabel.text =  NSLocalizedString("dateLabel", comment: "dateLabel") +
        "\(dateFormatter.stringFromDate(race.timestamp))"
        
        loadMap()
    }
    
    func mapRegion() -> MKCoordinateRegion {
        let initialLoc = race.locations.firstObject as! Location
        
        var minLat = initialLoc.latitude.doubleValue
        var minLng = initialLoc.longitude.doubleValue
        var maxLat = minLat
        var maxLng = minLng
        
        let locations = race.locations.array as! [Location]
        
        for location in locations {
            minLat = min(minLat, location.latitude.doubleValue)
            minLng = min(minLng, location.longitude.doubleValue)
            maxLat = max(maxLat, location.latitude.doubleValue)
            maxLng = max(maxLng, location.longitude.doubleValue)
        }
        
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: (minLat + maxLat)/2,
                longitude: (minLng + maxLng)/2),
            span: MKCoordinateSpan(latitudeDelta: (maxLat - minLat)*1.1,
                longitudeDelta: (maxLng - minLng)*1.1))
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if !overlay.isKindOfClass(MulticolorPolylineSegment) {
            return nil
        }
        
        let polyline = overlay as! MulticolorPolylineSegment
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = polyline.color
        renderer.lineWidth = 3
        return renderer
    }
    
    func polyline() -> MKPolyline {
        var coords = [CLLocationCoordinate2D]()
        
        let locations = race.locations.array as! [Location]
        for location in locations {
            coords.append(CLLocationCoordinate2D(latitude: location.latitude.doubleValue,
                longitude: location.longitude.doubleValue))
        }
        
        return MKPolyline(coordinates: &coords, count: race.locations.count)
    }
    
    func loadMap() {
        if race.locations.count > 0 {
            mapView.hidden = false
            
            // Set the map bounds
            mapView.region = mapRegion()
            
            // Make the line(s!) on the map
            let colorSegments = MulticolorPolylineSegment.colorSegments(forLocations: race.locations.array as! [Location])
            mapView.addOverlays(colorSegments)
        } else {
            // No locations were found!
            mapView.hidden = true
            
            UIAlertView(title: "Error",
                message: "Sorry, this race has no locations saved",
                delegate:nil,
                cancelButtonTitle: "OK").show()
        }
    }
    // MARK: - Action
//    @IBAction func sharePressed(sender: AnyObject) {
//        
//        let textToShare = textForSharing()
//        if let myWebsite = NSURL(string: NSLocalizedString("shareLink", comment: "shareLink"))
//        {
//            let objectsToShare = [textToShare, myWebsite]
//            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
//            
//            self.presentViewController(activityVC, animated: true, completion: nil)
//        }
//        
//    }
    
//    func textForSharing () ->NSString {
//        let firstText = NSLocalizedString("firstText", comment: "firstText") +
//        "\(UtilityClass.speedString(unit: units, speed: race.speed)))" +
//        NSLocalizedString("middleText", comment: "middleText") +
//        "\(UtilityClass.stringFromTimeInterval(Int (race.duration)))" +
//        NSLocalizedString("s", comment: "s") +
//        NSLocalizedString("secondText", comment: "secondText")
//        
//        return firstText
//    }
    
}

// MARK: - MKMapViewDelegate
extension DetailViewController: MKMapViewDelegate {
}
