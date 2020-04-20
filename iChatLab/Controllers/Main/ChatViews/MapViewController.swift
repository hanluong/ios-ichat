//
//  MapViewController.swift
//  iChatLab
//
//  Created by Han Luong on 4/20/20.
//  Copyright © 2020 Han Luong. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var location: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Map"
        
        setupViews()
    }
    
    func setupViews() {
        let coordinate = location.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        mapView.addAnnotation(annotation)
        
        // Add righ bar button to open map app
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open in Maps", style: .plain, target: self, action: #selector(rightBarButtonPressed))
    }
    
    @objc func rightBarButtonPressed() {
        let regionSpan = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        let launchOptions = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        
        let placeMark = MKPlacemark(coordinate: location.coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placeMark)
        mapItem.openInMaps(launchOptions: launchOptions)
    }
    
}
