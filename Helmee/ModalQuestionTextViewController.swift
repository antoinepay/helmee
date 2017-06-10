//
//  ModalQuestionTextViewController.swift
//  Helmee
//
//  Created by Antoine Payan on 15/06/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import UIKit
import Font_Awesome_Swift

class ModalQuestionTextViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak private var charactersCount: UILabel!
    @IBOutlet weak private var validateButton: UIButton!
    @IBOutlet weak private var textView: UITextView!
    @IBOutlet weak private var dismissButton: UIButton!
    @IBOutlet weak private var titleLabel: UILabel!
    private var delegate: MapQuestionTextDelegate
    private var question: Question?
    
    init(delegate: MapQuestionTextDelegate, question: Question) {
        self.delegate = delegate
        self.question = question
        super.init(nibName: "ModalQuestionTextViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "cancel"), style: .plain, target: self, action: #selector(dismissView))
        navigationItem.rightBarButtonItem?.tintColor = UIColor(hexString: Texts.mainColor)
        title = "Ma question"
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if (textView.text == Texts.questionPlaceholder)
        {
            textView.text = ""
            textView.textColor = .black
        }
        textView.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if (textView.text == "")
        {
            textView.text = Texts.questionPlaceholder
            textView.textColor = .lightGray
        }
        textView.resignFirstResponder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if(textView.text.isEmpty)
        {
            charactersCount.textColor=UIColor.red;
            charactersCount.text=String(textView.text.characters.count)+"/90";
            validateButton.isEnabled=false;
        }
        else
        {
            if(textView.text.characters.count <= 90)
            {
                charactersCount.textColor=UIColor.init(hexString: Texts.mainColor);
                charactersCount.text=String(textView.text.characters.count)+"/90";
                validateButton.isEnabled=true;
            }
            else
            {
                charactersCount.textColor=UIColor.red;
                charactersCount.text=String(textView.text.characters.count)+"/90";
                validateButton.isEnabled=false;
            }
        }
    }

    private func setupView() {
        validateButton.isEnabled = false
        validateButton.addTarget(self, action: #selector(validText), for: .touchUpInside)
        validateButton.setTitle("Go", for: .normal)
        validateButton.layer.cornerRadius = validateButton.frame.size.width / 2
        validateButton.setBackgroundColor(UIColor(hexString: Texts.mainColor), forState: .normal)
        validateButton.clipsToBounds = true
        validateButton.setTitleColor(.white, for: .normal)
        validateButton.tintColor = UIColor(hexString: Texts.mainColor)
        textView.delegate = self
        textView.text = Texts.questionPlaceholder
        textView.textColor = .lightGray
        textView.textAlignment = .natural
        textView.autocorrectionType = .no
        textView.isEditable = true
        charactersCount.text = "0/90"
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        textView.resignFirstResponder()
    }
    
    @objc private func validText() {
        question?.text = textView.text
        navigationController?.pushViewController(CategoryChoiceViewController(delegate: delegate, question: question), animated: true)
    }

    @objc private func dismissView() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
