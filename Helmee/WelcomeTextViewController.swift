//
//  WelcomeTextViewController.swift
//  Helmee
//
//  Created by Antoine Payan on 30/08/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import UIKit

class WelcomeTextViewController: UIViewController {

    @IBOutlet weak private var logo: UIImageView!
    @IBOutlet weak private var actionButton: UIButton!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var textLabel: UITextView!

    private var welcomeStruct: WelcomeStruct
    private var welcomeType: WelcomeType
    private let gradientLayer = CAGradientLayer()

    init(welcomeType: WelcomeType) {
        self.welcomeType = welcomeType
        self.welcomeStruct = WelcomeStruct(welcomeType: welcomeType)
        super.init(nibName: "WelcomeTextViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = welcomeStruct.title
        textLabel.attributedText = welcomeStruct.text
        setupButton()
        setupLogo()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupGradient()
    }

    private func setupGradient() {
        view.backgroundColor = .white
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor(hexString: Texts.mainColor).cgColor, UIColor(hexString: "#027dca").cgColor]
        gradient.frame = view.frame
        view.layer.insertSublayer(gradient, at: 0)
    }

    private func setupButton() {
        if welcomeType != .end {
            actionButton.isHidden = true
            return
        }
        actionButton.setImage(#imageLiteral(resourceName: "launch"), for: .normal)
        actionButton.tintColor = .white
        actionButton.setTitle(nil, for: .normal)
        actionButton.addTarget(self, action: #selector(dismissWelcome(_:)), for: .touchUpInside)
    }

    private func setupLogo() {
        logo.image = welcomeStruct.logo?.image ?? nil
    }

    @objc private func dismissWelcome(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "introSkipped")
        UserDefaults.standard.synchronize()
        dismiss(animated: true, completion: nil)
    }
}
