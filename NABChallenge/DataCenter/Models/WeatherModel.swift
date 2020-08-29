//
//  WeatherModel.swift
//  NABChallenge
//
//  Created by user on 8/23/20.
//  Copyright © 2020 Sang Nguyen. All rights reserved.
//

import UIKit

struct WeatherModel {
    var date: Date
    var temperature: Double
    var pressure: Int
    var humidity: Int
    var descriptionString: String
}

extension WeatherModel {
    init(info: OpenWeatherMapModels.List) {
        self.date = Date(timeIntervalSince1970: TimeInterval(info.dt))
        self.temperature = info.temp.average
        self.pressure = info.pressure
        self.humidity = info.humidity
        self.descriptionString = info.weather.compactMap({ $0.description }).joined(separator: ", ")
    }
}

extension OpenWeatherMapModels.Temp {
    var average: Double {
        return (self.day + self.night + self.morn + self.eve) / 4.0
    }
}


extension WeatherModel {
    static func create(from entity: WeatherEntity) -> WeatherModel? {
        guard let date = entity.date else {
            return nil
        }
        return WeatherModel(date: date,
                            temperature: entity.temperature,
                            pressure: Int(entity.pressure),
                            humidity: Int(entity.humidity),
                            descriptionString: entity.descriptionString ?? "")
    }
}
