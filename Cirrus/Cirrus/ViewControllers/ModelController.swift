//
//  ModelController.swift
//  Cirrus
//
//  Created by Chayel Heinsen on 11/15/15.
//  Copyright © 2015 Chayel Heinsen. All rights reserved.
//

import UIKit
import CoreLocation

/*
 A controller object that manages a simple model -- a collection of month names.
 
 The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
 It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
 
 There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
 */


class ModelController: NSObject, UIPageViewControllerDataSource {

    var pageLocation: [CLLocation] = []

    override init() {
        super.init()
        // Create the data model.
        pageLocation.append(CLLocation(latitude: 0, longitude: 0))
    }

    func viewControllerAtIndex(index: Int, storyboard: UIStoryboard) -> DataViewController? {
        // Return the data view controller for the given index.
//        if (self.pageLocation.count == 0) || (index >= self.pageLocation.count) {
//            return nil
//        }
        
        if index == 0 {
            let dataViewController = storyboard.instantiateViewControllerWithIdentifier("DataViewController") as! DataViewController
            return dataViewController
        } else {
            let dataViewController = storyboard.instantiateViewControllerWithIdentifier("DataViewController") as! DataViewController
            dataViewController.location = self.pageLocation[index]
            return dataViewController
        }
    }

    func newViewController(storyboard: UIStoryboard, location: CLLocation) -> DataViewController? {
        self.pageLocation.append(location)
        let dataViewController = storyboard.instantiateViewControllerWithIdentifier("DataViewController") as! DataViewController
        dataViewController.location = self.pageLocation.last!
        return dataViewController
    }
    
    func indexOfViewController(viewController: DataViewController) -> Int {
        // Return the index of the given data view controller.
        // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
        return pageLocation.indexOf(viewController.location) ?? NSNotFound
    }

    // MARK: - Page View Controller Data Source

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! DataViewController)
        
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index--
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! DataViewController)
        
        if index == NSNotFound {
            return nil
        }
        
        index++
        
        if index == self.pageLocation.count {
            return nil
        }
        
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
//    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
//        return self.pageLocation.count
//    }
//    
//    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
//        return 0
//    }

}

