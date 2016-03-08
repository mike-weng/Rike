//
//  PageViewController.swift
//  Rike
//
//  Created by Mike Weng on 2/22/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    var postOptions = [UIViewController]()
    var currentPage = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        let albumViewController = self.storyboard?.instantiateViewControllerWithIdentifier("AlbumViewController") as! AlbumViewController
        let cameraViewController = self.storyboard?.instantiateViewControllerWithIdentifier("CameraViewController") as! CameraViewController
        postOptions.append(albumViewController)
        postOptions.append(cameraViewController)
        self.setViewControllers([albumViewController], direction: .Forward, animated: true, completion: nil)


        // Do any additional setup after loading the view.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if currentPage == 0 {
                currentPage = 1
            } else {
                currentPage = 0
            }
        }
        let parentViewController = self.parentViewController as! EditPostViewController
        let pageIndicator = parentViewController.pageIndicator as UIPageControl
        pageIndicator.currentPage = currentPage
        pageIndicator.updateCurrentPageDisplay()
    }
    
    func pageViewController(pageViewController: UIPageViewController,
        viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
            let previousIndex = postOptions.indexOf(viewController)! as Int - 1
            if previousIndex <= 0 {
                return nil
            }
            print("page1")
            return postOptions[previousIndex]
    }
    
    func pageViewController(pageViewController: UIPageViewController,
        viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
            let nextIndex = postOptions.indexOf(viewController)! as Int + 1
            if nextIndex >= postOptions.endIndex {
                return nil
            }
            
            
            print("page2")
            return postOptions[nextIndex]
    }
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return postOptions.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }

}
