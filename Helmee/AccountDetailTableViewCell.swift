//
//  AccountDetailTableViewCell.swift
//  Helmee
//
//  Created by Antoine Payan on 11/06/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import UIKit

class AccountDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var content: UILabel!

    func configure(title: String, content: String, enabled: Bool) {
        self.title.text = title
        self.title.sizeToFit()
        self.title.numberOfLines = 0
        self.title.adjustsFontSizeToFitWidth = true
        self.content.text = content
        self.content.sizeToFit()
        self.content.numberOfLines = 0
        self.content.adjustsFontSizeToFitWidth = true
        isUserInteractionEnabled = enabled
        if enabled {
            accessoryType = .disclosureIndicator
        }
    }

}
