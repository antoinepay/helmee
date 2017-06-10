//
//  TargetSettings.swift
//  Helmee
//
//  Created by Antoine Payan on 11/06/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import Foundation

struct TargetSettings {
    static let serverUrl = "https://api.helmee.fr/"
    static let loginUrl = TargetSettings.serverUrl + "login"
    static let verifyConnectionUrl = TargetSettings.serverUrl + "verifyConnection"
    static let changeHelpUrl = TargetSettings.serverUrl + "changeHelpInstructions"
    static let myQuestions = TargetSettings.serverUrl + "myQuestions"
    static let categoriesIndex = TargetSettings.serverUrl + "categoriesIndex"
    static let editCategories = TargetSettings.serverUrl + "editCategories"
    static let myPlaces = TargetSettings.serverUrl + "places"
    static let deletePlace = TargetSettings.serverUrl + "deletePlace"
    static let questionsLocation = TargetSettings.serverUrl + "questionsLocation"
    static let sendQuestion = TargetSettings.serverUrl + "sendQuestion"
    static let deleteQuestion = TargetSettings.serverUrl + "deleteQuestion"
    static let validateAnswer = TargetSettings.serverUrl + "validateAnswer"
    static let answersQuestion = TargetSettings.serverUrl + "answersQuestion"
}
