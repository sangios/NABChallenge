//
//  WeatherSearchViewModel.swift
//  NABChallenge
//
//  Created by user on 8/23/20.
//  Copyright © 2020 Sang Nguyen. All rights reserved.
//

import UIKit

class WeatherSearchViewModel: WeatherSearchViewModelProtocol {
    public var forecastDays: Int = 7
    public var tempUnit = OpenWeatherMapAPI.TemperatureUnit.Metric
    
    public private(set) var filter = OpenWeatherMapAPI.SearchFilter()

    private var weatherViewModels = [WeatherViewModel]()
        
    private var error: Error?
    private var city: CityModel?
    
    private var dataManager: DataManagerProtocol
    
    var changeHandler: UpdateHandler?
    
    init(dataManager: DataManagerProtocol = DataManager.shared) {
        self.dataManager = dataManager
    }
    
    func search(city: String) {
        let filter = OpenWeatherMapAPI.SearchFilter(cityName: city, forecastDays: forecastDays, tempUnit: tempUnit)
        self.filter = filter
        
        guard city.count >= 3 else {
            self.error = nil
            self.city = nil
            self.weatherViewModels = []
            self.changeHandler?()
            return
        }
        
        self.dataManager.search(filter) { [weak self] (filter, city, searchResults, error) in
            guard let self = self else { return }
            guard self.filter == filter else { return }
            
            self.city = city
            self.error = error
            self.update(with: searchResults)
            
            self.changeHandler?()
        }
    }
    
    private func update(with searchResults: [WeatherModel]) {
        let list = searchResults.compactMap { (model) -> WeatherViewModel? in
            let viewModel = WeatherViewModel(weatherModel: model)
            return viewModel
        }
        self.weatherViewModels = list
    }
}

extension WeatherSearchViewModel {
    var count: Int {
        return weatherViewModels.count
    }
    
    subscript (index: Int) -> WeatherViewModel? {
        guard index >= 0, index < weatherViewModels.count else { return nil }
        return weatherViewModels[index]
    }
    
    var cityName: String {
        return city?.name ?? ""
    }
    
    var errorMessage: String? {
        return error?.localizedDescription
    }
}
