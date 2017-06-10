//
//  CategoryRepository.swift
//  Helmee
//
//  Created by Antoine Payan on 12/06/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import Foundation
import Alamofire

protocol CategoryRepository {
    func getCategories()
    func editCategories(categories: [Category])
}

protocol CategoryViewContract: class {
    func categoriesFetched(_ categories: [Category])
    func handleCategoriesError(_ error: HTTPError)
    func categoriesEdited()
    func handleCategoriesEditError(_ error: HTTPError)
}

class CategoryRepositoryImplementation: CategoryRepository {
    
    private var parser: JSONParserImplementation
    private var client: HTTPClient
    private var viewContract: CategoryViewContract
    
    init(client: HTTPClient, parser: JSONParserImplementation, viewContract: CategoryViewContract) {
        self.parser = parser
        self.client = client
        self.viewContract = viewContract
    }
    
    func getCategories() {
        fetchCategories { result in
            switch result {
            case let .value(value):
                self.viewContract.categoriesFetched(value)
            case let .error(error):
                self.viewContract.handleCategoriesError(error)
            }
        }
    }
    
    func editCategories(categories: [Category]) {
        editCategoriesRequest(categories: categories) { result in
            switch result {
            case .value(_):
                self.viewContract.categoriesEdited()
            case let .error(error):
                self.viewContract.handleCategoriesEditError(error)
            }
        }
    }

    private func fetchCategories(callback: @escaping (Result<[Category], HTTPError>) -> Void) {
        let url = TargetSettings.categoriesIndex
        let user = User.verifyUserArchived()
        let parameters: Parameters = [
            "id": user.id,
            "token": user.token
        ]
        let request = HTTPRequest(.post, URL: url, parameters: parameters) { result in
            switch result {
            case let .value(json):
                guard let json = json as? [Any] else {
                    callback(.error(HTTPError(type: .unspecified, message: nil)))
                    return
                }
                let categories: [Category] = self.parser.parse(json: json)
                callback(.value(categories))
            case let .error(error):
                callback(.error(error))
            }
        }
        client.send(request: request)
    }
    
    private func editCategoriesRequest(categories: [Category], callback: @escaping (Result<Any, HTTPError>) -> Void) {
        var categoriesSerialized = ""
        for category in categories {
            categoriesSerialized += String(category.id) + ","
        }
        let url = TargetSettings.editCategories
        let user = User.verifyUserArchived()
        let parameters: Parameters = [
            "idUser": user.id,
            "token": user.token,
            "categories": categoriesSerialized
        ]
        let request = HTTPRequest(.post, URL: url, parameters: parameters) { result in
            switch result {
            case let .value(json):
                guard let json = json as? [String:Any] else {
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

}
