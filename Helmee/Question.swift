//
//  Question.swift
//  Helmee
//
//  Created by Antoine Payan on 11/06/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import Foundation
import MapKit

struct Question {
    var id: Int
    var text: String
    var idAuthor: Int
    var usernameAuthor: String
    var credits: Int
    var position: CLLocationCoordinate2D
    var radius: Int
    var date: Date
    var accepted: Bool = false
    var answered: Bool = false
    var numberOfAnswers = 0
    var category: Category
    var answers: [Answer]?

    init(id: Int,
         text: String,
         idAuthor: Int,
         usernameAuthor: String,
         credits: Int,
         position: CLLocationCoordinate2D,
         radius: Int,
         date: Date,
         accepted: Bool,
         answered: Bool,
         numberOfAnswers: Int,
         category: Category?,
         answers: [Answer]?) {
        self.id = id
        self.text = text
        self.idAuthor = idAuthor
        self.usernameAuthor = usernameAuthor
        self.credits = credits
        self.position = position
        self.radius = radius
        self.date = date
        self.accepted = accepted
        self.answered = answered
        self.numberOfAnswers = numberOfAnswers
        self.answers = answers
        guard let category = category else {
            self.category = Category(id: 9, title: "", image: 0, color: "")
            return
        }
        self.category = category
    }

}
