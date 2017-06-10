//
//  Answer.swift
//  Helmee
//
//  Created by Antoine Payan on 06/08/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import Foundation

struct Answer {
    var id: Int
    var text: String
    var question: Int
    var date: Date
    var accepted: Bool
    var rejected: Bool
    var authorId: Int
    var authorUsername: String
}
