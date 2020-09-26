//
//  PremiumViewController.swift
//  tomorrow
//
//  Created by Russell Ong on 26/9/20.
//  Copyright © 2020 trillion.unicorn. All rights reserved.
//

import UIKit

class PremiumViewController: UIViewController {

    @IBOutlet weak var navCloseBtn: UIBarButtonItem!
    @IBOutlet weak var mostPopularView: UIView!
    @IBOutlet weak var mostFlexibleView: UIView!
    @IBOutlet weak var pricingStackView: UIStackView!
    
    @IBOutlet weak var mostPopularLabel: UILabel!
    @IBOutlet weak var mostFlexibleLabel: UILabel!
    
    var feedbackGenerator : UISelectionFeedbackGenerator? = nil
    var isYearly: Bool = true
    var viewBeingSelected = UIView()
    var viewBeingUnselected = UIView()
    
    var labelBeingSelected = UILabel()
    var labelBeingUnselected = UILabel()
    
    let selectedBgColor: UIColor = UIColor(red: 0.94, green: 0.20, blue: 0.20, alpha: 1.00)
    let unselectedBgColor: UIColor = UIColor(red: 0.87, green: 0.90, blue: 0.91, alpha: 1.00)
    
    var tap = UITapGestureRecognizer()
    
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var restoreBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        isYearly = !isYearly
        
        feedbackGenerator?.selectionChanged()
        feedbackGenerator?.prepare()

        if isYearly {
            viewBeingSelected = mostPopularView
            viewBeingUnselected = mostFlexibleView
            labelBeingSelected = mostPopularLabel
            labelBeingUnselected = mostFlexibleLabel
        } else {
            viewBeingSelected = mostFlexibleView
            viewBeingUnselected = mostPopularView
            labelBeingSelected = mostFlexibleLabel
            labelBeingUnselected = mostPopularLabel
        }
        
        labelBeingUnselected.textColor = .white
        labelBeingUnselected.textColor = .black
        
        viewBeingUnselected.addGestureRecognizer(tap)
        
        UIView.animate(withDuration: 0.1, animations: { [weak self] in
            self?.viewBeingSelected.transform = CGAffineTransform(scaleX: 1.03, y: 1.03)
            self?.labelBeingSelected.backgroundColor = self?.selectedBgColor
            self?.labelBeingUnselected.backgroundColor = self?.unselectedBgColor
        }) { (finished) in
            UIView.animate(withDuration: 0.05, animations: {
                self.viewBeingSelected.transform = CGAffineTransform.identity
            })
        }
    }
    
    fileprivate func setupUI(){
        pricingStackView.layoutMargins = UIEdgeInsets(top: 12, left: 8, bottom: 0, right: 8)
        pricingStackView.isLayoutMarginsRelativeArrangement = true
        
        navCloseBtn.tintColor = selectedBgColor
        mostPopularView.layer.cornerRadius = 16
        mostFlexibleView.layer.cornerRadius = 16
        mostPopularView.clipsToBounds = true
        mostFlexibleView.clipsToBounds = true
        
        mostPopularLabel.backgroundColor = selectedBgColor
        mostFlexibleLabel.backgroundColor = unselectedBgColor
        
        continueBtn.backgroundColor = selectedBgColor
        continueBtn.layer.cornerRadius = 8
        
        restoreBtn.setTitleColor(selectedBgColor, for: .normal)
    }
    
    fileprivate func setupGestures() {
        feedbackGenerator = UISelectionFeedbackGenerator()
        feedbackGenerator?.prepare()
        tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        mostFlexibleView.addGestureRecognizer(tap)
    }
    
    @IBAction func onTapClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
