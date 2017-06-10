//
//  QuestionRepository.swift
//  Helmee
//
//  Created by Antoine Payan on 11/06/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import Foundation
import Alamofire
import MapKit

protocol QuestionRepository {
    func getMyQuestions()
    func getQuestionsLocation()
    func send(Question: Question)
    func deleteAction(question: Question)
}

protocol QuestionViewContract: class {
    func questionsFetched(_ questions: [Question])
    func handleQuestionsError(_ error: HTTPError)
    func questionsLocationFetched(_ questions: [Question])
    func handleQuestionsLocationError(_ error: HTTPError)
    func questionSent()
    func handleQuestionSentError(_ error: HTTPError)
    func questionDeleted()
    func handleQuestionDeletedError(_ error: HTTPError)
}

extension QuestionViewContract {
    func questionsFetched(_ questions: [Question]) {}
    func handleQuestionsError(_ error: HTTPError) {}
    func questionsLocationFetched(_ questions: [Question]) {}
    func handleQuestionsLocationError(_ error: HTTPError) {}
    func questionSent() {}
    func handleQuestionSentError(_ error: HTTPError) {}
    func questionDeleted() {}
    func handleQuestionDeletedError(_ error: HTTPError) {}
}

class QuestionRepositoryImplementation: QuestionRepository {
    
    private var parser: JSONParserImplementation
    private var client: HTTPClient
    private var viewContract: QuestionViewContract
    
    init(client: HTTPClient, parser: JSONParserImplementation, viewContract: QuestionViewContract) {
        self.parser = parser
        self.client = client
        self.viewContract = viewContract
    }
    
    func getMyQuestions(callback: @escaping (Result<[Question], HTTPError>) -> Void) {
        let url = TargetSettings.myQuestions
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
                let questions: [Question] = self.parser.parse(json: json)
                callback(.value(questions))
            case let .error(error):
                callback(.error(error))
            }
        }
        client.send(request: request)
    }
    
    func getQuestionsLocation(callback: @escaping (Result<[Question], HTTPError>) -> Void) {
        let url = TargetSettings.questionsLocation
        let user = User.verifyUserArchived()
        let parameters: Parameters = [
            "id": user.id,
            "token": user.token,
            "latitude": user.position.latitude,
            "longitude": user.position.longitude
        ]
        let request = HTTPRequest(.post, URL: url, parameters: parameters) { result in
            switch result {
            case let .value(json):
                guard let json = json as? [Any] else {
                    callback(.error(HTTPError(type: .unspecified, message: nil)))
                    return
                }
                let questions: [Question] = self.parser.parse(json: json)
                callback(.value(questions))
            case let .error(error):
                callback(.error(error))
            }
        }
        client.send(request: request)
    }
    
    func getMyQuestions() {
        getMyQuestions { result in
            switch result {
            case let .value(value):
                self.viewContract.questionsFetched(value)
            case let .error(error):
                self.viewContract.handleQuestionsError(error)
            }
        }
    }
    
    func getQuestionsLocation() {
        getQuestionsLocation { result in
            switch result {
            case let .value(value):
                self.viewContract.questionsLocationFetched(value)
            case let .error(error):
                self.viewContract.handleQuestionsLocationError(error)
            }
        }
    }
    
    func sendQuestion(question: Question, callback: @escaping (Result<Any, HTTPError>) -> Void) {
        let url = TargetSettings.sendQuestion
        let user = User.verifyUserArchived()
        let parameters: Parameters = [
            "idAuthor": user.id,
            "token": user.token,
            "latitude": question.position.latitude,
            "longitude": question.position.longitude,
            "radius": question.radius,
            "text": question.text,
            "categoryId": question.category.id,
            "credits": question.credits
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
    
    func send(Question: Question) {
        sendQuestion(question: Question) { result in
            switch result {
            case .value(_):
                self.viewContract.questionSent()
            case let .error(error):
                self.viewContract.handleQuestionSentError(error)
            }
        }
    }
    
    func delete(question: Question, callback: @escaping (Result<Any, HTTPError>) -> Void) {
        let url = TargetSettings.deleteQuestion
        let user = User.verifyUserArchived()
        let parameters: Parameters = [
            "idUser": user.id,
            "token": user.token,
            "idQuestion": question.id
        ]
        let request = HTTPRequest(.post, URL: url, parameters: parameters) { result in
            switch result {
            case let .value(message):
                callback(.value(message))
            case let .error(error):
                callback(.error(error))
            }
        }
        client.send(request: request)
    }
    
    func deleteAction(question: Question) {
        delete(question: question) { result in
            switch result {
            case .value(_):
                self.viewContract.questionDeleted()
            case let .error(error):
                self.viewContract.handleQuestionDeletedError(error)
            }
        }
    }
}
