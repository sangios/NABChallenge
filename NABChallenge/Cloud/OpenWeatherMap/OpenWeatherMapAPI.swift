//
//  OpenWeatherMapAPI.swift
//  NABChallenge
//
//  Created by user on 8/23/20.
//  Copyright © 2020 Sang Nguyen. All rights reserved.
//

import UIKit

protocol OpenWeatherMapAPIProtocol {
    typealias SearchCompletion = (OpenWeatherMapModels.SearchResult?, Error?) -> Void
    
    func search(_ filter: OpenWeatherMapAPI.SearchFilter, completion: @escaping SearchCompletion)
}

class OpenWeatherMapAPI {
    enum TemperatureUnit {
        case Default
        case Metric
        case Imperial
        
        var queryString: String {
            switch self {
            case .Default:
                return "default"
            case .Metric:
                return "metric"
            case .Imperial:
                return "imperial"
            }
        }
        
        var unitString: String {
            switch self {
            case .Default:
                return "Kelvin"
            case .Metric:
                return "Celsius"
            case .Imperial:
                return "Fahrenheit"
            }
        }
    }
    
    struct SearchFilter: Equatable {
        var cityName: String = ""
        var forecastDays: Int = 7
        var tempUnit: TemperatureUnit = .Metric
        
        var toParams: [String: Any] {
            return ["q": cityName,
                    "cnt": forecastDays,
                    "units": tempUnit.queryString]
        }
        
        static func == (lhs: SearchFilter, rhs: SearchFilter) -> Bool {
            guard lhs.cityName.lowercased() == rhs.cityName.lowercased() else {
                return false
            }
            guard lhs.forecastDays == rhs.forecastDays else {
                return false
            }
            guard lhs.tempUnit == rhs.tempUnit else {
                return false
            }
            return true
        }
    }
    
    enum API {
        case search(params: SearchFilter)
        
        var path: String {
            switch self {
            case .search:
                return "/data/2.5/forecast/daily"
            }
        }
        
        var params: [String: Any]? {
            switch self {
            case .search(params: let filter):
                return filter.toParams
            }
        }
        
        func getURL(with host: String) -> URL {
            return URL(string: "\(host)/\(self.path)")!
        }
    }
    
    public private(set) var host = "https://api.openweathermap.org"
    
    private let appID = "60c6fbeb4b93ac653c492ba806fc346d"
    private let apiHelper = APIHelper()
        
    private var defaultParams: [String: Any] {
        return ["appid" : appID]
    }
}


//MARK:- Search
extension OpenWeatherMapAPI: OpenWeatherMapAPIProtocol {
    func search(_ filter: SearchFilter, completion: @escaping OpenWeatherMapAPIProtocol.SearchCompletion) {
        let apiInfo = API.search(params: filter)
        let url = apiInfo.getURL(with: host)
        var params = self.defaultParams
        
        apiInfo.params?.forEach({ (key, value) in
            params[key] = value
        })
        
        apiHelper.get(url: url, params: params) { (result) in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                var errorOccurred: Error?
                
                do {
                    let searchResults = try decoder.decode(OpenWeatherMapModels.SearchResult.self, from: data)
                    completion(searchResults, nil)
                    
                    return
                } catch {
                    errorOccurred = error
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    NSLog("GET \(json)")
                    
                    if let dict = json as? [String: Any] {
                        let code = dict["cod"] as? Int ?? 0
                        let msg = dict["message"] as? String ?? "Unknown error occurred"
                        let userInfo = [NSLocalizedDescriptionKey: msg,
                                        NSLocalizedFailureErrorKey: msg,
                                        NSLocalizedFailureReasonErrorKey: msg]
                        let error = NSError(domain: "OpenWeatherMapAPI", code: code, userInfo: userInfo)
                        
                        errorOccurred = error
                    }
                } catch {
                    errorOccurred = error
                }
                
                completion(nil, errorOccurred)
            case .failure(let error):
                completion(nil, error.underlyingError ?? error)
            }
        }
    }
}

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
