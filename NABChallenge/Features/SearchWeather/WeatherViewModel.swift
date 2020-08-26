//
//  WeatherViewModel.swift
//  NABChallenge
//
//  Created by user on 8/23/20.
//  Copyright © 2020 Sang Nguyen. All rights reserved.
//

import UIKit

class WeatherViewModel {
    var weatherModel: WeatherModel
    public private(set) var dateFormated: String = ""
    
    static var dateFormater: DateFormatter = {
        let formater = DateFormatter()
        formater.dateFormat = "EEE, dd MMM yyyy"
        return formater
    }()
    
    required init(weatherModel: WeatherModel) {
        self.weatherModel = weatherModel
        
        self.dateFormated = WeatherViewModel.dateFormater.string(from: weatherModel.date)
    }
}

extension WeatherViewModel: WeatherViewCellProtocol {
    var date: String {
        return "Date:  \(dateFormated)"
    }
    
    var temperature: String {
        let temp = Int(round(weatherModel.temperature))
        return "Average Temperature:  \(temp)°C"
    }
    
    var pressure: String {
        return "Pressure:  \(weatherModel.pressure)"
    }
    
    var humidity: String {
        return "Humidity:  \(weatherModel.humidity)%"
    }
    
    var descriptionString: String {
        return "Description:  \(weatherModel.descriptionString)"
    }
}
