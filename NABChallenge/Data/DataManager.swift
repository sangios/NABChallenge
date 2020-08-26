//
//  DataManager.swift
//  NABChallenge
//
//  Created by user on 8/24/20.
//  Copyright © 2020 Sang Nguyen. All rights reserved.
//

import UIKit
import CoreData

protocol DataManagerProtocol {
    typealias SearchCompletion = (OpenWeatherMapAPI.SearchFilter, CityModel?, [WeatherModel], Error?) -> Void
    
    func search(_ filter: OpenWeatherMapAPI.SearchFilter,
                completion: @escaping SearchCompletion)
}


class DataManager {
    static let shared = DataManager()
    private var api: OpenWeatherMapAPIProtocol
    
    init(api: OpenWeatherMapAPIProtocol = OpenWeatherMapAPI()) {
        self.api = api
    }
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Data")
        let description = NSPersistentStoreDescription()
        description.type = NSSQLiteStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { description, error in
            if let error = error {
                NSLog("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    func loadWeather(for city: String) -> (city: CityEntity?, weathers: [WeatherEntity]) {
        let context = persistentContainer.viewContext
        let citiesFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "CityEntity")
        let predicate = NSPredicate(format: "name BEGINSWITH[cd] %@", city)
        citiesFetch.predicate = predicate

        do {
            guard let cities = try context.fetch(citiesFetch) as? [CityEntity] else {
                return (nil, [])
            }
            guard let city = cities.first else {
                return (nil, [])
            }
            guard let weathers = city.weathers?.allObjects as? [WeatherEntity] else {
                return (city, [])
            }
            return (city, weathers)
        } catch {
            NSLog("Failed to fetch cites: \(error)")
        }
        
        return (nil, [])
    }
    
    func removeUselessWeathers() {
        let startOfDate = Date().startOfDate()
        
        let context = persistentContainer.viewContext
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "WeatherEntity")
        let predicate = NSPredicate(format: "date < %@", startOfDate as NSDate)
        fetch.predicate = predicate

        do {
            guard let entities = try context.fetch(fetch) as? [WeatherEntity] else {
                return
            }
            remove(entities: entities)
        } catch {
            NSLog("Failed to fetch cites: \(error)")
        }
    }
    
    func remove(entities: [WeatherEntity]) {
        guard entities.count > 0 else { return }
        let context = persistentContainer.viewContext
        entities.forEach { (entity) in
            context.delete(entity)
        }
        save(context: context)
    }
    
    func save(searchResult: OpenWeatherMapModels.SearchResult) {
        let context = persistentContainer.viewContext
        
        var city: CityEntity
        let list = self.loadWeather(for: searchResult.city.name)
        if let existCity = list.city {
            city = existCity
        } else {
            city = CityEntity(context: context)
        }
        city.update(from: searchResult.city)
        
        remove(entities: list.weathers)
        
        searchResult.list.forEach { (item) in
            let model = WeatherModel(info: item)
            let entity = WeatherEntity.init(context: context)
            entity.update(from: model)
            entity.city = city
        }
        
        save(context: context)
    }
    
    func clearAll() {
        
    }
    
    func save(context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            NSLog("SAVE DATA ERROR \(error.localizedDescription)")
        }
    }
}

extension DataManager: DataManagerProtocol {
    func search(_ filter: OpenWeatherMapAPI.SearchFilter,
                completion: @escaping SearchCompletion) {
        
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            let results = self.loadWeather(for: filter.cityName)
            let startSecondsOfDate = Date().startSecondsOfDate()
            var uselessEntities = [WeatherEntity]()
            var shouldCallAPI = true
            
            let list = results.weathers.compactMap { (entity) -> WeatherModel? in
                guard let date = entity.date else {
                    uselessEntities.append(entity)
                    return nil
                }
                guard date.timeIntervalSince1970 >= startSecondsOfDate else {
                    uselessEntities.append(entity)
                    return nil
                }
                return WeatherModel.create(from: entity)
            }
            let cityModel = CityModel.create(from: results.city)
            
            switch list.count {
            case filter.forecastDays...:
                shouldCallAPI = false
                DispatchQueue.main.async {
                    completion(filter, cityModel, list, nil)
                }
            case 1..<filter.forecastDays:
                DispatchQueue.main.async {
                    completion(filter, cityModel, list, nil)
                }
            default:
                break
            }
            
            if shouldCallAPI {
                self.api.search(filter) { [unowned self] (searchResults, error) in
                    guard let results = searchResults else {
                        DispatchQueue.main.async {
                            completion(filter, nil, [], error)
                        }
                        return
                    }
                    let list = results.list.compactMap { (item) -> WeatherModel? in
                        return WeatherModel(info: item)
                    }
                    let city = CityModel(name: searchResults?.city.name ?? "No Name")
                    
                    DispatchQueue.main.async {
                        completion(filter, city, list, error)
                    }
                    
                    self.save(searchResult: results)
                }
            }
            
            self.remove(entities: uselessEntities)
        }
    }
}
