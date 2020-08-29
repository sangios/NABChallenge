//
//  DataManager.swift
//  NABChallenge
//
//  Created by user on 8/24/20.
//  Copyright © 2020 Sang Nguyen. All rights reserved.
//

import UIKit

protocol DataManagerProtocol {
    typealias SearchCompletion = (String, CityModel?, [WeatherModel], Error?) -> Void
    
    func search(_ searchKey: String, completion: @escaping SearchCompletion)
}


class DataManager {
    static let shared = DataManager(api: OpenWeatherMapAPI(), database: Database.shared)
    
    private var api: OpenWeatherMapAPIProtocol
    private var database: DatabaseProtocol
    
    init(api: OpenWeatherMapAPIProtocol, database: DatabaseProtocol) {
        self.api = api
        self.database = database
    }
    
    func removeUnusedWeathers() {
        database.removeUnusedWeathers()
    }
    
    func save(city: CityModel, weathers: [WeatherModel]) {
        let dataInDB = self.database.loadWeathers(for: city.name)
        let cityEntity = self.database.updateCity(dataInDB.city, from: city)
        
        self.database.remove(weathers: dataInDB.weathers)
        self.database.add(weathers: weathers, for: cityEntity)
    }
}

extension DataManager: DataManagerProtocol {
    func search(_ searchKey: String, completion: @escaping SearchCompletion) {
        
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            let results = self.database.loadWeathers(for: searchKey)
            let startSecsOfDate = Date().startSecondsOfDate()
            var shouldCallAPI = true
            
            let list = results.weathers.compactMap { (entity) -> WeatherModel? in
                guard let date = entity.date else { return nil }
                guard date.timeIntervalSince1970 >= startSecsOfDate else { return nil }
                return WeatherModel.create(from: entity)
            }
            let cityModel = CityModel.create(from: results.city)
            
            let filter = OpenWeatherMapAPI.SearchFilter(cityName: searchKey)
            
            switch list.count {
            case filter.forecastDays...:
                shouldCallAPI = false
                DispatchQueue.main.async {
                    completion(searchKey, cityModel, list, nil)
                }
            case 1..<filter.forecastDays:
                DispatchQueue.main.async {
                    completion(searchKey, cityModel, list, nil)
                }
            default:
                break
            }
            
            if shouldCallAPI {
                self.api.search(filter) { [unowned self] (searchResults, error) in
                    guard let results = searchResults else {
                        DispatchQueue.main.async {
                            completion(searchKey, nil, [], error)
                        }
                        return
                    }
                    let weathers = results.list.compactMap {
                        return WeatherModel(info: $0)
                    }
                    let city = CityModel(info: results.city)
                    
                    DispatchQueue.main.async {
                        completion(searchKey, city, weathers, error)
                    }
                    
                    self.save(city: city, weathers: weathers)
                }
            }
        }
    }
}
