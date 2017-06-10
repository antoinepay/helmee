//
//  CategoryChoiceViewController.swift
//  Helmee
//
//  Created by Antoine Payan on 09/07/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import UIKit
import QuartzCore

class CategoryChoiceViewController: UIViewController, iCarouselDelegate, iCarouselDataSource {

    @IBOutlet weak private var sendQuestion: UIButton!
    @IBOutlet weak private var categoryTitle: UILabel!
    @IBOutlet weak private var carousel: iCarousel!
    
    private var question: Question?
    private var delegate: MapQuestionTextDelegate
    
    init(delegate: MapQuestionTextDelegate, question: Question?) {
        self.delegate = delegate
        self.question = question
        super.init(nibName: "CategoryChoiceViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let user = User.verifyUserArchived()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "cancel"), style: .plain, target: self, action: #selector(dismissView))
        setupCollectionView()
        title = "La catégorie"
    }
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return user.categories.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        if let cell = view as? CategoryCollectionViewCell {
            cell.configureInit(category: user.categories[index])
            return cell
        } else {
            guard let cell = Bundle.main.loadNibNamed("CategoryCollectionViewCell", owner: nil, options: nil)?.first as? CategoryCollectionViewCell else { return UICollectionViewCell() }
            cell.configureInit(category: user.categories[index])
            return cell
        }
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if option == .visibleItems {
            return 4
        } else if option == .spacing {
            return value * 2
        } else if option == .angle {
            return value * 0.7
        } else if option == .fadeMin {
            return value * 2
        } else if option == .radius {
            return value * 1.5
        }
        return value
    }
    
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        for visible in carousel.visibleItemViews {
            guard let cell = visible as? CategoryCollectionViewCell else { return }
            cell.disableCell()
        }
        guard let cell = carousel.itemView(at: carousel.currentItemIndex) as? CategoryCollectionViewCell else { return }
        cell.configure(category: user.categories[carousel.currentItemIndex])
        categoryTitle.text = user.categories[carousel.currentItemIndex].title
        categoryTitle.textColor = UIColor(hexString: user.categories[carousel.currentItemIndex].color)
        sendQuestion.isEnabled = true
    }
    
    private func setupCollectionView() {
        carousel.type = .cylinder
        carousel.delegate = self
        carousel.dataSource = self
        categoryTitle.text = ""
        edgesForExtendedLayout = []
        sendQuestion.tintColor = UIColor(hexString: Texts.mainColor)
        sendQuestion.setTitle("Envoyer ma question", for: .normal)
        sendQuestion.addTarget(self, action: #selector(send), for: .touchUpInside)
        sendQuestion.isEnabled = false
    }
    
    @objc private func send() {
        navigationController?.dismiss(animated: true, completion: { _ in
            guard
                let cellSelected = self.carousel.currentItemView as? CategoryCollectionViewCell,
                var question = self.question,
                let category = cellSelected.category else {
                return
            }
            question.category = category
            self.delegate.send(question: question)
        })
    }
    
    @objc private func dismissView() {
        navigationController?.dismiss(animated: true, completion: nil)
    }

}
