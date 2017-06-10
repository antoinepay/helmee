//
//  AccountViewController.swift
//  Helmee
//
//  Created by Antoine Payan on 11/06/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import UIKit

class AccountViewController: SharedViewController, UITableViewDelegate, UITableViewDataSource, AccountViewContract, CategoryViewContract {

    @IBOutlet weak private var tableView: UITableView!

    lazy private var user: User = User.verifyUserArchived()
    private var categories = [Category]()
    private var newCategories = [Category]()
    private var areCategoriesDifferent = false

    lazy private var accountRepository: AccountRepository = self.factory.getAccountRepository(viewContract: self)
    lazy private var categoryRepository: CategoryRepository = self.factory.getCategoryRepository(viewContract: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        user = User.verifyUserArchived()
        newCategories = user.categories
        showLoader()
        categoryRepository.getCategories()
    }
    
    //MARK: - AccountViewContract

    func valueChanged(_ value: Bool) {
        user.helpInstructions = value
        let data = NSKeyedArchiver.archivedData(withRootObject: user)
        UserDefaults.standard.set(data, forKey: "user")
        UserDefaults.standard.synchronize()
        self.dismiss(animated: true, completion: nil)
    }
    
    func handleValueChangedError(_ error: HTTPError) {
        self.dismiss(animated: true, completion: {
            self.showSimpleAlertWithMessage(title: Texts.error, message: error.localizedDescription)
        })
    }
    
    //MARK: - CategoryRepository
    
