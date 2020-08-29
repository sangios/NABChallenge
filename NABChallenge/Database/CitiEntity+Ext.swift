//
//  CitiEntity+Ext.swift
//  NABChallenge
//
//  Created by user on 8/25/20.
//  Copyright © 2020 Sang Nguyen. All rights reserved.
//

import UIKit

extension CityEntity {    
    func update(from city: CityModel) {
        self.id = Int32(city.id)
        self.country = city.country
        self.name = city.name
        self.population = Int32(city.population)
        self.lat = city.lat
        self.long = city.long
        self.timezone = Int32(city.timezone)
    }
}
