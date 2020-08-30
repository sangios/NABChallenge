//
//  CitiEntity+Ext.swift
//  NABChallenge
//
//  Created by user on 8/25/20.
//  Copyright © 2020 Sang Nguyen. All rights reserved.
//

import Foundation

extension CityEntity {
    func update(id: Int,
                country: String,
                name: String,
                population: Int,
                lat: Double,
                long: Double,
                timezone: Int) {
        self.id = Int32(id)
        self.country = country
        self.name = name
        self.population = Int32(population)
        self.lat = lat
        self.long = long
        self.timezone = Int32(timezone)
    }
}
