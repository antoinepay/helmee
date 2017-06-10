//
//  EmptyNewsTableViewCell.swift
//  Helmee
//
//  Created by Antoine Payan on 01/09/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import UIKit

class EmptyNewsTableViewCell: UITableViewCell {

    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak private var logo: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(image: UIImage, text: String) {
        emptyLabel.text = text
        logo.image = image
    }
    
}
