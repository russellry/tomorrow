//
//  CustomHeader.swift
//  tomorrow
//
//  Created by Russell Ong on 11/9/20.
//  Copyright © 2020 trillion.unicorn. All rights reserved.
//

import UIKit

class CustomHeader: UITableViewHeaderFooterView {
    let title = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureContents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureContents() {
        self.isUserInteractionEnabled = false
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = UIFont(name: "GillSans", size: 60)
        title.textColor = .white
        title.numberOfLines = 0
        title.layer.shadowColor = UIColor.black.cgColor
        title.layer.shadowRadius = 3.0
        title.layer.shadowOpacity = 1.0
        title.layer.shadowOffset = CGSize(width: 4, height: 4)
        title.layer.masksToBounds = false
        contentView.addSubview(title)

        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                   constant: 8),
            title.trailingAnchor.constraint(equalTo:
                   contentView.layoutMarginsGuide.trailingAnchor),
            title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            title.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
