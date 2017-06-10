//
//  Factory.swift
//  Helmee
//
//  Created by Antoine Payan on 11/06/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import Foundation

class Factory {
    
    private lazy var client = HTTPClient()
    private lazy var parser = JSONParserImplementation()

    func getLoginRepository(viewContract: LoginViewContract) -> LoginRepository {
        return LoginRepositoryImplementation(
            client: client,
            parser: parser,
            viewContract: viewContract
        )
    }
    
    func getAccountRepository(viewContract: AccountViewContract) -> AccountRepository {
        return AccountRepositoryImplementation(
            client: client,
            parser: parser,
            viewContract: viewContract
        )
    }
    
    func getQuestionRepository(viewContract: QuestionViewContract) -> QuestionRepository {
        return QuestionRepositoryImplementation(
            client: client,
            parser: parser,
            viewContract: viewContract
        )
    }
    
    func getCategoryRepository(viewContract: CategoryViewContract) -> CategoryRepository {
        return CategoryRepositoryImplementation(
            client: client,
            parser: parser,
            viewContract: viewContract
        )
    }
    
    func getPlaceRepository(viewContract: PlaceViewContract) -> PlaceRepository {
        return PlaceRepositoryImplementation(
            client: client,
            parser: parser,
            viewContract: viewContract
        )
    }

    func getAnswerRepository(viewContract: AnswerViewContract) -> AnswerRepository {
        return AnswerRepositoryImplementation(
            client: client,
            parser: parser,
            viewContract: viewContract
        )
    }

    func getNewsRepository(viewContract: NewsViewContract) -> NewsRepository {
        return NewsRepositoryImplementation(
            client: client,
            parser: parser,
            viewContract: viewContract
        )
    }
}
