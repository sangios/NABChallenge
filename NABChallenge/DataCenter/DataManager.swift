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
    
    func search(_ searchKey: String, forecastDays: Int, completion: @escaping SearchCompletion)
    
    func save(city: CityModel, weathers: [WeatherModel])
    func removeUnusedWeathers()
}


class DataManager {
    static let shared = DataManager(api: OpenWeatherMapAPI(), database: Database.shared)
    
    private var api: DataManagerProtocol
    private var database: DataManagerProtocol
    
    init(api: DataManagerProtocol, database: DataManagerProtocol) {
        self.api = api
        self.database = database
    }
    
    func removeUnusedWeathers() {
        database.removeUnusedWeathers()
    }
    
    func save(city: CityModel, weathers: [WeatherModel]) {
        self.database.save(city: city, weathers: weathers)
    }
}

extension DataManager: DataManagerProtocol {
    func search(_ searchKey: String, forecastDays: Int, completion: @escaping SearchCompletion) {
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.database.search(searchKey, forecastDays: forecastDays) { (searchKey, cityModel, list, error) in
                                            
                switch list.count {
                case forecastDays...:
                    DispatchQueue.main.async {
                        completion(searchKey, cityModel, list, nil)
                    }
                    return
                case 1..<forecastDays:
                    DispatchQueue.main.async {
                        completion(searchKey, cityModel, list, nil)
                    }
                default:
                    break
                }
                
                self?.api.search(searchKey, forecastDays: forecastDays) { (searchKey, city, weathers, error) in
                    guard let city = city else {
                        DispatchQueue.main.async {
                            completion(searchKey, nil, [], error)
                        }
                        return
                    }
                    
                    DispatchQueue.main.async {
                        completion(searchKey, city, weathers, error)
                    }
                    
                    self?.save(city: city, weathers: weathers)
                }
            }
        }
    }
}
