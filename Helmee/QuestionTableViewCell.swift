//
//  QuestionTableViewCell.swift
//  Helmee
//
//  Created by Antoine Payan on 11/06/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import UIKit
import KDCircularProgress
import Font_Awesome_Swift

private struct Constants {
    static let stateImageSize = CGSize(width: 32, height: 32)
    static let diamondImageSize = CGSize(width: 20, height: 20)
}
class QuestionTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var authorLabel: UILabel!
    @IBOutlet weak private var remainingTime: UILabel!
    @IBOutlet weak private var progressView: KDCircularProgress!
    @IBOutlet weak private var viewQuestion: UIView!
    @IBOutlet weak private var credits: UILabel!
    @IBOutlet weak private var creditsImage: UIImageView!
    @IBOutlet weak private var stateImage: UIImageView!
    @IBOutlet weak private var questionText: UILabel!
    
    var question: Question?
    
    func configure(question: Question) {
        selectionStyle = .none
        self.question = question
        let user = User.verifyUserArchived()
        let color = UIColor(hexString: question.category.color)
        credits.text = String(question.credits)
        credits.textColor = color
        creditsImage.image = UIImage(icon: .FADiamond, size: Constants.diamondImageSize, orientation: UIImageOrientation.up, textColor: color, backgroundColor: .clear)
        creditsImage.tintColor = color
        if question.accepted {
            stateImage.image = UIImage(icon: .FACheck, size: Constants.stateImageSize, orientation: UIImageOrientation.up, textColor: color, backgroundColor: .clear)
        } else if question.answered {
            stateImage.image = UIImage(icon: .FAHourglass2, size: Constants.stateImageSize, orientation: UIImageOrientation.up, textColor: color, backgroundColor: .clear)
        } else {
            stateImage.image = UIImage(icon: .FAClockO, size: Constants.stateImageSize, orientation: UIImageOrientation.up, textColor: color, backgroundColor: .clear)
        }
        stateImage.tintColor = color
        questionText.text = question.text
        questionText.textColor = .black
        backgroundColor = .white
        viewQuestion.backgroundColor = .clear
        viewQuestion.layer.cornerRadius = 4.0
        viewQuestion.layer.borderColor = color.cgColor
        viewQuestion.layer.borderWidth = 2.0
        var time = question.date.timeIntervalSinceNow
        time = abs(time / 60)
        var remain: Double = 0
        if time > 3 * 60 {
            remainingTime.text = "0"
        } else if time > 2 * 60 {
            remain = time / 60
            remain = round(10 * remain) / 10
            remainingTime.text = String(3 - remain) + "h"
        } else {
            remain = (3 * 60 - time).rounded()
            remainingTime.text = String(Int(remain)) + "'"
        }
        var degrees = time * 360 / 180
        if degrees > 360 {
            degrees = 0
        } else {
            degrees = 360 - degrees
        }
        progressView.angle = degrees
        progressView.clockwise = true
        progressView.trackColor = .lightGray
        progressView.trackThickness = 0.6
        progressView.progressThickness = 0.5
        progressView.progressInsideFillColor = UIColor(hexString: question.category.color)
        if user.id != question.idAuthor {
            authorLabel.text = question.usernameAuthor
            authorLabel.textColor = color
        } else {
            authorLabel.isHidden = true
        }
        
    }
}
