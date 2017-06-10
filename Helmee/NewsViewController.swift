//
//  NewsViewController.swift
//  Helmee
//
//  Created by Antoine Payan on 11/06/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import UIKit
import Font_Awesome_Swift

class NewsViewController: SharedViewController, UITableViewDelegate, UITableViewDataSource, NewsViewContract {

    @IBOutlet weak private var tableView: UITableView!

    private var pageViewControllers: [QuestionsContent] = []
    private var strates: [NewsStrate] = []
    private lazy var newsRepository: NewsRepository = self.factory.getNewsRepository(viewContract: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
    }

    override func viewDidAppear(_ animated: Bool) {
        strates.removeAll()
        tableView.reloadData()
        newsRepository.news()
    }

    //MARK: - NewsViewContract

    func newsFetched(_ strates: [NewsStrate]) {
        self.strates = strates
        tableView.reloadData()
    }

    func handleNewsError(_ error: HTTPError) {
        strates = []
        print(error)
    }
    
    //MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return strates.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !strates[indexPath.section].questions.isEmpty else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "emptyNewsTableViewCell", for: indexPath) as?   EmptyNewsTableViewCell {
                switch strates[indexPath.section].header.title {
                case "Les plus répondues":
                    cell.configure(image: #imageLiteral(resourceName: "empty"), text: "Il n'y a pas de questions très actives en ce moment")
                case "Les plus récentes":
                    cell.configure(image: #imageLiteral(resourceName: "empty"), text: "Il n'y a pas de nouvelles questions en ce moment")
                default:
                    cell.configure(image: #imageLiteral(resourceName: "empty"), text: "Pas de questions pour le moment")
                }
                cell.isUserInteractionEnabled = false
                return cell
            }
            return UITableViewCell()
        }
        if let cell = tableView.dequeueReusableCell(withIdentifier: "newsTableViewCell", for: indexPath) as? NewsTableViewCell {
            cell.configure(strate: strates[indexPath.section], factory: factory)
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return strates[section].header.height
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let frame = CGRect(
            x: 0.0,
            y: 0.0,
            width: tableView.frame.size.width,
            height: strates[section].header.height
        )
        if let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerView") as? HeaderView {
            headerCell.configure(frame: frame, header: strates[section].header)
            return headerCell
        }
        return UIView()
    }
    
    //MARK: - Private

    private func setupView() {
        title = "Actualités"
    }

    private func setupTableView() {
        let cellNib = UINib(nibName: "NewsTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "newsTableViewCell")
        let emptyNib = UINib(nibName: "EmptyNewsTableViewCell", bundle: nil)
        tableView.register(emptyNib, forCellReuseIdentifier: "emptyNewsTableViewCell")
        let headerNib = UINib(nibName: "HeaderView", bundle: nil)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "headerView")
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
    }
}
