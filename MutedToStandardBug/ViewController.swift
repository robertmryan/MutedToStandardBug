//
//  ViewController.swift
//  MutedToStandardBug
//
//  Created by Robert Ryan on 4/3/20.
//  Copyright © 2020 Robert Ryan. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var forceChangeSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapView()
    }
}

// MARK: - Actions

extension ViewController {
    @IBAction func didChangeMapTypeSegmentedControlValue(_ sender: UISegmentedControl) {
        updateMapType()
    }

    @IBAction func didChangeForceChange(_ sender: UISwitch) {
        updateMapType()
    }
}

// MARK: - Change Map Type (This is the bug.)

private extension ViewController {

    /// Change map type
    ///
    /// If you change from `.standard` to `.mutedStandard` in iOS 13, you won't see the change unless you set
    /// `forceChangeSwitch.isOn`. There are a number of ways to force the change. Below I'm resetting the `centerCoordinate`.
    /// You can also force the change by changing to `.satellite` or `.hybrid` before setting to `.standard` or
    /// `.mutedStandard`.

    func updateMapType() {
        switch mapTypeSegmentedControl.selectedSegmentIndex {
        case 0: mapView.mapType = .mutedStandard
        case 1: mapView.mapType = .standard
        case 2: mapView.mapType = .satellite
        case 3: mapView.mapType = .hybrid
        default: break
        }

        if forceChangeSwitch.isOn {
            // if we do this kludgy reset of the `centerCoordinate`, the map is updated correctly.
            mapView.centerCoordinate = mapView.centerCoordinate
        }
    }

}

// MARK: - Unrelated methods to configure mapview

private extension ViewController {
    func configureMapView() {
        setCamera()
        findRestaurants()
        updateMapType()
    }

    func setCamera() {
        let apple = CLLocationCoordinate2D(latitude: 37.332693, longitude: -122.03071)
        mapView.camera = MKMapCamera(lookingAtCenter: apple, fromDistance: 4400, pitch: 0, heading: 0)
    }

    func findRestaurants() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "restaurant"
        request.region = mapView.region

        MKLocalSearch(request: request).start { [weak self] response, _ in
            guard let mapItems = response?.mapItems else { return }

            let annotations = mapItems.map { (mapItem) -> MKAnnotation in
                let annotation = MKPointAnnotation()
                annotation.coordinate = mapItem.placemark.coordinate
                annotation.title = mapItem.name
                return annotation
            }

            self?.mapView.addAnnotations(annotations)
        }
    }
}
