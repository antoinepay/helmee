//
//  WelcomeViewController.swift
//  Helmee
//
//  Created by Antoine Payan on 30/08/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import UIKit

enum WelcomeType {
    case intro
    case question
    case news
    case places
    case report
    case end
}

struct WelcomeStruct {
    var title: String
    var text: NSMutableAttributedString
    var logo: UIImageView?

    init(welcomeType: WelcomeType) {
        logo = UIImageView()
        logo?.tintColor = .white
        text = NSMutableAttributedString()
        switch welcomeType {
        case .intro:
            title = "Bienvenue"
            text.append(NSAttributedString(string: "Merci d'avoir téléchargé Helmee, voici un petit didacticiel pour vous présenter ses nombreuses fonctionnalités"))
            logo = UIImageView(image: #imageLiteral(resourceName: "startWelcome"))
        case .end:
            title = "Lancez-vous !"
            text.append(NSAttributedString(string: "Vous êtes maintenant prêt à poser une question et aider les utilisateurs d'Helmee"))
            logo = UIImageView(image: #imageLiteral(resourceName: "rocketWelcome"))
        case .question:
            title = "Les questions"
            text.append(NSAttributedString(string: "Un principe simple, vous vous posez une question et vous n'avez pas la réponse ? Vous possédez 150 crédits au départ. Vous pouvez poser des questions localisées sur une carte, associées à une catégorie bien définie en dépensant ces crédits. Les personnes se situant dans la zone de votre question, ou ayant renseignée cette zone pourront répondre à votre question."))
            logo = UIImageView(image: #imageLiteral(resourceName: "questionsWelcome"))
        case .places:
            title = "Mes zones"
            text.append(NSAttributedString(string: "En plus de votre position actuelle, vous pouvez définir des zones bien connues à vos yeux pour lesquelles vous vous sentez capable de répondre à une question"))
            logo = UIImageView(image: #imageLiteral(resourceName: "zoneWelcome"))
        case .news:
            title = "Fil d'actualité"
            text.append(NSAttributedString(string: "Helmee possède un fil d'actualité vous permettant de consulter les questions du moment les plus répondues, les questions les plus récentes. Vous pouvez ainsi voir ce qu'il se passe dans le monde entier !"))
            logo = UIImageView(image: #imageLiteral(resourceName: "newsWelcome"))
        case .report:
            title = "Signalement"
            text.append(NSAttributedString(string: "Vous avez la possibilité d'accepter une réponse à votre question si elle vous parait correcte. L'auteur de la réponse recevra le nombre de crédits que vous avez dépensé pour cette question. Vous pouvez aussi signaler chaque réponse que vous voyez si elle vous paraît très inappropriée ou abusive"))
            logo = UIImageView(image: #imageLiteral(resourceName: "reportWelcome"))
        }
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 15
        style.alignment = .justified
        text.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSRange(location: 0, length: text.length))
        let font = UIFont.systemFont(ofSize: 16)
        text.addAttribute(NSFontAttributeName, value: font, range: NSRange(location: 0, length: text.length))
        text.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: NSRange(location: 0, length: text.length))
    }
}

class WelcomeViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    private var welcomeViewControllers: [UIViewController] = []
    private var pageControl = UIPageControl()
    private var indexPresented = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageViewController()
        setupDismissButton()
        setupPageControl()
        self.delegate = self
        self.dataSource = self
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var i = 0
        for p in welcomeViewControllers {
            if viewController == p {
                return i != 0 ? welcomeViewControllers[i - 1] : nil
            }
            i += 1
        }
        return UIViewController()
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var i = 0
        for p in welcomeViewControllers {
            if viewController == p {
                return i != welcomeViewControllers.count - 1 ? welcomeViewControllers[i + 1] : nil
            }
            i += 1
        }
        return UIViewController()
    }

    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        var i = 0
        for p in welcomeViewControllers {
            if pendingViewControllers[0] == p {
                indexPresented = i
            }
            i += 1
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        pageControl.currentPage = indexPresented
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.bringSubview(toFront: pageControl)
    }

    private func setupPageControl() {
        pageControl = UIPageControl(frame: CGRect(x: 0, y: view.frame.height - 40, width: view.frame.size.width, height: 40))
        pageControl.currentPage = 0
        pageControl.numberOfPages = welcomeViewControllers.count
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.pageIndicatorTintColor = UIColor.lightGray.withAlphaComponent(0.2)
        pageControl.backgroundColor = .clear
        pageControl.isUserInteractionEnabled = false
        view.addSubview(pageControl)
    }

    private func setupPageViewController() {
        welcomeViewControllers.append(WelcomeTextViewController(welcomeType: .intro))
        welcomeViewControllers.append(WelcomeTextViewController(welcomeType: .question))
        welcomeViewControllers.append(WelcomeTextViewController(welcomeType: .places))
        welcomeViewControllers.append(WelcomeTextViewController(welcomeType: .news))
        welcomeViewControllers.append(WelcomeTextViewController(welcomeType: .report))
        welcomeViewControllers.append(WelcomeTextViewController(welcomeType: .end))
        setViewControllers([welcomeViewControllers[0]], direction: .forward, animated: true, completion: nil)
    }

    private func setupDismissButton() {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "cancel"))
        let dismissButton = UIButton(frame: imageView.frame)
        dismissButton.setImage(imageView.image, for: .normal)
        dismissButton.tintColor = .white
        dismissButton.addTarget(self, action: #selector(dismissPageViewController(_:)), for: .touchUpInside)
        view.addSubview(dismissButton)
        dismissButton.pinToSuperview(edges: [.right,.top], insets: UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 20))
    }

    @objc private func dismissPageViewController(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "introSkipped")
        dismiss(animated: true, completion: nil)
    }
}
