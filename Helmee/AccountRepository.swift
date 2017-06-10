//
//  AccountRepository.swift
//  Helmee
//
//  Created by Antoine Payan on 11/06/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import Foundation
import Alamofire

protocol AccountRepository {
    func changeHelpInstructions(value: Bool)
}

protocol AccountViewContract: class {
    func valueChanged(_ value: Bool)
    func handleValueChangedError(_ error: HTTPError)
}

class AccountRepositoryImplementation: AccountRepository {
    
    private var parser: JSONParserImplementation
    private var client: HTTPClient
    private var viewContract: AccountViewContract
    
    init(client: HTTPClient, parser: JSONParserImplementation, viewContract: AccountViewContract) {
        self.parser = parser
        self.client = client
        self.viewContract = viewContract
    }
    
    func changeHelpAction(value: Bool, callback: @escaping (Result<Bool, HTTPError>) -> Void) {
        let url = TargetSettings.changeHelpUrl
        let user = User.verifyUserArchived()
        let parameters: Parameters = [
            "idUser": user.id,
            "token": user.token,
            "value": value ? "true" : "false"
        ]
        let request = HTTPRequest(.post, URL: url, parameters: parameters) { result in
            switch result {
            case let .value(json):
                guard let _ = json as? [String:Any] else {
                    return
                }
                callback(.value(value))
            case let .error(error):
                callback(.error(error))
            }
        }
        client.send(request: request)
    }
    
    func changeHelpInstructions(value: Bool) {
        changeHelpAction(value: value) { result in
            switch result {
            case let .value(value):
                self.viewContract.valueChanged(value)
            case let .error(error):
                self.viewContract.handleValueChangedError(error)
            }
        }
    }
}
