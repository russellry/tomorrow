//
//  GrowingCell.swift
//  GrowingCellTextView
//
//  Created by SwiftDevCenter on 12/03/19.
//  Copyright © 2019 SwiftDevCenter. All rights reserved.
//

import UIKit
import CoreData

protocol CellDynamicHeightProtocol: class {
    func updateHeightOfRow(_ cell: EntryTableViewCell, _ textView: UITextView)
}

protocol SaveSelectedCellProtocol: class {
    func saveSelectedCell(_ cell: EntryTableViewCell, text: String)
}

class EntryTableViewCell: UITableViewCell {
    
    weak var rowHeightDelegate: CellDynamicHeightProtocol?
    weak var selectedCellDelegate: SaveSelectedCellProtocol?
    
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if let delegate = rowHeightDelegate {
            delegate.updateHeightOfRow(self, textView)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let delegate = selectedCellDelegate {
            delegate.saveSelectedCell(self, text: textView.text)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let delegate = rowHeightDelegate {
            delegate.updateHeightOfRow(self, textView)
        }
    }
    
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if text == "\n" {
//
//            return false
//        }
//        return true
//    }
}
