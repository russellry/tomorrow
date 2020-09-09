//
//  ImmutableEntryTableViewCell.swift
//  tomorrow
//
//  Created by Russell Ong on 10/9/20.
//  Copyright © 2020 trillion.unicorn. All rights reserved.
//

import UIKit

class ImmutableEntryTableViewCell: UITableViewCell {

    @IBOutlet weak var labelView: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
