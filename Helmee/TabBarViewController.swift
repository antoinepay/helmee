//
//  TabBarViewController.swift
//  Helmee
//
//  Created by Antoine Payan on 11/06/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    private var factory: Factory
    
    init(factory: Factory) {
        self.factory = factory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let newsNav = UINavigationController()
        let mapNav = UINavigationController()
        let accountNav = UINavigationController()
        let questionsNav = UINavigationController()
        
        let newsViewController = NewsViewController(factory: factory)
        let mapQuestionViewController = MapQuestionViewController(factory: factory)
        let accountViewController = AccountViewController(factory: factory)
        let questionsViewController = QuestionsViewController(factory: factory)
        
        newsNav.viewControllers = [newsViewController]
        accountNav.viewControllers = [accountViewController]
        mapNav.viewControllers = [mapQuestionViewController]
        questionsNav.viewControllers = [questionsViewController]
        newsNav.tabBarItem = UITabBarItem(title: "Actualités", image: #imageLiteral(resourceName: "star"), selectedImage: #imageLiteral(resourceName: "star_selected"))
        mapNav.tabBarItem = UITabBarItem(title: "Nouvelle question", image: #imageLiteral(resourceName: "QuestionZone"), selectedImage: #imageLiteral(resourceName: "QuestionZone_selected"))
        accountNav.tabBarItem = UITabBarItem(title: "Mon compte", image: #imageLiteral(resourceName: "user"), selectedImage: #imageLiteral(resourceName: "user_selected"))
        questionsNav.tabBarItem = UITabBarItem(tabBarSystemItem: .mostViewed, tag: 3)
        
        tabBar.barTintColor = UIColor(hexString: Texts.mainColor)
        tabBar.tintColor = .white
        tabBar.isTranslucent = false
        
        viewControllers = [newsNav, mapNav, questionsNav, accountNav]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
