//
//  NewsTableViewCell.swift
//  Helmee
//
//  Created by Antoine Payan on 11/06/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {

    @IBOutlet weak var pageView: UIView!
    private var pageViewController: QuestionsContent?

    override func prepareForReuse() {
        super.prepareForReuse()
        pageViewController?.view.removeFromSuperview()
    }

    func configure(strate: NewsStrate, factory: Factory) {
        backgroundColor = .clear
        pageViewController = QuestionsContent(strate: strate, factory: factory)
        guard let pageViewController = pageViewController else { return }
        pageView.addSubview(pageViewController.view)
        pageViewController.view.pinToSuperview()
    }

}
