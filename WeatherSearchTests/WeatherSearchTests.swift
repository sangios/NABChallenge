//
//  WeatherSearchTests.swift
//  Weather SearchTests
//
//  Created by user on 8/26/20.
//  Copyright © 2020 Sang Nguyen. All rights reserved.
//

import XCTest
@testable import Weather_Search

class WeatherSearchAPIMock: OpenWeatherMapAPIProtocol {
    var input: OpenWeatherMapAPI.SearchFilter!
    var output: (OpenWeatherMapModels.SearchResult?, Error?)!
    
    func search(_ filter: OpenWeatherMapAPI.SearchFilter, completion: @escaping SearchCompletion) {
        guard input == filter else {
            completion(nil, nil)
            return
        }
        completion(output.0, output.1)
    }
}

class DataManagerMock: DataManagerProtocol {
    var api: OpenWeatherMapAPIProtocol
    init(api: OpenWeatherMapAPIProtocol) {
        self.api = api
    }
    
    func search(_ filter: OpenWeatherMapAPI.SearchFilter, completion: @escaping SearchCompletion) {
        api.search(filter) { (result, error) in
            let cityModel = CityModel(name: result?.city.name ?? "")
            let list = result?.list.compactMap { (item) -> WeatherModel? in
                return WeatherModel(info: item)
            } ?? []
            completion(filter, cityModel, list, error)
        }
    }
}

class WeatherSearchTests: XCTestCase {
    
    var weatherSearchVM: WeatherSearchViewModel!
    var dataManager: DataManagerMock!
    var weatherSearchAPI: WeatherSearchAPIMock!

    override func setUpWithError() throws {
        weatherSearchAPI = WeatherSearchAPIMock()
        dataManager = DataManagerMock(api: weatherSearchAPI)
        weatherSearchVM = WeatherSearchViewModel(dataManager: dataManager)
    }

    override func tearDownWithError() throws {

    }

    func testSearchHaveResults() throws {
        let json = "{\"city\":{\"id\":1580578,\"name\":\"Ho Chi Minh City\",\"coord\":{\"lon\":106.6667,\"lat\":10.8333},\"country\":\"VN\",\"population\":0,\"timezone\":25200},\"cod\":\"200\",\"message\":3.4701156,\"cnt\":7,\"list\":[{\"dt\":1598414400,\"sunrise\":1598395434,\"sunset\":1598440009,\"temp\":{\"day\":31,\"min\":28.64,\"max\":31,\"night\":28.64,\"eve\":31,\"morn\":31},\"feels_like\":{\"day\":34.88,\"night\":31.22,\"eve\":34.88,\"morn\":34.88},\"pressure\":1005,\"humidity\":74,\"weather\":[{\"id\":500,\"main\":\"Rain\",\"description\":\"light rain\",\"icon\":\"10d\"}],\"speed\":4.36,\"deg\":249,\"clouds\":40,\"pop\":0.47,\"rain\":0.14},{\"dt\":1598500800,\"sunrise\":1598481834,\"sunset\":1598526375,\"temp\":{\"day\":32.17,\"min\":26.27,\"max\":34.35,\"night\":27.72,\"eve\":33.13,\"morn\":26.27},\"feels_like\":{\"day\":33.99,\"night\":30.76,\"eve\":35.26,\"morn\":30.27},\"pressure\":1008,\"humidity\":59,\"weather\":[{\"id\":500,\"main\":\"Rain\",\"description\":\"light rain\",\"icon\":\"10d\"}],\"speed\":4.99,\"deg\":249,\"clouds\":87,\"pop\":0.93,\"rain\":2.31},{\"dt\":1598587200,\"sunrise\":1598568233,\"sunset\":1598612740,\"temp\":{\"day\":31.41,\"min\":25.9,\"max\":34.22,\"night\":28.13,\"eve\":34.02,\"morn\":25.9},\"feels_like\":{\"day\":33.58,\"night\":30.66,\"eve\":35.76,\"morn\":29.6},\"pressure\":1007,\"humidity\":61,\"weather\":[{\"id\":804,\"main\":\"Clouds\",\"description\":\"overcast clouds\",\"icon\":\"04d\"}],\"speed\":4.37,\"deg\":252,\"clouds\":100,\"pop\":0.23},{\"dt\":1598673600,\"sunrise\":1598654632,\"sunset\":1598699106,\"temp\":{\"day\":30.99,\"min\":26.21,\"max\":34.62,\"night\":28.04,\"eve\":33.78,\"morn\":26.21},\"feels_like\":{\"day\":33.94,\"night\":31.24,\"eve\":35.76,\"morn\":30.19},\"pressure\":1007,\"humidity\":68,\"weather\":[{\"id\":500,\"main\":\"Rain\",\"description\":\"light rain\",\"icon\":\"10d\"}],\"speed\":4.42,\"deg\":244,\"clouds\":95,\"pop\":0.77,\"rain\":0.94},{\"dt\":1598760000,\"sunrise\":1598741031,\"sunset\":1598785470,\"temp\":{\"day\":31.75,\"min\":25.97,\"max\":34.52,\"night\":28.21,\"eve\":34.52,\"morn\":25.97},\"feels_like\":{\"day\":34.96,\"night\":31.57,\"eve\":36.61,\"morn\":30.94},\"pressure\":1008,\"humidity\":62,\"weather\":[{\"id\":804,\"main\":\"Clouds\",\"description\":\"overcast clouds\",\"icon\":\"04d\"}],\"speed\":3.35,\"deg\":247,\"clouds\":93,\"pop\":0.3},{\"dt\":1598846400,\"sunrise\":1598827430,\"sunset\":1598871835,\"temp\":{\"day\":31.96,\"min\":26.32,\"max\":34.42,\"night\":28.13,\"eve\":33.56,\"morn\":26.32},\"feels_like\":{\"day\":35.53,\"night\":31.5,\"eve\":36.36,\"morn\":30.72},\"pressure\":1008,\"humidity\":60,\"weather\":[{\"id\":500,\"main\":\"Rain\",\"description\":\"light rain\",\"icon\":\"10d\"}],\"speed\":2.56,\"deg\":243,\"clouds\":100,\"pop\":0.69,\"rain\":1.5},{\"dt\":1598932800,\"sunrise\":1598913828,\"sunset\":1598958198,\"temp\":{\"day\":32.66,\"min\":26.5,\"max\":33.59,\"night\":27.84,\"eve\":33.4,\"morn\":26.5},\"feels_like\":{\"day\":36.24,\"night\":31.16,\"eve\":36.5,\"morn\":30.85},\"pressure\":1008,\"humidity\":57,\"weather\":[{\"id\":501,\"main\":\"Rain\",\"description\":\"moderate rain\",\"icon\":\"10d\"}],\"speed\":2.38,\"deg\":244,\"clouds\":60,\"pop\":0.75,\"rain\":4.36}]}"
        
        let searchResult = OpenWeatherMapModels.SearchResult(json)
        let input = OpenWeatherMapAPI.SearchFilter(cityName: searchResult!.city.name, forecastDays: 7, tempUnit: .Metric)
        
        let output: (OpenWeatherMapModels.SearchResult?, Error?) = (searchResult, nil)
        
        weatherSearchAPI.input = input
        weatherSearchAPI.output = output
        
        weatherSearchVM.changeHandler = { [unowned self] in
            self.validateSearchHaveResults()
        }
        weatherSearchVM.search(city: input.cityName)
    }
    
