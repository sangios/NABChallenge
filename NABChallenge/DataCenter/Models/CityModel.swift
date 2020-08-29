//
//  CityModel.swift
//  NABChallenge
//
//  Created by user on 8/24/20.
//  Copyright © 2020 Sang Nguyen. All rights reserved.
//

import UIKit

struct CityModel {
    var id: Int
    var name: String
    var lat: Double
    var long: Double
    var country: String
    var population: Int
    var timezone: Int
}

extension CityModel {
    init(info city: OpenWeatherMapModels.City) {
        self.id = city.id
        self.country = city.country
        self.name = city.name
        self.population = city.population
        self.lat = city.coord.lat
        self.long = city.coord.lon
        self.timezone = city.timezone
    }
}

extension CityModel {
    static func create(from entity: CityEntity?) -> CityModel? {
        guard let entity = entity else { return nil }
        return CityModel(id: Int(entity.id),
                         name: entity.name ?? "Unknown",
                         lat: entity.lat,
                         long: entity.long,
                         country: entity.country ?? "Unknown",
                         population: Int(entity.population),
                         timezone: Int(entity.timezone))
    }
}
