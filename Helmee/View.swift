//
//  View.swift
//  Helmee
//
//  Created by Antoine Payan on 11/06/2017.
//  Copyright © 2017 Antoine Payan. All rights reserved.
//

import UIKit

extension UIView {
    /*func pinToSuperview() {
        guard let superview = self.superview else { return }
        topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
        leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
    }*/
    
    func pinStackHorizontal() {
        guard let superview = self.superview else { return }
        topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
    }
    
    func pinCenterView() {
        guard let superview = self.superview else { return }
        centerXAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: superview.centerYAnchor).isActive = true
    }
    
    func pinLeading() {
        guard let superview = self.superview else { return }
        leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
    }

    @objc(pinToSuperview) public func pinToSuperview() {
        pinToSuperview(edges: .all, insets: .zero)
    }

    @objc(pinToSuperviewWithEdges:) public func pinToSuperview(edges: UIRectEdge) {
        pinToSuperview(edges: edges, insets: .zero)
    }

    @objc(pinToSuperviewWithInsets:) public func pinToSuperview(insets: UIEdgeInsets) {
        pinToSuperview(edges: .all, insets: insets)
    }

    @objc(pinToSuperviewWithEdges:insets:) public func pinToSuperview(edges: UIRectEdge, insets: UIEdgeInsets) {
        guard let superview = self.superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        if edges.contains(.top) {
            ad_pinTo(view: superview, attribute: .top, constant: insets.top)
        }
        if edges.contains(.left) {
            ad_pinTo(view: superview, attribute: .left, constant: insets.left)
        }
        if edges.contains(.bottom) {
            ad_pinTo(view: superview, attribute: .bottom, constant: -insets.bottom)
        }
        if edges.contains(.right) {
            ad_pinTo(view: superview, attribute: .right, constant: -insets.right)
        }
    }

    //MARK: - Private

    private func ad_pinTo(view: UIView, attribute: NSLayoutAttribute, constant: CGFloat) {
        view.addConstraint(
            NSLayoutConstraint(
                item: self,
                attribute: attribute,
                relatedBy: .equal,
                toItem: view,
                attribute: attribute,
                multiplier: 1.0,
                constant: constant
            )
        )
    }
}
