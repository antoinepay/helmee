//
//  AnswersPresentationController.swift
//  Helmee
//
//  Created by Antoine Payan on 06/08/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import UIKit

class AnswersPresentationController: SharedPresentationController {

    override var frameOfPresentedViewInContainerView: CGRect {
        var frame: CGRect = .zero
        frame.size = size(forChildContentContainer: presentedViewController,
                          withParentContainerSize: containerView!.bounds.size)

        frame.origin = CGPoint(x: containerView!.bounds.size.width * (1.0/24.0), y: containerView!.bounds.size.height * (1.0/24.0))
        return frame
    }

    override func size(forChildContentContainer container: UIContentContainer,
                       withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: parentSize.width * (11.0 / 12.0), height: parentSize.height * (11.0 / 12.0))
    }
}

