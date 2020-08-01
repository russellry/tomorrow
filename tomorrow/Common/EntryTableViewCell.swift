//
//  GrowingCell.swift
//  GrowingCellTextView
//
//  Created by SwiftDevCenter on 12/03/19.
//  Copyright © 2019 SwiftDevCenter. All rights reserved.
//

import UIKit

protocol CellDynamicHeightProtocol: class {
    func updateHeightOfRow(_ cell: EntryTableViewCell, _ textView: UITextView)
}

class EntryTableViewCell: UITableViewCell {
    
    weak var rowHeightDelegate: CellDynamicHeightProtocol?
    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.delegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension EntryTableViewCell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if let deletate = rowHeightDelegate {
            deletate.updateHeightOfRow(self, textView)
        }
    }
}
