//
//  PageViewController.swift
//  tomorrow
//
//  Created by Russell Ong on 27/6/20.
//  Copyright © 2020 trillion.unicorn. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController {
    var myViewControllers = [UIViewController]()

    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        
        let homeVC = UIStoryboard(name: "HomeScreen", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController")
        let settingsVC = UIStoryboard(name: "SettingsScreen", bundle: nil).instantiateViewController(withIdentifier: "SettingsViewController")

        myViewControllers.append(homeVC)
        myViewControllers.append(settingsVC)
        
        if let firstViewController = myViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                animated: true,
                completion: { _ in
                    
                    let vc = firstViewController as! HomeViewController
                    vc.homeDelegate = self
             
            })
        }
        
        //TODO: when horizontally scrolling, it breaks when adding completion's delegate to homeviewcontrollerdelegate.
        
    }
}

extension PageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let currentViewController = pageViewController.viewControllers![0] as? HomeViewController {
                currentViewController.homeDelegate = self
            }
        }
    }
}

extension PageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = myViewControllers.firstIndex(of: viewController) else { // >>>>>>
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            return myViewControllers.last
        }
        
        guard myViewControllers.count > previousIndex else {
            return nil
        }


        return myViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = myViewControllers.firstIndex(of: viewController) else { // <<<<<
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = myViewControllers.count
        
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            return myViewControllers.first
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
                
        return myViewControllers[nextIndex]
    }
}

extension PageViewController: HomeViewControllerDelegate {
    func disableHorizontalScroll() {
        dataSource = nil
    }
    
    func enableHorizontalScroll() {
        dataSource = self
    }
    
    
}
