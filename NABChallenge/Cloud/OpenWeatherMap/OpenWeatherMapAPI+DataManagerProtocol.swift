//
//  OpenWeatherMapAPI+DataManagerProtocol.swift
//  NABChallenge
//
//  Created by user on 8/30/20.
//  Copyright © 2020 Sang Nguyen. All rights reserved.
//

import Foundation

extension OpenWeatherMapAPI: DataManagerProtocol {
    func save(city: CityModel, weathers: [WeatherModel]) {
        
    }
    
    func removeUnusedWeathers() {
        
    }
    
    func search(_ searchKey: String, forecastDays: Int, completion: @escaping DataManagerProtocol.SearchCompletion) {
        
        let filter = OpenWeatherMapAPI.SearchFilter(cityName: searchKey, forecastDays: forecastDays)
        
        self.search(filter) { (searchResults, error) in
            guard let results = searchResults else {
                completion(searchKey, nil, [], error)
                return
            }
            let weathers = results.list.compactMap {
                return WeatherModel(info: $0)
            }
            let city = CityModel(info: results.city)
            
            completion(searchKey, city, weathers, error)
        }
    }
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
