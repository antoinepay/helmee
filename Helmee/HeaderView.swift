//
//  HeaderView.swift
//  Helmee
//
//  Created by Antoine Payan on 28/08/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import UIKit
import Font_Awesome_Swift

class HeaderView: UITableViewHeaderFooterView {

    private var header: NewsHeaderFooter?
    @IBOutlet weak private var logo: UIImageView!

    func configure(frame: CGRect, header: NewsHeaderFooter) {
        contentView.backgroundColor = header.color
        logo.image = UIImage(icon: FAType.init(rawValue: header.image)!, size: CGSize(width: header.height - 10, height: header.height - 10), orientation: .up, textColor: .white, backgroundColor: .clear)
    }



}
