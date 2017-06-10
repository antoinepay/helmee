//
//  User.swift
//  Helmee
//
//  Created by Antoine Payan on 11/06/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import Foundation
import MapKit

class User: NSObject, NSCoding {
    var id: Int
    var username: String
    var email: String
    var position: CLLocationCoordinate2D
    var credits: Int
    var token: String
    var rank: Int
    var points: Int
    var helpInstructions: Bool
    var categories: [Category]
    
    init(id: Int,
         username: String,
         email: String,
         latitude: String,
         longitude: String,
         credits: Int,
         token: String,
         rank: Int,
         points: Int,
         helpInstructions: Bool,
         categories: [Category]) {
        self.id = id
        self.username = username
        self.email = email
        if let lat = CLLocationDegrees(latitude), let lng = CLLocationDegrees(longitude) {
            self.position = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        } else {
            self.position = CLLocationCoordinate2D()
        }
        self.credits = credits
        self.token = token
        self.rank = rank
        self.points = points
        self.helpInstructions = helpInstructions
        self.categories = categories
    }
    
    override init() {
        id = 0
        username = ""
        email = ""
        position = CLLocationCoordinate2D()
        token = ""
        credits = 0
        rank = 0
        points = 0
        helpInstructions = false
        categories = []
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(username, forKey: "username")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(position.latitude.description, forKey: "latitude")
        aCoder.encode(position.longitude.description, forKey: "longitude")
        aCoder.encode(credits, forKey: "credits")
        aCoder.encode(token, forKey: "token")
        aCoder.encode(rank, forKey: "rank")
        aCoder.encode(points, forKey: "points")
        aCoder.encode(helpInstructions, forKey: "helpInstructions")
        aCoder.encode(categories, forKey: "categories")
    }
    
    required init(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeInteger(forKey: "id")
        self.username = aDecoder.decodeObject(forKey: "username") as! String
        self.email = aDecoder.decodeObject(forKey: "email") as! String
        if let latitude = aDecoder.decodeObject(forKey: "latitude") as? String,
            let longitude = aDecoder.decodeObject(forKey: "longitude") as? String {
            if let lat = CLLocationDegrees(latitude), let lng = CLLocationDegrees(longitude) {
                self.position = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            } else {
                self.position = CLLocationCoordinate2D()
            }
        } else {
            self.position = CLLocationCoordinate2D()
        }
        self.credits = aDecoder.decodeInteger(forKey: "credits")
        self.token = aDecoder.decodeObject(forKey: "token") as! String
        self.rank = aDecoder.decodeInteger(forKey: "rank")
        self.points = aDecoder.decodeInteger(forKey: "points")
        self.helpInstructions = aDecoder.decodeBool(forKey: "helpInstructions")
        if let categories = aDecoder.decodeObject(forKey: "categories") as? [Category] {
            self.categories = categories
        } else {
            self.categories = []
        }
    }
    
    static func verifyUserArchived() -> User {
        guard let userData = UserDefaults.standard.object(forKey: "user") as? Data else {
            return User()
        }
        guard let user = NSKeyedUnarchiver.unarchiveObject(with: userData) as? User else {
            return User()
        }
        return user
    }
}
