//
//  Database+EXT.swift
//  NABChallenge
//
//  Created by user on 8/30/20.
//  Copyright © 2020 Sang Nguyen. All rights reserved.
//

import Foundation
import CoreData

extension Database: DataManagerProtocol {
    func search(_ searchKey: String, forecastDays: Int, completion: @escaping DataManagerProtocol.SearchCompletion) {
        let results = self.loadWeathers(for: searchKey)
        let startSecsOfDate = Date().startSecondsOfDate()
        
        let list = results.weathers.compactMap { (entity) -> WeatherModel? in
            guard let date = entity.date else { return nil }
            guard date.timeIntervalSince1970 >= startSecsOfDate else { return nil }
            return WeatherModel.create(from: entity)
        }
        let cityModel = CityModel.create(from: results.city)
        
        completion(searchKey, cityModel, list, nil)
    }
    
    func save(city: CityModel, weathers: [WeatherModel]) {
        let dataInDB = self.loadWeathers(for: city.name)
        let cityEntity = self.updateCity(dataInDB.city, from: city)
        
        self.remove(weathers: dataInDB.weathers)
        self.add(weathers: weathers, for: cityEntity)
    }
    
    func removeUnusedWeathers() {
        let startOfDate = Date().startOfDate()
        
        let context = persistentContainer.viewContext
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "WeatherEntity")
        let predicate = NSPredicate(format: "date < %@", startOfDate as NSDate)
        fetch.predicate = predicate

        do {
            guard let entities = try context.fetch(fetch) as? [WeatherEntity] else {
                return
            }
            remove(weathers: entities, in: context)
        } catch {
            NSLog("Failed to fetch cites: \(error)")
        }
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

extension WeatherEntity {
    func update(from model: WeatherModel) {
        update(date: model.date,
               temperature: model.temperature,
               pressure: model.pressure,
               humidity: model.humidity,
               descriptionString: model.descriptionString)
    }
}

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

