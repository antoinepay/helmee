//
//  AnswerRepository.swift
//  Helmee
//
//  Created by Antoine Payan on 09/08/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import Foundation
import Alamofire

protocol AnswerRepository {
    func refreshAnswers(for question: Question)
    func validate(_ answer: Answer)
    func reject(_ answer: Answer)
}

protocol AnswerViewContract: class {
    func answerValidated()
    func handleValidateAnswerError(_ error: HTTPError)
    func answerRejected()
    func handleRejectAnswerError(_ error: HTTPError)
    func answersRefreshed(_ answers: [Answer])
    func handleAnswersRefreshError(_ error: HTTPError)
}

class AnswerRepositoryImplementation: AnswerRepository {
    private var parser: JSONParserImplementation
    private var client: HTTPClient
    private var viewContract: AnswerViewContract

    init(client: HTTPClient, parser: JSONParserImplementation, viewContract: AnswerViewContract) {
        self.parser = parser
        self.client = client
        self.viewContract = viewContract
    }

    func validate(_ answer: Answer) {
        validateAnswerRequest(answer: answer) { result in
            switch result {
            case .value(_):
                self.viewContract.answerValidated()
                break
            case let .error(error):
                self.viewContract.handleValidateAnswerError(error)
                break
            }
        }
    }

    func reject(_ answer: Answer) {
        rejectAnswerRequest(answer: answer) { result in
            switch result {
            case .value(_):
                self.viewContract.answerRejected()
                break
            case let .error(error):
                self.viewContract.handleRejectAnswerError(error)
                break
            }
        }
    }

    func refreshAnswers(for question: Question) {
        refreshAnswersRequest(question: question) { result in
            switch result {
            case let .value(value):
                self.viewContract.answersRefreshed(value)
                break
            case let .error(error):
                self.viewContract.handleAnswersRefreshError(error)
                break
            }
        }
    }

    private func validateAnswerRequest(answer: Answer, callback: @escaping (Result<Any, HTTPError>) -> Void) {
        let url = TargetSettings.validateAnswer
        let user = User.verifyUserArchived()
        let parameters: Parameters = [
            "idUser": user.id,
            "token": user.token,
            "idAnswer": answer.id
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
                callback(.value(json))
            case let .error(error):
                callback(.error(error))
            }
        }
        client.send(request: request)
    }

    private func refreshAnswersRequest(question: Question, callback: @escaping (Result<[Answer], HTTPError>) -> Void) {
        let url = TargetSettings.answersQuestion
        let user = User.verifyUserArchived()
        let parameters: Parameters = [
            "idUser": user.id,
            "token": user.token,
            "idQuestion": question.id
        ]
        let request = HTTPRequest(.post, URL: url, parameters: parameters) { result in
            switch result {
            case let .value(json):
                guard let json1 = json as? [Any] else {
                    guard let json = json as? [String:Any] else { return }
                    if let message = self.parser.checkErrorMessage(json: json) {
                        let error = HTTPError(type: .personalized, message: message)
                        callback(.error(error))
                        return
                    }
                    return
                }
                let answers: [Answer] = self.parser.parse(json: json1)
                callback(.value(answers))
            case let .error(error):
                callback(.error(error))
            }
        }
        client.send(request: request)
    }

    func rejectAnswerRequest(answer: Answer, callback: @escaping (Result<Any, HTTPError>) -> Void) {
        let url = TargetSettings.rejectAnswer
        let user = User.verifyUserArchived()
        let parameters: Parameters = [
            "idUser": user.id,
            "token": user.token,
            "idAnswer": answer.id
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
                callback(.value(json))
            case let .error(error):
                callback(.error(error))
            }
        }
        client.send(request: request)
    }


    
}

