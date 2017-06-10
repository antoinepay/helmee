//
//  QuestionsContent.swift
//  Helmee
//
//  Created by Antoine Payan on 28/08/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import Foundation

class QuestionsContent: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    private var questions: [Question]
    private var questionViewControllers: [QuestionCircleViewController] = []
    private var indexPresented = 0
    private var pageControl = UIPageControl()
    private var header: NewsHeaderFooter
    private var factory: Factory

    init(strate: NewsStrate, factory: Factory) {
        self.questions = strate.questions
        self.header = strate.header
        self.factory = factory
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [:])
        self.delegate = self
        self.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        questionViewControllers = questions.flatMap { question in
            return QuestionCircleViewController(question: question, factory: factory)
        }
        setupPageControl()
        setViewControllers([questionViewControllers[0]], direction: .forward, animated: true, completion: nil)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        pageControl.frame = CGRect(x: 0, y: view.frame.height - 40, width: view.frame.size.width, height: 40)
        view.bringSubview(toFront: pageControl)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard questionViewControllers.count != 1 else {
            return nil
        }
        var i = 0
        for p in questionViewControllers {
            if viewController == p {
                return i != 0 ? questionViewControllers[i - 1] : questionViewControllers.last
            }
            i += 1
        }
        return UIViewController()
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard questionViewControllers.count != 1 else {
            return nil
        }
        var i = 0
        for p in questionViewControllers {
            if viewController == p {
                return i != questionViewControllers.count - 1 ? questionViewControllers[i + 1] : questionViewControllers.first
            }
            i += 1
        }
        return UIViewController()
    }

    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        var i = 0
        for p in questionViewControllers {
            if pendingViewControllers[0] == p {
                indexPresented = i
            }
            i += 1
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        pageControl.currentPage = indexPresented
    }

    private func setupPageControl() {
        pageControl = UIPageControl(frame: CGRect(x: 0, y: view.frame.height - 40, width: view.frame.size.width, height: 40))
        pageControl.currentPage = 0
        pageControl.numberOfPages = questionViewControllers.count
        pageControl.currentPageIndicatorTintColor = header.color
        pageControl.pageIndicatorTintColor = UIColor.lightGray.withAlphaComponent(0.2)
        pageControl.backgroundColor = .clear
        pageControl.isUserInteractionEnabled = false
        view.addSubview(pageControl)

    }

}
