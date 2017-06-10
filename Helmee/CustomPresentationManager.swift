//
//  CustomPresentationManager.swift
//  Helmee
//
//  Created by Antoine Payan on 06/07/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import UIKit

enum CustomPresentationController {
    case questionText
    case answers
    case answer
}

class CustomPresentationManager: NSObject, UIViewControllerTransitioningDelegate {

    private var type: CustomPresentationController

    init(type: CustomPresentationController) {
        self.type = type
        super.init()
    }

    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        switch type {
        case .questionText:
            return QuestionTextPresentationController(presentedViewController: presented, presenting: presenting)
        case .answers:
            return AnswersPresentationController(presentedViewController: presented, presenting: presenting)
        case .answer:
            return AnswerPresentationController(presentedViewController: presented, presenting: presenting)
        }
    }
}
