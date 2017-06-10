//
//  LoginRepository.swift
//  Helmee
//
//  Created by Antoine Payan on 11/06/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import Foundation
import Alamofire

protocol LoginRepository {
    func login(username: String, password: String)
}

protocol LoginViewContract: class {
    func login(_ user: User)
    func handleLoginError(_ error: HTTPError)
}

class LoginRepositoryImplementation: LoginRepository {
    
    private var parser: JSONParserImplementation
    private var client: HTTPClient
    private var viewContract: LoginViewContract
    static let client: HTTPClient = HTTPClient()
    
    init(client: HTTPClient, parser: JSONParserImplementation, viewContract: LoginViewContract) {
        self.parser = parser
        self.client = client
        self.viewContract = viewContract
    }
    
    func loginAction(username: String, password: String, callback: @escaping (Result<User, HTTPError>) -> Void) {
        let url = TargetSettings.loginUrl
        let parameters: Parameters = [
            "username": username,
            "password": password
        ]
        let request = HTTPRequest(.post, URL: url, parameters: parameters) { result in
            switch result {
            case let .value(json):
                guard let json = json as? [String:Any] else {
                    return
                }
                if let message = self.parser.checkErrorMessage(json: json) {
                    let error = HTTPError(type: .personalized, message: message)
                    callback(.error(error))
                    return
                }
                let user: User = self.parser.parse(json: json)
                callback(.value(user))
            case let .error(error):
                callback(.error(error))
            }
        }
        client.send(request: request)
    }
    
    func login(username: String, password: String) {
        loginAction(username: username, password: password) { result in
            switch result {
            case let .value(user):
                self.viewContract.login(user)
            case let .error(error):
                self.viewContract.handleLoginError(error)
            }
        }
    }
    
    static func checkConnection(user: User, callback: @escaping (Result<User,HTTPError>) -> Void) {
        let url = TargetSettings.verifyConnectionUrl
        let parameters: Parameters = [
            "username": user.username,
            "token": user.token
        ]
        let request = HTTPRequest(.post, URL: url, parameters: parameters) { result in
            switch result {
            case let .value(json):
                guard let json = json as? [String:Any] else {
                    return
                }
                let user: User = JSONParserImplementation.parse(json: json)
                callback(.value(user))
            case let .error(error):
                callback(.error(error))
            }
        }
        client.send(request: request)
    }
}
