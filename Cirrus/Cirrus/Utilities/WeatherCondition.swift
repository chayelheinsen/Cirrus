//
//  WeatherCondition.swift
//  Cirrus
//
//  Created by Chayel Heinsen on 11/15/15.
//  Copyright © 2015 Chayel Heinsen. All rights reserved.
//

import Foundation
import UIKit

class WeatherCondition {
    
    var degrees: Int
    var unit: String
    var iconChar: String
    var day: String
    var color: UIColor
    
    /**
    * Builds a WeatherCondition from certain API-Data
    * http://bugs.openweathermap.org/projects/api/wiki/Weather_Condition_Codes
    */
    init(degrees: Double, units: String, icon: Int, time: Int) {
        
        self.degrees = Int(degrees)
        
        switch units {
        case "us": self.unit = "°F"
        default: self.unit = "°C"
        }
        
        switch icon {
        case 200...232:             self.iconChar = "\u{f01e}" // Thunderstorm
        case 500...531:             self.iconChar = "\u{f019}" // Rain
        case 600...610:             self.iconChar = "\u{f01b}" // Snow
        case 612...622:             self.iconChar = "\u{f01b}" // Snow
        case 611:                   self.iconChar = "\u{f0b5}" // Sleet
        //case "wind":                self.iconChar = "\u{f050}"
        case 741:                   self.iconChar = "\u{f014}"
        case 800:                   self.iconChar = "\u{f00d}" // Clear Day
        //case 800:                   self.iconChar = "\u{f02e}" // Clear Night
        case 801...804:             self.iconChar = "\u{f013}" // Cloudy
        case 900:                   self.iconChar = "\u{f056}"
        case 906:                   self.iconChar = "\u{f015}" // Hail
        default:                    self.iconChar = "\u{f055}"
        }
        
        let date = NSDate(timeIntervalSince1970: NSTimeInterval(time))
        let dayNumber = NSCalendar.currentCalendar().components(.Weekday, fromDate: date).weekday
        
        switch dayNumber {
        case 1: self.day = "SUN"
        case 2: self.day = "MON"
        case 3: self.day = "TUE"
        case 4: self.day = "WED"
        case 5: self.day = "THU"
        case 6: self.day = "FRI"
        case 7: self.day = "SAT"
        default: self.day = "ERR"
        }
        
        var tempCelsius = degrees
        if unit == "°F" { tempCelsius = (degrees-32)/(9/5) }
        
        switch tempCelsius {
        case (35)...(300): color = UIColor(hue: 10.0/360.0, saturation: 0.74, brightness: 1, alpha: 1)
        case (30)...(35): color = UIColor(hue: 26.0/360.0, saturation: 0.74, brightness: 1, alpha: 1)
        case (20)...(30): color = UIColor(hue: 47.0/360.0, saturation: 0.74, brightness: 1, alpha: 1)
        case (15)...(20): color = UIColor(hue: 144.0/360.0, saturation: 0.70, brightness: 0.71, alpha: 1)
        case (5)...(15): color = UIColor(hue: 180.0/360.0, saturation: 0.65, brightness: 0.74, alpha: 1)
        case (-5)...(5): color = UIColor(hue: 190.0/360.0, saturation: 0.84, brightness: 0.76, alpha: 1)
        default: color = UIColor.blackColor()
        }
    }
    
    
}


