//
//  WeatherEntity.swift
//  NABChallenge
//
//  Created by user on 8/24/20.
//  Copyright © 2020 Sang Nguyen. All rights reserved.
//

import Foundation

extension WeatherEntity {
    func update(date: Date,
                temperature: Double,
                pressure: Int,
                humidity: Int,
                descriptionString: String) {
        self.date = date
        self.temperature = temperature
        self.pressure = Int16(pressure)
        self.humidity = Int16(humidity)
        self.descriptionString = descriptionString
    }
}