    func categoriesFetched(_ categories: [Category]) {
        self.categories = categories
        tableView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
    
    func handleCategoriesError(_ error: HTTPError) {
        self.dismiss(animated: true, completion: {
            self.showSimpleAlertWithMessage(title: Texts.error, message: error.localizedDescription)
        })
    }
    
    func categoriesEdited() {
        user.categories = newCategories
        areCategoriesDifferent = false
        let data = NSKeyedArchiver.archivedData(withRootObject: user)
        UserDefaults.standard.set(data, forKey: "user")
        UserDefaults.standard.synchronize()
        tableView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
    
    func handleCategoriesEditError(_ error: HTTPError) {
        self.dismiss(animated: true, completion: {
            self.newCategories = self.categories
            self.tableView.reloadData()
            self.showSimpleAlertWithMessage(title: Texts.error, message: error.localizedDescription)
        })
    }
    
    //MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 5
        case 1:
            return categories.count
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "accountDetailsCell", for: indexPath) as? AccountDetailTableViewCell {
                switch indexPath.row {
                case 0:
                    cell.configure(title: "Nom d'utilisateur", content: user.username, enabled: false)
                    cell.content.textColor = .lightGray
                    return cell
                case 1:
                    cell.configure(title: "E-mail", content: user.email, enabled: true)
                    return cell
                case 2:
                    cell.configure(title: "Instructions d'aide", content: "", enabled: true)
                    let switchButton = UISwitch()
                    cell.accessoryView = switchButton
                    switchButton.isOn = user.helpInstructions
                    switchButton.addTarget(self, action: #selector(changeHelpInstructions(sender:)), for: .valueChanged)
                    return cell
                case 3:
                    cell.configure(title: "Crédits", content: String(user.credits), enabled: true)
                    let addImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
                        addImage.image = #imageLiteral(resourceName: "add_selected")
                    addImage.tintColor = UIColor(hexString: Texts.creditsColor)
                    cell.accessoryView = addImage
                    return cell
                case 4:
                    cell.configure(title: "Mes zones", content: "", enabled: true)
                    return cell
                default:
                    cell.configure(title: "", content: "", enabled: false)
                    return cell
                }
            } else {
                return UITableViewCell()
            }
        case 1:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "accountCategoriesCell", for: indexPath) as? AccountCategoryTableViewCell {
                var hasCategory = false
                if userHasCategory(category: categories[indexPath.row]) {
                    hasCategory = true
                }
                cell.configure(category: categories[indexPath.row], enabled: hasCategory)
                return cell
            }
            return UITableViewCell()
        default:
            let cell = UITableViewCell()
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = UIColor(hexString: Texts.redColor)
            cell.textLabel?.text = Texts.menuLogout
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewCategories = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 45))
        let titleLabel = UILabel(frame: CGRect(x: 5, y: 8, width: tableView.frame.size.width, height: 20))
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: UIFontWeightLight)
        titleLabel.textColor = .gray
        viewCategories.addSubview(titleLabel)
        switch section {
        case 0:
            titleLabel.text = "Mes coordonnées".uppercased()
        case 1:
            titleLabel.text = "Mes catégories".uppercased()
            let subtitleLabel = UILabel(frame: CGRect(x: 10, y: 25, width: tableView.frame.size.width, height: 20))
            subtitleLabel.text = "(Toucher pour modifier)"
            subtitleLabel.font = UIFont.systemFont(ofSize: 11, weight: UIFontWeightLight)
            subtitleLabel.textColor = .gray
            viewCategories.addSubview(subtitleLabel)
            if areCategoriesDifferent {
                let buttonEdit = UIButton(frame: CGRect(x: tableView.frame.size.width - 110, y: 8, width: 100, height: 32))
                buttonEdit.layer.cornerRadius = 4.0
                buttonEdit.clipsToBounds = true
                buttonEdit.setTitle("Modifier", for: .normal)
                buttonEdit.setTitleColor(.white, for: .normal)
                buttonEdit.setTitleColor(.lightGray, for: .highlighted)
                buttonEdit.setBackgroundColor(UIColor(hexString: Texts.mainColor), forState: .normal)
                buttonEdit.setBackgroundColor(UIColor(hexString: Texts.mainColor).withAlphaComponent(0.9), forState: .highlighted)
                viewCategories.addSubview(buttonEdit)
                buttonEdit.titleLabel?.textAlignment = .center
                buttonEdit.addTarget(self, action: #selector(editCategoriesAction), for: .touchUpInside)
            }
        default:
            break
        }
        return viewCategories
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1:
            return 45
        default:
            return 28
        }
    }
    
    //MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if let cell = tableView.cellForRow(at: indexPath) as? AccountDetailTableViewCell {
                switch indexPath.row {
                case 1:
                    //todo email edit
                    break
                case 4:
                    modalTransitionStyle = .coverVertical
                    navigationController?.pushViewController(PlacesListViewController(factory: factory), animated: true)
                    break
                default:
                    break
                }
            }
            break;
        case 1:
            if let cell = tableView.cellForRow(at: indexPath) as? AccountCategoryTableViewCell {
                if let category = cell.category {
                    if cell.enabled {
                        deleteInNewCategoriesIfFound(category: category)
                    } else {
                        newCategories.append(category)
                    }
                    if areCategoriesSelectedDifferent() {
                        areCategoriesDifferent = true
                    } else {
                        areCategoriesDifferent = false
                    }
                    tableView.reloadData()
                    cell.configure(category: category, enabled: !cell.enabled)
                }
            }
            break;
        default:
            UserDefaults.standard.removeObject(forKey: "user")
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.set(rootViewController: HomeViewController(factory: factory))
        }
    }
    
    private func setupTableView() {
        title = "Mon compte"
        let nibDetail = UINib(nibName: "AccountDetailTableViewCell", bundle: nil)
        tableView.register(nibDetail, forCellReuseIdentifier: "accountDetailsCell")
        let nibCategory = UINib(nibName: "AccountCategoryTableViewCell", bundle: nil)
        tableView.register(nibCategory, forCellReuseIdentifier: "accountCategoriesCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    @objc private func changeHelpInstructions(sender: UISwitch) {
        showLoader()
        accountRepository.changeHelpInstructions(value: sender.isOn)
    }
    
    @objc private func editCategoriesAction() {
        showLoader()
        categoryRepository.editCategories(categories: newCategories)
    }
    
    private func userHasCategory(category: Category) -> Bool {
        for uc in newCategories {
            if uc.id == category.id {
                return true
            }
        }
        return false
    }
    
    private func deleteInNewCategoriesIfFound(category: Category) {
        for newCat in newCategories {
            if newCat.id == category.id {
                newCategories.remove(at: newCategories.index(of: newCat)!)
            }
        }
    }
    
    private func areCategoriesSelectedDifferent() -> Bool {
        var n = 0
        for newCat in newCategories {
            for cat in user.categories {
                if newCat.id == cat.id {
                    n += 1
                }
            }
        }
        if n != user.categories.count || user.categories.count != newCategories.count {
            return true
        }
        return false
    }
}
