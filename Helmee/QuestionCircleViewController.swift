//
//  QuestionCircleViewController.swift
//  Helmee
//
//  Created by Antoine Payan on 28/08/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import UIKit
import KDCircularProgress
import Font_Awesome_Swift

class QuestionCircleViewController: UIViewController {

    private var question: Question
    private var circle: KDCircularProgress = KDCircularProgress()
    private var categoryBadge = UIView()
    private var factory: Factory
    lazy private var answersTransitioningDelegate = CustomPresentationManager(type: .answers)

    @IBOutlet weak private var authorLabel: UILabel!
    @IBOutlet weak private var circleView: UIView!
    @IBOutlet weak private var textLabel: UILabel!

    @IBOutlet weak private var globalCircleView: UIView!
    @IBOutlet weak private var numberOfAnswersLabel: UILabel!
    @IBOutlet weak private var answerLabel: UILabel!

    init(question: Question, factory: Factory) {
        self.question = question
        self.factory = factory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupCircleView()
        let tap = UITapGestureRecognizer(target: self, action: #selector(presentAnswersViewController))
        view.addGestureRecognizer(tap)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        globalCircleView.bringSubview(toFront: categoryBadge)
        let widthCircle = circleView.frame.size.width
        let center = globalCircleView.center
        let distanceFromCenter = (widthCircle / 2.0) * sqrt(2.0) / 2.0
        let x = center.x - distanceFromCenter
        categoryBadge.frame.origin = CGPoint(x: x, y: widthCircle / 2 * (1 - sqrt(2) / 2.0))
    }

    private func setupView() {
        categoryBadge.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        categoryBadge.layer.cornerRadius = 16.0
        let categoryImage = UIImage(icon: FAType.init(rawValue: question.category.image)!, size: CGSize(width: 26, height: 26), orientation: .up, textColor: .white, backgroundColor: .clear)
        let imageView = UIImageView(image: categoryImage)
        categoryBadge.addSubview(imageView)
        imageView.center = categoryBadge.center
        categoryBadge.clipsToBounds = true
        categoryBadge.backgroundColor = UIColor(hexString: question.category.color)
        categoryBadge.layer.borderColor = UIColor.white.cgColor
        categoryBadge.layer.borderWidth = 2.0
        globalCircleView.addSubview(categoryBadge)
        textLabel.text = question.text
        textLabel.textColor = UIColor(hexString: question.category.color)
        numberOfAnswersLabel.font = UIFont.systemFont(ofSize: 25, weight: 200)
        numberOfAnswersLabel.text = String(describing: question.answers?.count ?? 0)
        var text = "réponse"
        if let answers = question.answers,
            !answers.isEmpty {
            text = text + "s"
        }
        answerLabel.text = text
        authorLabel.text = "Par " + question.usernameAuthor
        authorLabel.textColor = UIColor.lightGray.withAlphaComponent(0.8)
        authorLabel.font = UIFont.systemFont(ofSize: 15)
    }

    private func setupCircleView() {
        circleView.backgroundColor = .clear
        circleView.addSubview(circle)
        circle.pinToSuperview()
        circle.progressThickness = 0.1
        circle.glowMode = .constant
        circle.glowAmount = 0.4
        circle.angle = 360
        circle.trackColor = .clear
        let firstColor = UIColor(hexString: question.category.color)
        let secondColor = firstColor.lighter(by: 20) ?? firstColor
        circle.set(colors: secondColor, firstColor)
    }

    @objc private func presentAnswersViewController() {
        let answersViewController = AnswersViewController(question: question, factory: factory)
        let navigationController = UINavigationController()
        navigationController.viewControllers = [answersViewController]
        navigationController.modalPresentationStyle = .custom
        navigationController.transitioningDelegate = answersTransitioningDelegate
        present(navigationController, animated: true, completion: nil)
    }

}
