//
//  PlaceRepository.swift
//  Helmee
//
//  Created by Antoine Payan on 18/06/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import Foundation
import Alamofire

protocol PlaceRepository {
    func getMyPlaces()
    func deletePlace(place: Place)
}

protocol PlaceViewContract: class {
    func placesFetched(_ places: [Place])
    func handlePlacesError(_ error: HTTPError)
    func placeDeleted()
    func handlePlaceDeletedError(_ error: HTTPError)
}

class PlaceRepositoryImplementation: PlaceRepository {
    
    private var parser: JSONParserImplementation
    private var client: HTTPClient
    private var viewContract: PlaceViewContract
    
    init(client: HTTPClient, parser: JSONParserImplementation, viewContract: PlaceViewContract) {
        self.parser = parser
        self.client = client
        self.viewContract = viewContract
    }
    
    func fetchMyPlaces(callback: @escaping (Result<[Place], HTTPError>) -> Void) {
        let url = TargetSettings.myPlaces
        let user = User.verifyUserArchived()
        let parameters: Parameters = [
            "idUser": user.id,
            "token": user.token
        ]
        let request = HTTPRequest(.post, URL: url, parameters: parameters) { result in
            switch result {
            case let .value(json):
                guard let json = json as? [Any] else {
                    callback(.error(HTTPError(type: .unspecified, message: nil)))
                    return
                }
                let places: [Place] = self.parser.parse(json: json)
                callback(.value(places))
            case let .error(error):
                callback(.error(error))
            }
        }
        client.send(request: request)
    }
    
    func getMyPlaces() {
        fetchMyPlaces { result in
            switch result {
            case let .value(value):
                self.viewContract.placesFetched(value)
            case let .error(error):
                self.viewContract.handlePlacesError(error)
            }
        }
    }
    
    
    func deletePlaceRequest(place: Place, callback: @escaping (Result<Any, HTTPError>) -> Void) {
        let url = TargetSettings.deletePlace
        let user = User.verifyUserArchived()
        let parameters: Parameters = [
            "idUser": user.id,
            "token": user.token,
            "idPlace": place.id
        ]
        let request = HTTPRequest(.post, URL: url, parameters: parameters) { result in
            switch result {
            case let .value(json):
                guard let json = json as? [String: Any] else {
                    callback(.error(HTTPError(type: .unspecified, message: nil)))
                    return
                }
                callback(.value(json))
            case let .error(error):
                callback(.error(error))
            }
        }
        client.send(request: request)
    }
    

    func deletePlace(place: Place) {
        deletePlaceRequest(place: place) { result in
            switch result {
            case .value(_):
                self.viewContract.placeDeleted()
            case let .error(error):
                self.viewContract.handlePlaceDeletedError(error)
            }
        }
    }
}


