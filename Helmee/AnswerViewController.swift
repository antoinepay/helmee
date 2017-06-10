//
//  AnswerViewController.swift
//  Helmee
//
//  Created by Antoine Payan on 15/08/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import UIKit
import Font_Awesome_Swift

private struct Constants {
    static let answerFont = UIFont.systemFont(ofSize: 15.0)
}

class AnswerViewController: SharedViewController, UITextViewDelegate {

    @IBOutlet weak private var sendAnswer: UIButton!
    @IBOutlet weak private var answerTextView: UIView!
    @IBOutlet weak private var answerText: UITextView!
    @IBOutlet weak private var questionLabel: UILabel!
    @IBOutlet weak private var answerHeight: NSLayoutConstraint!

    private var question: Question

    init(question: Question, factory: Factory) {
        self.question = question
        super.init(factory: factory)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if range.location >= 60, range.location >= textView.text.characters.count  {
            return false
        }
        return true
    }

    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if (textView.text == "Votre réponse") {
            textView.text = ""
            textView.textColor = .black
        }
        textView.becomeFirstResponder() //Optional
    }

    func textViewDidEndEditing(_ textView: UITextView)
    {
        if (textView.text.isEmpty) {
            textView.text = "Votre réponse"
            textView.textColor = .lightGray
        }
        textView.resignFirstResponder()
    }

    func textViewDidChange(_ textView: UITextView) {
        updateAnswerView(font: Constants.answerFont)
    }

    private func updateAnswerView(font: UIFont) {
        answerText.font = Constants.answerFont
        let height = answerText.text.height(withConstrainedWidth: answerText.frame.size.width - 10, font: font)
        answerHeight.constant = height + 20
        view.layoutSubviews()
        answerText.layoutSubviews()
    }

    private func setupView() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:))))
        view.backgroundColor = UIColor(hexString: "#FAFAFA")
        questionLabel.text = question.text
        answerText.text = "Votre réponse"
        answerText.textColor = .lightGray
        answerTextView.layer.cornerRadius = 15.0
        answerTextView.layer.borderColor = UIColor(hexString: "#9E9E9E").cgColor
        answerTextView.layer.borderWidth = 1.0
        answerText.delegate = self
        updateAnswerView(font: Constants.answerFont)
        sendAnswer.setFAIcon(icon: .FASend, iconSize: 16.0, forState: .normal)
        sendAnswer.tintColor = .white
        sendAnswer.backgroundColor = UIColor(hexString: Texts.mainColor)
        sendAnswer.layer.cornerRadius = sendAnswer.frame.size.width / 2.0
    }

    @objc private func dismissKeyboard(_ sender: Any) {
        answerText.resignFirstResponder()
    }
}
