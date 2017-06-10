//
//  PlaceDetailViewController.swift
//  Helmee
//
//  Created by Antoine Payan on 18/06/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import UIKit
import MapKit

class PlaceDetailViewController: SharedViewController, MKMapViewDelegate, PlaceViewContract {

    @IBOutlet weak private var mapView: MKMapView!
    private var place: Place
    
    lazy private var placeRepository: PlaceRepository = self.factory.getPlaceRepository(viewContract: self)

    init(factory: Factory, place: Place) {
        self.place = place
        super.init(factory: factory)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    //MARK: - PlaceViewContract
    
    func placesFetched(_ places: [Place]) {
        
    }
    
    func handlePlacesError(_ error: HTTPError) {
        
    }
    
    func placeDeleted() {
        dismiss(animated: true, completion: { _ in
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    func handlePlaceDeletedError(_ error: HTTPError) {
        dismiss(animated: true, completion: { _ in
            self.showSimpleAlertWithMessage(title: "Oups", message: "Impossible de supprimer la zone, veuillez réessayer")
        })
    }
    
    //MARK: - Private
    
    private func setupView() {
        mapView.delegate = self
        mapView.mapType = MKMapType(rawValue: 0)!
        mapView.showsPointsOfInterest = true;
        mapView.showsUserLocation = true
        mapView.isScrollEnabled = true;
        mapView.isZoomEnabled = true;
        mapView.showsCompass = true
        mapView.showsBuildings = true
        mapView.showsScale = true
        mapView.setCenter(place.position, animated: true)
        let viewRegion = MKCoordinateRegionMakeWithDistance(place.position, 2000, 2000)
        let adjustedRegion = mapView.regionThatFits(viewRegion)
        mapView.setRegion(adjustedRegion, animated: true)
        let pin = MKPointAnnotation()
        pin.coordinate = place.position
        mapView.addAnnotation(pin)
        let deleteButton = UIBarButtonItem(title: "Supprimer", style: .plain, target: self, action: #selector(deletePlace))
        deleteButton.tintColor = UIColor(hexString: Texts.redColor)
        navigationItem.rightBarButtonItem = deleteButton
    }
    
    @objc private func deletePlace() {
        showLoader()
        placeRepository.deletePlace(place: place)
    }

}
