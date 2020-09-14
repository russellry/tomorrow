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

protocol SelectNextCellProtocol: class {
    func selectNextPossibleCell(_ cell: EntryTableViewCell)
}

protocol DeleteEmptyCellDataProtocol: class {
    func deleteEmptyCellData(_ cell: EntryTableViewCell)
}

protocol TapCheckboxProtocol: class {
    func selectCheckbox(_ cell: EntryTableViewCell)
}

class EntryTableViewCell: UITableViewCell {
    
    weak var rowHeightDelegate: CellDynamicHeightProtocol?
    weak var selectedCellDelegate: SaveSelectedCellProtocol?
    weak var selectNextPossibleCellDelegate: SelectNextCellProtocol?
    weak var deleteEmptyCellDataDelegate: DeleteEmptyCellDataProtocol?
    weak var selectCheckboxDelegate: TapCheckboxProtocol?
    
    @IBOutlet weak var checkbox: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.delegate = self
        //Default value: https://developer.apple.com/documentation/uikit/uitextview/1618619-textcontainerinset
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func onTapCheckbox(_ sender: Any) {
        selectCheckboxDelegate?.selectCheckbox(self)
    }
    
    func setCheckboxImage(entry: Entry) {
        if entry.done {
            self.checkbox.setBackgroundImage(UIImage(systemName: "largecircle.fill.circle"), for: .normal)
        } else {
            self.checkbox.setBackgroundImage(UIImage(systemName: "circle"), for: .normal)
        }
    }
}

extension EntryTableViewCell: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        NSLog("Start Editing")
        //TODO: when it begins, whole cell should be visible. TODO: leave it for now
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        deleteEmptyCellDataDelegate?.deleteEmptyCellData(self)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let delegate = selectedCellDelegate {
            delegate.saveSelectedCell(self, text: textView.text)
        }
        
        if let delegate = rowHeightDelegate {
            delegate.updateHeightOfRow(self, textView)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if let delegate = selectNextPossibleCellDelegate {
                delegate.selectNextPossibleCell(self)
            }
            return false
        }
        return true
    }
}
