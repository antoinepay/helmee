//
//  QuestionsViewController.swift
//  Helmee
//
//  Created by Antoine Payan on 11/06/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import UIKit
import Font_Awesome_Swift

class QuestionsViewController: SharedViewController, QuestionViewContract, UITableViewDelegate, UITableViewDataSource {

    private var questions : [Int:[Question]] = [:]
    private var sections: [Int:Int] = [:]
    private var refreshControl = UIRefreshControl()
    
    lazy private var questionRepository: QuestionRepository = self.factory.getQuestionRepository(viewContract: self)
    lazy private var answersTransitioningDelegate = CustomPresentationManager(type: .answers)
    lazy private var answerTransitioningDelegate = CustomPresentationManager(type: .answer)
    
    @IBOutlet weak private var placeholderButton: UIButton!
    @IBOutlet weak private var sectionSegment: UISegmentedControl!
    @IBOutlet weak private var tableView: UITableView!


    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshQuestions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let image = UIImage(icon: .FARefresh, size: CGSize(width: 24, height: 24), orientation: .up, textColor: .white, backgroundColor: .clear)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(refreshQuestions))
        navigationItem.rightBarButtonItem?.tintColor = .white
    }
    
    //MARK: - QuestionViewContract

    func questionsFetched(_ questions: [Question]) {
        self.questions.removeAll()
        sections.removeAll()
        for q in questions{
            self.questions[q.category.id] = []
            sections[q.category.id]=0;
        }
        for q in questions{
            self.questions[q.category.id]?.append(q);
            sections[q.category.id] = sections[q.category.id]!+1;
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.endRefresh()
            //self.dismiss(animated: true, completion: nil)
        }
    }
    
    func handleQuestionsError(_ error: Error) {
        endRefresh()
        dismiss(animated: true, completion: {
            self.showSimpleAlertWithMessage(title: Texts.error, message: error.localizedDescription)
        })
    }
    
    func questionsLocationFetched(_ questions: [Question]) {
        self.questions.removeAll()
        sections.removeAll()
        for q in questions{
            self.questions[q.category.id] = []
            sections[q.category.id]=0;
        }
        for q in questions{
            self.questions[q.category.id]?.append(q);
            sections[q.category.id] = sections[q.category.id]!+1;
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.endRefresh()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func handleQuestionsLocationError(_ error: Error) {
        endRefresh()
        dismiss(animated: true, completion: {
            self.showSimpleAlertWithMessage(title: Texts.error, message: error.localizedDescription)
        })
    }
    
    func questionDeleted() {
        endRefresh()
        dismiss(animated: true, completion: {
            self.showSimpleAlertWithMessage(title: "", message: "La question a bien été supprimée !")
        })
        DispatchQueue.main.async {
            self.questionRepository.getMyQuestions()
        }
    }
    
    func handleQuestionDeletedError(_ error: Error) {
        endRefresh()
        dismiss(animated: true, completion: {
            self.showSimpleAlertWithMessage(title: Texts.error, message: error.localizedDescription)
        })
    }
    
    
    
    //MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        setPlaceholder(visible: sections.count == 0)
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var i = 0
        for value in sections {
            if i == section {
                return value.value
            }
            i = i + 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "myQuestionCell", for: indexPath) as? QuestionTableViewCell {
            var categoryId = 0
            var i = 0
            for value in sections {
                if i == indexPath.section {
                    categoryId = value.key
                }
                i = i + 1
            }
            guard let questionsInSection = questions[categoryId] else {
                return UITableViewCell()
            }
            cell.configure(question: questionsInSection[indexPath.row])
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        let title = UILabel(frame: CGRect.init(x: 60, y: 0, width: Int(view.frame.width/2), height: 40))
        var i = 0
        var color = ""
        var image = 0
        for value in sections {
            if i == section {
                let category = questions[value.key]?[0].category
                title.text = category?.title
                color = (category?.color)!
                image = (category?.image)!
            }
            i = i + 1
        }
        let icone = UIImageView(image: UIImage(icon: FAType.init(rawValue: image)!, size: CGSize(width: 32, height: 32), orientation: UIImageOrientation.up, textColor: UIColor(hexString: color), backgroundColor: .clear))
        
        icone.frame.origin=CGPoint(x: 20, y: 4);
        headerView.backgroundColor = UIColor(hexString: "#FAFAFA")
        headerView.addSubview(title)
        headerView.addSubview(icone)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let cell = tableView.cellForRow(at: indexPath) as? QuestionTableViewCell,
            let question = cell.question else {
            return false
        }
        if question.answered, !question.accepted {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Supprimer", handler: { action in
            guard let cell = tableView.cellForRow(at: action.1) as? QuestionTableViewCell,
            let question = cell.question else { return }
            self.showLoader()
            self.questionRepository.deleteAction(question: question)
            
        })
        return [deleteAction]
    }

    //MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            let cell = tableView.cellForRow(at: indexPath) as? QuestionTableViewCell,
            let question = cell.question else {
                return
        }
        if sectionSegment.selectedSegmentIndex == 0 {
            let answersViewController = AnswersViewController(question: question, factory: factory)
            let navigationController = UINavigationController()
            navigationController.viewControllers = [answersViewController]
            navigationController.modalPresentationStyle = .custom
            navigationController.transitioningDelegate = answersTransitioningDelegate
            present(navigationController, animated: true, completion: nil)
        } else {
            let viewController = AnswerViewController(question: question, factory: factory)
            viewController.modalPresentationStyle = .custom
            viewController.transitioningDelegate = answerTransitioningDelegate
            present(viewController, animated: true, completion: nil)
        }
    }

    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }

    //MARK: - Private
    
    private func setup() {
        title = "Questions"
        sectionSegment.removeAllSegments()
        sectionSegment.insertSegment(withTitle: "Mes questions", at: 0, animated: false)
        sectionSegment.insertSegment(withTitle: "Dans ma zone", at: 1, animated: false)
        sectionSegment.selectedSegmentIndex = 0
        sectionSegment.tintColor = .white
        sectionSegment.addTarget(self, action: #selector(switchSegment(_:)), for: .valueChanged)
        placeholderButton.setTitle("Posez une question", for: .normal)
        placeholderButton.titleLabel?.lineBreakMode = .byWordWrapping
        placeholderButton.titleLabel?.numberOfLines = 0
        placeholderButton.titleLabel?.textAlignment = .center
        placeholderButton.tintColor = UIColor(hexString: Texts.mainColor)
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        let nib = UINib(nibName: "QuestionTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "myQuestionCell")
        tableView.dataSource = self
        tableView.delegate = self
        refreshControl.backgroundColor = UIColor(hexString: Texts.mainColor)
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(refreshQuestions), for: .valueChanged)
        tableView.addSubview(refreshControl)
        tableView.sendSubview(toBack: refreshControl)
    }
    
    @objc private func switchSegment(_ sender: AnyObject) {
        if let sender = sender as? UISegmentedControl {
            if sender.selectedSegmentIndex == 0 {
                placeholderButton.isUserInteractionEnabled = true
                placeholderButton.setTitle("Posez une question", for: .normal)
                placeholderButton.addTarget(self, action: #selector(switchToMapQuestion), for: .touchUpInside)
            } else {
                placeholderButton.isUserInteractionEnabled = false
                placeholderButton.setTitle("Pas de questions dans vos zones, ni près de vous !", for: .normal)
            }
            refreshQuestions()
        }
    }
    
    @objc private func switchToMapQuestion() {
        tabBarController?.selectedIndex = 1
    }
    
    private func setPlaceholder(visible: Bool) {
        placeholderButton.isHidden = !visible
        tableView.tableFooterView = UIView()
    }
    
    private func endRefresh() {
        dismiss(animated: true, completion: { _ in
            self.tableView.layoutIfNeeded()
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        })
    }
    
    @objc private func refreshQuestions() {
        showLoader()
        if sectionSegment.selectedSegmentIndex == 0 {
            questionRepository.getMyQuestions()
        } else {
            questionRepository.getQuestionsLocation()
        }
    }

}
