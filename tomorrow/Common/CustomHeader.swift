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
        title.font = UIFont.systemFont(ofSize: 60)
        title.numberOfLines = 0
        contentView.addSubview(title)

        // Center the image vertically and place it near the leading
        // edge of the view. Constrain its width and height to 50 points.
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
