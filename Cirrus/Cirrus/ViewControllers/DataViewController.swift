//
//  DataViewController.swift
//  Cirrus
//
//  Created by Chayel Heinsen on 11/15/15.
//  Copyright © 2015 Chayel Heinsen. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON
import FloatingActionSheetController
import SwiftLocation

class DataViewController: UIViewController {

    var location: CLLocation = CLLocation(latitude: 0, longitude: 0)
    
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var day0: WeatherConditionView!
    @IBOutlet weak var day1: WeatherConditionView!
    @IBOutlet weak var day2: WeatherConditionView!
    @IBOutlet weak var day3: WeatherConditionView!
    @IBOutlet weak var day4: WeatherConditionView!
    @IBOutlet weak var day5: WeatherConditionView!
    
    @IBOutlet var visualEffectViewTopConstraint: NSLayoutConstraint! // -20 to show, -100 to hide
    @IBOutlet var textfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Inserts Background Gradient
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        
        let color1 = UIColor(red: 1, green: 1, blue: 1, alpha: 0).CGColor as CGColorRef
        let color2 = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4).CGColor as CGColorRef
        gradientLayer.colors = [color1, color2]
        
        self.view.layer.insertSublayer(gradientLayer, atIndex: 0)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "addNewLocation")
        self.view.addGestureRecognizer(tap)
        
        if location.coordinate.latitude == 0 && location.coordinate.longitude == 0 {
            
            do {
                try SwiftLocation.shared.currentLocation(.City, timeout: 30, onSuccess: { (location) -> Void in
                    
                        if let location = location {
                            self.location = location
                            self.fetchWeather()
                        }
                    },
                    onFail: { (error) -> Void in
                        
                })
            } catch {
                
            }
        } else {
            self.fetchWeather()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func fetchWeather() {
        Sweather.sharedManager.forecast(location.coordinate, callback: { (result) -> () in
            //print(result.data())
            
            if let data = result.data() {
                let json = JSON(data)
                
                if let list = json["list"].arrayObject {
                    //print(list)
                    
                    var conditions: [WeatherCondition] = []
                    var units = ""
                    
                    switch Sweather.sharedManager.temperatureFormat {
                    case .Fahrenheit:
                        units = "us"
                    case .Celsius:
                        units = ""
                    }
                    
                    for weather in list {
                        let date = NSDate(timeIntervalSince1970: NSTimeInterval(weather["dt"] as! Int))
                        
                        if !NSCalendar.currentCalendar().isDateInToday(date) {
                            
                            let c = WeatherCondition(degrees: weather["main"]!!["temp_max"] as! Double, units: units, icon: weather["weather"]!![0]["id"] as! Int, time: weather["dt"] as! Int)
                            
                            if conditions.count == 0 {
                                conditions.append(c)
                            } else {
                                
                                let results = conditions.filter({$0.day == c.day})
                                
                                if results.isEmpty {
                                    conditions.append(c)
                                }
                            }
                        }
                    }
                    
                    let days = [self.day1, self.day2, self.day3, self.day4, self.day5]
                    
                    for i in 0...4 {
                        let day = days[i]
                        let wtr = conditions[i]
                        
                        if day.day != nil {
                            day.day.text = wtr.day
                        }
                        
                        day.icon.text = wtr.iconChar
                        day.degree.text = "\(wtr.degrees)\(wtr.unit)"
                    }
                }
            }
            
        })
        
        Sweather.sharedManager.currentWeather(location.coordinate, callback: { (result) -> () in
            
            if let data = result.data() {
                //print(data)
                var units = ""
                
                let json = JSON(data)
                
                switch Sweather.sharedManager.temperatureFormat {
                case .Fahrenheit:
                    units = "us"
                case .Celsius:
                    units = ""
                }
                
                let condition = WeatherCondition(degrees: json["main"]["temp"].double!, units: units, icon: json["weather"][0]["id"].int!, time: json["dt"].int!)
                
                self.city.text = json["name"].string
                
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.view.backgroundColor = condition.color
                })
                
                self.day0.icon.text = condition.iconChar
                self.day0.degree.text = "\(condition.degrees)\(condition.unit)"
            }
        })
    }
    
    func addNewLocation() {
        
        let action1 = FloatingAction(title: "New City") { action in
            UIView.animateWithDuration(0.5, delay: 1.5, options: .CurveLinear, animations: { () -> Void in
                self.visualEffectViewTopConstraint.constant = -20
                }, completion: { (done) -> Void in
                    
                    if done {
                        self.textfield.becomeFirstResponder()
                    }
            })
            
        }
        
//        let action2 = FloatingAction(title: "title") { action in
//            // Do something.
//        }
        
        let action3 = FloatingAction(title: "Cancel") { action in }
        
        let group1 = FloatingActionGroup(action: action1/*, action2*/)
        let group2 = FloatingActionGroup(action: action3)
        
        let actionSheet = FloatingActionSheetController(actionGroup: group1, group2, animationStyle: .SlideUp)
        
        // Color of action sheet
        //actionSheet.itemTintColor = .whiteColor()
        // Color of title texts
        //actionSheet.textColor = .blackColor()
        // Font of title texts
        actionSheet.font = .boldSystemFontOfSize(18)
        // background dimming color
        //actionSheet.dimmingColor = UIColor(white: 1, alpha: 0.7)
        
        actionSheet.present(self)
        
//        let alertController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
//        let newCity: UIAlertAction = UIAlertAction(title: "New City", style: .Default) { (action) -> Void in
//            
//        }
//        
//        let cancel: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
//        
//        alertController.addAction(newCity)
//        alertController.addAction(cancel)
//        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - IBActions
    
    @IBAction func addCity(sender: UIButton) {
        self.textfield.resignFirstResponder()
        
        UIView.animateWithDuration(0.5) { () -> Void in
            self.visualEffectViewTopConstraint.constant = -100
        }
        
        SwiftLocation.shared.reverseAddress(.Apple, address: self.textfield.text!, region: nil, onSuccess: { (place) -> Void in
            let location: CLLocation = place!.location!
            NSNotificationCenter.defaultCenter().postNotificationName("MakeNewPage", object: nil, userInfo: ["location" : location])
            }, onFail: nil)
    }
}

