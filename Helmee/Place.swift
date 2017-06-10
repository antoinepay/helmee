//
//  Place.swift
//  Helmee
//
//  Created by Antoine Payan on 18/06/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import Foundation
import MapKit

class Place {
    var id: Int
    var name: String
    var position: CLLocationCoordinate2D

    init(id: Int, name: String, latitude: String, longitude: String) {
        self.id = id
        self.name = name
        if let lat = CLLocationDegrees(latitude),
            let lng = CLLocationDegrees(longitude) {
            self.position = CLLocationCoordinate2D(
                latitude: lat,
                longitude: lng
            )
        } else {
            self.position = CLLocationCoordinate2D()
        }
    }
}
