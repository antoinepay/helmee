//
//  AnswerTableViewCell.swift
//  Helmee
//
//  Created by Antoine Payan on 06/08/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import UIKit

class AnswerTableViewCell: UITableViewCell {

    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet private weak var answerView: UIView!
    @IBOutlet weak var answerLabel: UILabel!
    var answer: Answer?
    weak var answerTableViewCellDelegate: AnswerTableViewCellDelegate?

    func configure(answer: Answer, delegate: AnswerTableViewCellDelegate) {
        selectionStyle = .none
        self.answer = answer
        self.answerTableViewCellDelegate = delegate
        authorLabel.text = answer.authorUsername
        answerLabel.text = answer.text
        answerLabel.sizeToFit()
        answerLabel.frame.size.height = answerView.frame.size.height
        if answer.accepted {
            answerView.backgroundColor = UIColor(hexString: Texts.greenColor)
        } else if answer.rejected {
            answerView.backgroundColor = UIColor(hexString: Texts.redColor)
        } else {
            answerView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        }
        answerView.layer.cornerRadius = 15.0
        answerView.clipsToBounds = true
        if !answer.accepted, !answer.rejected {
            let forceTouch = DeepPressGestureRecognizer(target: self, action: #selector(handleTouch(_:)), threshold: 0.8)
            answerView.addGestureRecognizer(forceTouch)
        }
    }

    func reset() {
        guard let answer = answer else { return }
        if answer.accepted {
            answerView.backgroundColor = UIColor(hexString: Texts.greenColor)
        } else if answer.rejected {
            answerView.backgroundColor = UIColor(hexString: Texts.redColor)
        } else {
            answerView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        }
    }

    func setEffectOnMessageView(transform: Bool, callback: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3, animations: {
            if transform {
                self.answerView.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
            } else {
                self.answerView.transform = CGAffineTransform.identity
            }
        }, completion: { _ in
            callback()
        })
    }

    func setBackground(with color: UIColor) {
        answerView.backgroundColor = color
    }

    func setOriginalColor() {
        guard let answer = answer else { return }
        if answer.accepted {
            answerView.backgroundColor = UIColor(hexString: Texts.greenColor)
        } else if answer.rejected {
            answerView.backgroundColor = UIColor(hexString: Texts.redColor)
        } else {
            answerView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        }
    }

    @objc private func handleTouch(_ sender: Any) {
        guard let forceTouch = sender as? DeepPressGestureRecognizer else { return }
        if forceTouch.state == .began {
            guard
                let delegate = answerTableViewCellDelegate,
                let answer = answer else {
                return
            }
            if #available(iOS 10.0, *) {
                let generator = UISelectionFeedbackGenerator()
                generator.selectionChanged()
            }
            delegate.didForceTouchAnswer(answer)
        }
    }
}
