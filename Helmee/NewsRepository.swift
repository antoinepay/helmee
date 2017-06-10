//
//  NewsRepository.swift
//  Helmee
//
//  Created by Antoine Payan on 27/08/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import Foundation
import Alamofire

protocol NewsRepository {
    func news()
}

protocol NewsViewContract: class {
    func newsFetched(_ strates: [NewsStrate])
    func handleNewsError(_ error: HTTPError)
}

class NewsRepositoryImplementation: NewsRepository {

    private var parser: JSONParserImplementation
    private var client: HTTPClient
    private var viewContract: NewsViewContract
    static let client: HTTPClient = HTTPClient()

    init(client: HTTPClient, parser: JSONParserImplementation, viewContract: NewsViewContract) {
        self.parser = parser
        self.client = client
        self.viewContract = viewContract
    }

    func newsAction(callback: @escaping (Result<[NewsStrate], HTTPError>) -> Void) {
        let url = TargetSettings.news
        let user = User.verifyUserArchived()
        let parameters: Parameters = [
            "idUser": user.id,
            "token": user.token
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
                let strates: [NewsStrate] = self.parser.parse(json: json)
                callback(.value(strates))
            case let .error(error):
                callback(.error(error))
            }
        }
        client.send(request: request)
    }

    func news() {
        newsAction() { result in
            switch result {
            case let .value(news):
                self.viewContract.newsFetched(news)
            case let .error(error):
                self.viewContract.handleNewsError(error)
            }
        }
    }
}
