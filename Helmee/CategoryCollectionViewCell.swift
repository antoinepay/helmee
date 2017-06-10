    //
//  CategoryCollectionViewCell.swift
//  Helmee
//
//  Created by Antoine Payan on 09/07/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import UIKit
import Font_Awesome_Swift

class CategoryCollectionViewCell: UIView {
    @IBOutlet weak private var image: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    var category: Category?

    func configure(category: Category) {
        self.category = category
        image.image = UIImage(icon: FAType.init(rawValue: category.image)!, size: image.frame.size, orientation: .up, textColor: UIColor(hexString: category.color), backgroundColor: .clear)
    }
    
    func configureInit(category: Category) {
        self.category = category
        image.image = UIImage(icon: FAType.init(rawValue: category.image)!, size: image.frame.size, orientation: .up, textColor: .lightGray, backgroundColor: .clear)
    }
    
    func disableCell() {
        guard let category = category else { return }
        image.image = UIImage(icon: FAType.init(rawValue: category.image)!, size: image.frame.size, orientation: .up, textColor: .lightGray, backgroundColor: .clear)
    }

}
