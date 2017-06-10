//
//  AnswersViewController.swift
//  Helmee
//
//  Created by Antoine Payan on 06/08/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import UIKit
import Alamofire

protocol AnswerTableViewCellDelegate: class {
    func didForceTouchAnswer(_ answer: Answer)
}

enum State {
    case validation
    case rejection
    case unknown
}

class AnswersViewController: UIViewController,
UITableViewDataSource,
UITableViewDelegate,
AnswerTableViewCellDelegate,
AnswerViewContract
{

    @IBOutlet weak var placeholder: UIStackView!
    @IBOutlet weak var reactStackView: UIStackView!
    @IBOutlet weak var tableView: UITableView!

    private var factory: Factory
    private var answerSelected: Answer?
    private var validateAnswer = UIButton()
    private var rejectAnswer = UIButton()
    private var cancelSelection = UIButton()
    private var question: Question?
    private var state: State

    lazy private var answerRepository: AnswerRepository = self.factory.getAnswerRepository(viewContract: self)

    init(question: Question?, factory: Factory) {
        self.factory = factory
        self.question = question
        state = .unknown
        super.init(nibName: "AnswersViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "cancel"), style: .plain, target: self, action: #selector(dismissView))
        navigationItem.rightBarButtonItem?.tintColor = UIColor(hexString: Texts.mainColor)
        title = "Réponses"
        automaticallyAdjustsScrollViewInsets = false

    }

    //MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let answers = question?.answers else { return 0 }
        placeholder.isHidden = !answers.isEmpty
        return answers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "answerTableViewCell", for: indexPath) as? AnswerTableViewCell,
        let answers = question?.answers else { return UITableViewCell() }
        cell.configure(answer: answers[indexPath.row], delegate: self)
        return cell

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let answers = question?.answers else {
                return 44.0
        }
        let font = UIFont(name: "Helvetica Neue", size: 17.0) ?? UIFont()
        let answer = answers[indexPath.row]
        let height = answer.text.height(withConstrainedWidth: tableView.frame.size.width * 0.8, font: font)
        return height + 45.0
    }

    //MARK: - AnswerViewContract

    func answerValidated() {
        guard let question = question else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        answerRepository.refreshAnswers(for: question)
    }

    func handleValidateAnswerError(_ error: HTTPError) {
        showSimpleAlertWithMessage(title: Texts.oups, message: error.message)
    }

    func answerRejected() {
        guard let question = question else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        answerRepository.refreshAnswers(for: question)
    }

    func handleRejectAnswerError(_ error: HTTPError) {
        showSimpleAlertWithMessage(title: Texts.oups, message: error.message)
    }

    func answersRefreshed(_ answers: [Answer]) {
        question?.answers = answers
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }

    func handleAnswersRefreshError(_ error: HTTPError) {
        showSimpleAlertWithMessage(title: Texts.oups, message: error.message)
    }

    //MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            state != .unknown,
            let cell = tableView.cellForRow(at: indexPath) as? AnswerTableViewCell else {
                return
        }
        for visibleCell in tableView.visibleCells {
            if let visibleCell = visibleCell as? AnswerTableViewCell {
                visibleCell.setOriginalColor()
            }
        }
        guard let answer = cell.answer, !answer.accepted, !answer.rejected else { return }
        cell.setBackground(with: state == .validation ? UIColor(hexString: Texts.greenColor).withAlphaComponent(0.6) : UIColor(hexString: Texts.redColor).withAlphaComponent(0.6))
        answerSelected = answer
        if state == .validation {
            validateAnswer.isEnabled = true
        } else if state == .rejection {
            rejectAnswer.isEnabled = true
        }
    }

    //MARK: - AnswerTableViewCellDelegate

    func didForceTouchAnswer(_ answer: Answer) {
        answerSelected = answer
        highlightCell(for: answer)
    }

    func presentAlert(answer: Answer) {
        guard let question = question else { return }
        let alertController = UIAlertController(title: "Choisissez votre action", message: "", preferredStyle: .actionSheet)
        if !question.accepted {
            alertController.addAction(UIAlertAction(title: "Valider", style: .default, handler: { _ in
                self.showLoader()
                self.answerRepository.validate(answer)
            }))
        }
        alertController.addAction(UIAlertAction(title: "Signaler", style: .default, handler: { _ in

        }))
        alertController.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: { _ in
            UIView.animate(withDuration: 0.5, animations: {
                self.resetCells()
                self.tableView.contentOffset = .zero
            })
        }))
        UIView.animate(withDuration: 0.5, animations: {
            self.present(alertController, animated: false)
            guard let answers = self.question?.answers else { return }
            var i = 0
            for a in answers {
                if a.id == answer.id {
                    let indexPath = IndexPath(row: i, section: 0)
                    self.tableView.setContentOffset(self.getContentOffset(for: indexPath), animated: true)
                }
                i += 1
            }

        })
    }

    //MARK: - Private

    private func setupView() {
        let nib = UINib(nibName: "AnswerTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "answerTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        edgesForExtendedLayout = []



        validateAnswer.setTitle("Valider", for: .normal)
        validateAnswer.setTitleColor(.white, for: .normal)
        validateAnswer.setBackgroundColor(UIColor(hexString: Texts.greenColor), forState: .normal)
        validateAnswer.addTarget(self, action: #selector(enterValidationState(_:)), for: .touchUpInside)
        validateAnswer.layer.cornerRadius = 4.0
        validateAnswer.clipsToBounds = true

        reactStackView.distribution = .fillEqually
        reactStackView.clipsToBounds = true

        rejectAnswer.setTitle("Signaler", for: .normal)
        rejectAnswer.setTitleColor(.white, for: .normal)
        rejectAnswer.setBackgroundColor(UIColor(hexString: Texts.redColor), forState: .normal)
        rejectAnswer.addTarget(self, action: #selector(enterRejectionState(_:)), for: .touchUpInside)
        rejectAnswer.layer.cornerRadius = 4.0
        rejectAnswer.clipsToBounds = true

        cancelSelection.setTitle("Annuler", for: .normal)
        cancelSelection.setTitleColor(.white, for: .normal)
        cancelSelection.setBackgroundColor(UIColor(hexString: Texts.mainColor), forState: .normal)
        cancelSelection.addTarget(self, action: #selector(cancelSelectionAction(_:)), for: .touchUpInside)
        cancelSelection.layer.cornerRadius = 4.0
        cancelSelection.clipsToBounds = true
        cancelSelection.isHidden = true

        reactStackView.addArrangedSubview(rejectAnswer)
        reactStackView.addArrangedSubview(validateAnswer)
        reactStackView.addArrangedSubview(cancelSelection)

        guard let question = question else { return }
        if question.accepted {
            validateAnswer.isEnabled = false
        }
    }

    @objc private func enterValidationState(_ sender: Any) {
        if state == .validation {
            showLoader()
            guard let answerSelected = answerSelected else { return }
            answerRepository.validate(answerSelected)
            state = .unknown
            setStackViewButtons(enabled: true)
        } else {
            state = .validation
            setStackViewButtons(enabled: false)
            presentAlertInformation(text: "Cliquez sur la réponse que vous souhaitez valider, attention, cette action est irréversible")
        }
    }

    @objc private func enterRejectionState(_ sender: Any) {
        if state == .rejection {
            showLoader()
            guard let answerSelected = answerSelected else { return }
            answerRepository.reject(answerSelected)
            state = .unknown
            setStackViewButtons(enabled: true)
        } else {
            state = .rejection
            setStackViewButtons(enabled: false)
            presentAlertInformation(text: "Cliquez sur la réponse que vous souhaitez rejeter, attention, cette action est irréversible")
        }
    }

    @objc private func dismissView() {
        navigationController?.dismiss(animated: true, completion: nil)
    }

    private func highlightCell(for answer: Answer) {
        hideCellsPartially()
        guard let answers = question?.answers else { return }
        var i = 0
        for a in answers {
            if a.id == answer.id {
                let indexPath = IndexPath(row: i, section: 0)
                guard let cell = tableView.cellForRow(at: indexPath) as? AnswerTableViewCell else { return }
                cell.alpha = 1.0
                cell.setEffectOnMessageView(transform: true) {
                    self.presentAlert(answer: answer)
                }
            }
            i += 1
        }
    }

    private func hideCellsPartially() {
        for visibleCell in tableView.visibleCells {
            guard let cell = visibleCell as? AnswerTableViewCell else { return }
            cell.alpha = 0.6
            cell.setEffectOnMessageView(transform: false, callback: {})
        }
    }

    private func resetCells() {
        for visibleCell in tableView.visibleCells {
            guard let cell = visibleCell as? AnswerTableViewCell else { return }
            cell.alpha = 1.0
            cell.setEffectOnMessageView(transform: false, callback: {})
            cell.reset()
        }
    }

    private func getContentOffset(for indexPath: IndexPath) -> CGPoint {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return .zero
        }
        let difference = cell.frame.origin.y - tableView.frame.origin.y + 20
        return CGPoint(x: 0, y: difference)
    }

    private func setStackViewButtons(enabled: Bool) {

        rejectAnswer.isEnabled = enabled
        cancelSelection.isHidden = enabled
        validateAnswer.isEnabled = enabled
        guard let question = question else { return }
        if question.accepted {
            validateAnswer.isEnabled = false
        }
    }

    @objc private func cancelSelectionAction(_ sender: Any) {
        rejectAnswer.isEnabled = true
        cancelSelection.isHidden = true
        validateAnswer.isEnabled = true
        guard let question = question else { return }
        if question.accepted {
            validateAnswer.isEnabled = false
        }
        tableView.reloadData()
    }

    private func presentAlertInformation(text: String) {
        let alertController = UIAlertController(title: "Encore une étape", message: text, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alertController, animated: true)
    }

    private func showSimpleAlertWithMessage(title: String, message: String!) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let cancel = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(cancel)
        if self.presentedViewController == nil {
            self.present(alertController, animated: true, completion: nil)
        }
    }

    private func showLoader() {
        let alert = UIAlertController(title: nil, message: Texts.waiting, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: { _ in
            Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
                sessionDataTask.forEach { $0.cancel() }
                uploadData.forEach { $0.cancel() }
                downloadData.forEach { $0.cancel() }
            }
        }))
        alert.view.tintColor = UIColor.black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect.init(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        alert.view.addSubview(loadingIndicator)
        self.present(alert, animated: true, completion: nil)
    }

}
