//
//  LocationsViewController.swift
//  Birdy2
//
//  Created by veso on 2/5/16.
//  Copyright © 2016 veso. All rights reserved.
//

import UIKit
import GoogleMaps


@objc class LocationsViewController: UIViewController {
    var locations: Array<Coordinates>!;

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logoImage = UIImage(named: "scriptLogo")
        let scriptLogoView = UIImageView(image:logoImage)
        scriptLogoView.contentMode = UIViewContentMode.ScaleAspectFit;
        scriptLogoView.frame = CGRectMake(0, 0, 30.0, 30.0);
        self.navigationItem.titleView = scriptLogoView;
        
        let firstPointLat = (self.locations[0].latitude as NSString).doubleValue
        let firstPointLon = (self.locations[0].longitude as NSString).doubleValue
        
        let camera = GMSCameraPosition.cameraWithLatitude(firstPointLat,
            longitude: firstPointLon, zoom: 5)
        let mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        mapView.myLocationEnabled = true
        self.view = mapView
        
        for point in self.locations {
            let marker = GMSMarker()
            let latitude = (point.latitude as NSString).doubleValue
            let longitude = (point.longitude as NSString).doubleValue
            marker.position = CLLocationCoordinate2DMake(latitude, longitude)
            // marker.title = "Sydney"
            // marker.snippet = "Australia"
            marker.map = mapView
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
