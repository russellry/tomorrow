//
//  HomeViewController.swift
//  tomorrow
//
//  Created by Russell Ong on 17/6/20.
//  Copyright © 2020 trillion.unicorn. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    var isEditingText = false
    var homeDelegate: HomeViewControllerDelegate?
    
    var doneBtn = UIBarButtonItem()
    var addBtn = UIBarButtonItem()

    @IBOutlet weak var navItem: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(clickedDone))
        addBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(clickedAdd))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navItem.setRightBarButton(addBtn, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("disappearing Home")
    }
    
    @objc func clickedDone() {
        toggleBarButton()
        homeDelegate?.enableHorizontalScroll()
    }
    
    @objc func clickedAdd() {
        toggleBarButton()
        homeDelegate?.disableHorizontalScroll()
    }
    
    func toggleBarButton(){
        isEditingText = !isEditingText
        
        if isEditingText {
            navItem.rightBarButtonItem = doneBtn
        } else {
            navItem.rightBarButtonItem = addBtn
        }
    }
}

protocol HomeViewControllerDelegate {
    func disableHorizontalScroll()
    func enableHorizontalScroll()
}
