//
//  ViewController.swift
//  Helmee
//
//  Created by Antoine Payan on 10/06/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import UIKit

class HomeViewController: SharedViewController, LoginViewContract, UITextFieldDelegate {

    @IBOutlet weak private var signInButton: UIButton!
    @IBOutlet weak private var loginView: UIView!
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var password: UITextField!
    @IBOutlet weak private var username: UITextField!
    
    lazy private var loginRepository: LoginRepository = self.factory.getLoginRepository(viewContract: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerKeyboardNotifications()
        if !UserDefaults.standard.bool(forKey: "introSkipped") {
            present(WelcomeViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [:]), animated: true)
            return
        }
        if let message = UserDefaults.standard.string(forKey: "errorMessage") {
            showSimpleAlertWithMessage(title: Texts.error, message: message)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterKeyboardNotifications()
    }
    
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardDidShow(notification:)),
                                               name: NSNotification.Name.UIKeyboardDidShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
    }
    
    func unregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func keyboardDidShow(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height+80, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag: NSInteger = textField.tag + 1;
        if nextTag==1 {
            password.becomeFirstResponder();
        } else if nextTag == 2 {
            signInAction(self)
        }
        else {
            textField.resignFirstResponder()
        }
        return false
    }
    
    @IBAction func signInAction(_ sender: Any) {
        guard let usernameText = username.text,
            let passwordText = password.text else {
                return
        }
        loginRepository.login(username: usernameText, password: passwordText)
    }
    @IBAction func presentWelcome(_ sender: Any) {
        let welcomeViewController = WelcomeViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [:])
        present(welcomeViewController, animated: true)
    }
    
    func login(_ user: User) {
        let data = NSKeyedArchiver.archivedData(withRootObject: user)
        UserDefaults.standard.set(data, forKey: "user")
        UserDefaults.standard.synchronize()
        DispatchQueue.main.async {
            let tabBarController = TabBarViewController(factory: self.factory)
            tabBarController.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
            self.present(tabBarController, animated: true, completion: nil)
            (UIApplication.shared.delegate as! AppDelegate).launchTimerConnection()
        }
    }
    
    func handleLoginError(_ error: HTTPError) {
        showSimpleAlertWithMessage(title: Texts.oups, message: error.message)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func setupView() {
        username.delegate = self
        password.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        
        disableButton()
        
        loginView.layer.cornerRadius = 5.0
        loginView.layer.borderColor = UIColor.black.cgColor
        loginView.layer.borderWidth = 1.0
        
        signInButton.setBackgroundColor(.gray, forState: .selected)
        signInButton.setBackgroundColor(.gray, forState: .highlighted)
        signInButton.backgroundColor = .gray
        signInButton.layer.cornerRadius = 5.0
        signInButton.clipsToBounds = true
    }
    
    private func activateButton() {
        signInButton.isEnabled=true
        signInButton.isSelected=false
        signInButton.setBackgroundColor(.white, forState: .normal)
        signInButton.setTitleColor(UIColor(hexString: Texts.mainColor), for: .normal)
    }
    
    private func disableButton() {
        signInButton.isEnabled = false;
        signInButton.isSelected = true;
        signInButton.setBackgroundColor(.gray, forState: .normal)
        signInButton.setTitleColor(.lightGray, for: .normal)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField.tag==0) {
            if(string=="" && (textField.text?.characters.count)! <= 1) {
                disableButton();
                return true;
            } else if (string==" ") {
                return false;
            } else {
                if(!(password.text?.isEmpty)!) {
                    activateButton();
                }
                return true;
            }
        } else {
            if(string=="" && (textField.text?.characters.count)! <= 1) {
                disableButton()
                return true
            } else if (string==" ") {
                return false;
            } else {
                if(!(username.text?.isEmpty)!){
                    activateButton()
                }
                return true;
            }
        }
    }

}

