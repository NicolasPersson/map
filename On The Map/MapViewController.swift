//
//  ViewController.swift
//  On The Map
//
//  Created by Chris Bacon on 2015-09-26.
//  Copyright © 2015 BaconCo. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
   
    let coordinates = CLLocationCoordinate2D(latitude: CLLocationDegrees(37.7617), longitude: CLLocationDegrees(-122.4216))
    let pinn = MKPointAnnotation()
    
        pinn.coordinate = coordinates
    
    self.mapView.addAnnotation(pinn)
    
    }

}

