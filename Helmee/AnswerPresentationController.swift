//
//  AnswerPresentationController.swift
//  Helmee
//
//  Created by Antoine Payan on 15/08/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import UIKit

class AnswerPresentationController: SharedPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        var frame: CGRect = .zero
        frame.size = size(forChildContentContainer: presentedViewController,
                          withParentContainerSize: containerView!.bounds.size)

        frame.origin = CGPoint(x: containerView!.bounds.size.width * (1.0/12.0), y: containerView!.bounds.size.height * (1.5/5.0))
        return frame
    }

    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        setupKeyboardObserver()
    }

    override func size(forChildContentContainer container: UIContentContainer,
                       withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: parentSize.width*(5.0/6.0), height: parentSize.height/2.5)
    }

    private func setupKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShown), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
    }

    @objc private func keyboardShown(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        guard var frame = presentedView?.frame else { return }
        if frame.maxY > keyboardFrame.origin.y {
            frame.origin.y -= frame.maxY - keyboardFrame.origin.y + 20
            presentedView?.frame = frame
        }
    }
}