    func testSearchNoResults() throws {
        let error = NSError(domain: "WeatherSearchAPIMock", code: 404, userInfo: [NSLocalizedDescriptionKey : "city not found"])
        
        let input = OpenWeatherMapAPI.SearchFilter(cityName: "saigon1", forecastDays: 7, tempUnit: .Metric)
        
        let output: (OpenWeatherMapModels.SearchResult?, Error?) = (nil, error)
        
        weatherSearchAPI.input = input
        weatherSearchAPI.output = output
        
        weatherSearchVM.changeHandler = { [unowned self] in
            self.validateSearchNoResults()
        }
        weatherSearchVM.search(city: input.cityName)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}

extension WeatherSearchTests {
    func validateSearchHaveResults() {
        let city = weatherSearchVM.cityName
        XCTAssertTrue(city == "Ho Chi Minh City", "City name invalid \(city)")
        
        let count = weatherSearchVM.count
        XCTAssertTrue(count == 7, "Count invalid \(count)")
        
        XCTAssertTrue(weatherSearchVM.errorMessage == nil, "Error invalid \(String(describing: weatherSearchVM.errorMessage))")
        
        // Just validate one item now
        if let item = weatherSearchVM[0] {
            XCTAssertTrue(item.date == "Date:  Wed, 26 Aug 2020", "Date formated invalid [\(item.date)]")
            XCTAssertTrue(item.temperature == "Average Temperature:  30°C", "Temperature invalid [\(item.temperature)]")
            XCTAssertTrue(item.humidity == "Humidity:  74%", "Humidity invalid [\(item.humidity)]")
            XCTAssertTrue(item.pressure == "Pressure:  1005", "Pressure invalid [\(item.pressure)]")
            XCTAssertTrue(item.descriptionString == "Description:  light rain", "descriptionString invalid [\(item.descriptionString)]")
        }
    }
    
    func validateSearchNoResults() {
        let city = weatherSearchVM.cityName
        XCTAssertTrue(city == "", "City name invalid \(city)")
        
        let count = weatherSearchVM.count
        XCTAssertTrue(count == 0, "Count invalid \(count)")
        
        XCTAssertTrue(weatherSearchVM.errorMessage == "city not found", "Error invalid \(String(describing: weatherSearchVM.errorMessage))")
    }
}
