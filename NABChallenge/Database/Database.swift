//
//  Database.swift
//  NABChallenge
//
//  Created by user on 8/29/20.
//  Copyright © 2020 Sang Nguyen. All rights reserved.
//

import UIKit
import CoreData

protocol DatabaseProtocol {
    func updateCity(_ city: CityEntity?, from model: CityModel) -> CityEntity
    func updateCity(from model: CityModel) -> CityEntity
    
    func loadWeathers(for city: String) -> (city: CityEntity?, weathers: [WeatherEntity])
    
    func add(weathers: [WeatherModel], for city: CityEntity)
    
    func remove(weathers: [WeatherEntity])
    func removeUnusedWeathers()
}

class Database: DatabaseProtocol {
    static let shared = Database()
    
    lazy var persistentContainer: NSPersistentContainer = {
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
    
    func updateCity(_ city: CityEntity?, from model: CityModel) -> CityEntity {
        let context = persistentContainer.viewContext
        
        let newCity = city ?? CityEntity(context: context)
        newCity.update(from: model)
        
        save(context: context)
        
        return newCity
    }
    
    func updateCity(from model: CityModel) -> CityEntity {
        return updateCity(nil, from: model)
    }
    
    func loadWeathers(for city: String) -> (city: CityEntity?, weathers: [WeatherEntity]) {
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
    
    func add(weathers: [WeatherModel], for city: CityEntity) {
        let context = persistentContainer.viewContext
        
        weathers.forEach { (model) in
            let entity = WeatherEntity.init(context: context)
            entity.update(from: model)
            entity.city = city
        }
        
        save(context: context)
    }
    
    func remove(weathers: [WeatherEntity]) {
        remove(weathers: weathers, in: persistentContainer.viewContext)
    }
    
    func remove(weathers: [WeatherEntity], in context: NSManagedObjectContext) {
        guard weathers.count > 0 else { return }
        weathers.forEach { (entity) in
            context.delete(entity)
        }
        save(context: context)
    }
    
    private func save(context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            NSLog("SAVE DATA ERROR \(error.localizedDescription)")
        }
    }
}
