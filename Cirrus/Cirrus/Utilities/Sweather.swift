//
//  Sweather.swift
//  Cirrus
//
//  Created by Chayel Heinsen on 11/15/15.
//  Copyright © 2015 Chayel Heinsen. All rights reserved.
//

import Foundation
import CoreLocation

extension String {
    func replace(string:String, replacement:String) -> String {
        return self.stringByReplacingOccurrencesOfString(string,
            withString: replacement,
            options: NSStringCompareOptions.LiteralSearch,
            range: nil)
    }
    
    func replaceWhitespace() -> String {
        return self.replace(" ", replacement: "+")
    }
}

public class Sweather {
    public enum TemperatureFormat: String {
        case Celsius = "metric"
        case Fahrenheit = "imperial"
    }
    
    public enum Result {
        case Success(NSURLResponse!, NSDictionary!)
        case Error(NSURLResponse!, NSError!)
        
        public func data() -> NSDictionary? {
            switch self {
            case .Success(_, let dictionary):
                return dictionary
            case .Error(_, _):
                return nil
            }
        }
        
        public func response() -> NSURLResponse? {
            switch self {
            case .Success(let response, _):
                return response
            case .Error(let response, _):
                return response
            }
        }
        
        public func error() -> NSError? {
            switch self {
            case .Success(_, _):
                return nil
            case .Error(_, let error):
                return error
            }
        }
    }
    
    static let sharedManager: Sweather = Sweather(apiKey: "")
    public var apiKey: String
    public var apiVersion: String
    public var language: String
    public var temperatureFormat: TemperatureFormat
    
    private var queue: NSOperationQueue
    
    private struct Base {
        static let basePath = "http://api.openweathermap.org/data/"
    }
    
    // MARK: - Initialization

    public convenience init(apiKey: String) {
        self.init(apiKey: apiKey, language: "en", temperatureFormat: .Fahrenheit, apiVersion: "2.5")
    }
    
    public convenience init(apiKey: String, temperatureFormat: TemperatureFormat) {
        self.init(apiKey: apiKey, language: "en", temperatureFormat: temperatureFormat, apiVersion: "2.5")
    }
    
    public convenience init(apiKey: String, language: String, temperatureFormat: TemperatureFormat) {
        self.init(apiKey: apiKey, language: language, temperatureFormat: temperatureFormat, apiVersion: "2.5")
    }
    
    public init(apiKey: String, language: String, temperatureFormat: TemperatureFormat, apiVersion: String) {
        self.apiKey = apiKey
        self.temperatureFormat = temperatureFormat
        self.apiVersion = apiVersion
        self.language = language
        self.queue = NSOperationQueue()
    }
    
    // MARK: - Retrieving current weather data
    
    public func currentWeather(cityName: String, callback: (Result) -> ()) {
        call("/weather?q=\(cityName.replaceWhitespace())", callback: callback)
    }
    
    public func currentWeather(coordinate: CLLocationCoordinate2D, callback: (Result) -> ()) {
        let coordinateString = "lat=\(coordinate.latitude)&lon=\(coordinate.longitude)"
        call("/weather?\(coordinateString)", callback: callback)
    }
    
    public func currentWeather(cityId: Int, callback: (Result) -> ()) {
        call("/weather?id=\(cityId)", callback: callback)
    }
    
    // MARK: - Retrieving daily forecast
    
    public func dailyForecast(cityName: String, callback: (Result) -> ()) {
        call("/forecast/daily?q=\(cityName.replaceWhitespace())", callback: callback)
    }
    
    public func dailyForecast(coordinate: CLLocationCoordinate2D, callback: (Result) -> ()) {
        call("/forecast/daily?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)", callback: callback)
        
    }
    
    public func dailyForecast(cityId: Int, callback: (Result) -> ()) {
        call("/forecast/daily?id=\(cityId)", callback: callback)
    }
    
    // MARK: - Retrieving forecast
    
    public func forecast(cityName: String, callback: (Result) -> ()) {
        call("/forecast?q=\(cityName.replaceWhitespace())", callback: callback)
    }
    
    public func forecast(coordinate: CLLocationCoordinate2D, callback:(Result) -> ()) {
        call("/forecast?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)", callback: callback)
    }
    
    public func forecast(cityId: Int, callback: (Result) ->()) {
        call("/forecast?id=\(cityId)", callback: callback)
    }
    
    // MARK: - Retrieving city
    
    public func findCity(cityName: String, callback: (Result) -> ()) {
        call("/find?q=\(cityName.replaceWhitespace())", callback: callback)
    }
    
    public func findCity(coordinate: CLLocationCoordinate2D, callback: (Result) -> ()) {
        call("/find?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)", callback: callback)
    }
    
    // MARK: - Call the api
    
    private func call(method: String, callback: (Result) -> ()) {
        let url = Base.basePath + apiVersion + method + "&APPID=\(apiKey)&lang=\(language)&units=\(temperatureFormat.rawValue)"
        let request = NSURLRequest(URL: NSURL(string: url)!)
        let currentQueue = NSOperationQueue.currentQueue()
        
//        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
//            (data, response, error) -> Void in
//            
//            if error != nil {
//                var error: NSError? = error
//                var dictionary: NSDictionary?
//                
//                if let data = data {
//                    
//                    do {
//                        dictionary = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? NSDictionary
//                    } catch let e as NSError {
//                        error = e
//                    }
//                }
//                
//                currentQueue?.addOperationWithBlock {
//                    var result = Result.Success(response, dictionary)
//                  
//                    if error != nil {
//                        result = Result.Error(response, error)
//                    }
//                    
//                    callback(result)
//                }
//                
//            } else {
//                print(error)
//            }
//        }
//        
//        task.resume()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: queue) { (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            var error: NSError? = error
            var dictionary: NSDictionary?
            
            if let data = data {
                do {
                    dictionary = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? NSDictionary
                } catch let e as NSError {
                    error = e
                }
            }
            currentQueue?.addOperationWithBlock {
                var result = Result.Success(response, dictionary)
                if error != nil {
                    result = Result.Error(response, error)
                }
                callback(result)
            }
        }
    }
}