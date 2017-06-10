//
//  AccountCategoryTableViewCell.swift
//  Helmee
//
//  Created by Antoine Payan on 11/06/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import UIKit
import Font_Awesome_Swift

class AccountCategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak private var title: UILabel!
    var enabled: Bool = false
    var category: Category?

    func configure(category: Category, enabled : Bool) {
        title.text = category.title
        selectionStyle = .none
        self.category = category
        self.enabled = enabled
        if enabled {
            logo.image = UIImage(icon: FAType(rawValue: category.image)!, size: CGSize.init(width: 24, height: 24), orientation: UIImageOrientation.up, textColor: UIColor(hexString: category.color), backgroundColor: .clear)
            title.textColor = UIColor(hexString: category.color)
        } else {
            logo.image = UIImage(icon: FAType(rawValue: category.image)!, size: CGSize.init(width: 24, height: 24), orientation: UIImageOrientation.up, textColor: .lightGray, backgroundColor: .clear)
            title.textColor = .lightGray
        }
        
    }
}
