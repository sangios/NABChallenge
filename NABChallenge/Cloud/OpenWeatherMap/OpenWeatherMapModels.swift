//
//  OpenWeatherMapModels.swift
//  NABChallenge
//
//  Created by user on 8/23/20.
//  Copyright © 2020 Sang Nguyen. All rights reserved.
//

import UIKit

struct OpenWeatherMapModels {
    struct SearchResult: Codable {
        let city: City
        let cod: String
        let message: Double
        let cnt: Int
        let list: [List]
    }

    struct City: Codable {
        let id: Int
        let name: String
        let coord: Coord
        let country: String
        let population, timezone: Int
    }

    struct Coord: Codable {
        let lon, lat: Double
    }

    struct List: Codable {
        let dt, sunrise, sunset: Int
        let temp: Temp
        let feelsLike: FeelsLike
        let pressure, humidity: Int
        let weather: [Weather]
        let speed: Double
        let deg, clouds: Int
        let pop: Double
        let rain: Double?

        enum CodingKeys: String, CodingKey {
            case dt, sunrise, sunset, temp
            case feelsLike = "feels_like"
            case pressure, humidity, weather, speed, deg, clouds, pop, rain
        }
    }

    struct FeelsLike: Codable {
        let day, night, eve, morn: Double
    }

    struct Temp: Codable {
        let day, min, max, night: Double
        let eve, morn: Double
    }

    struct Weather: Codable {
        let id: Int
        let main, description, icon: String
    }
}

// MARK: Convenience initializers

extension OpenWeatherMapModels.SearchResult {
    init?(data: Data) {
        guard let me = try? JSONDecoder().decode(OpenWeatherMapModels.SearchResult.self, from: data) else { return nil }
        self = me
    }

    init?(_ json: String, using encoding: String.Encoding = .utf8) {
        guard let data = json.data(using: encoding) else { return nil }
        self.init(data: data)
    }

    init?(fromURL url: String) {
        guard let url = URL(string: url) else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        self.init(data: data)
    }

    var jsonData: Data? {
        return try? JSONEncoder().encode(self)
    }

    var json: String? {
        guard let data = self.jsonData else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

extension OpenWeatherMapModels.City {
    init?(data: Data) {
        guard let me = try? JSONDecoder().decode(OpenWeatherMapModels.City.self, from: data) else { return nil }
        self = me
    }

    init?(_ json: String, using encoding: String.Encoding = .utf8) {
        guard let data = json.data(using: encoding) else { return nil }
        self.init(data: data)
    }

    init?(fromURL url: String) {
        guard let url = URL(string: url) else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        self.init(data: data)
    }

    var jsonData: Data? {
        return try? JSONEncoder().encode(self)
    }

    var json: String? {
        guard let data = self.jsonData else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

extension OpenWeatherMapModels.Coord {
    init?(data: Data) {
        guard let me = try? JSONDecoder().decode(OpenWeatherMapModels.Coord.self, from: data) else { return nil }
        self = me
    }

    init?(_ json: String, using encoding: String.Encoding = .utf8) {
        guard let data = json.data(using: encoding) else { return nil }
        self.init(data: data)
    }

    init?(fromURL url: String) {
        guard let url = URL(string: url) else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        self.init(data: data)
    }

    var jsonData: Data? {
        return try? JSONEncoder().encode(self)
    }

    var json: String? {
        guard let data = self.jsonData else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

extension OpenWeatherMapModels.List {
    init?(data: Data) {
        guard let me = try? JSONDecoder().decode(OpenWeatherMapModels.List.self, from: data) else { return nil }
        self = me
    }

    init?(_ json: String, using encoding: String.Encoding = .utf8) {
        guard let data = json.data(using: encoding) else { return nil }
        self.init(data: data)
    }

    init?(fromURL url: String) {
        guard let url = URL(string: url) else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        self.init(data: data)
    }

    var jsonData: Data? {
        return try? JSONEncoder().encode(self)
    }

    var json: String? {
        guard let data = self.jsonData else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

extension OpenWeatherMapModels.FeelsLike {
    init?(data: Data) {
        guard let me = try? JSONDecoder().decode(OpenWeatherMapModels.FeelsLike.self, from: data) else { return nil }
        self = me
    }

    init?(_ json: String, using encoding: String.Encoding = .utf8) {
        guard let data = json.data(using: encoding) else { return nil }
        self.init(data: data)
    }

    init?(fromURL url: String) {
        guard let url = URL(string: url) else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        self.init(data: data)
    }

    var jsonData: Data? {
        return try? JSONEncoder().encode(self)
    }

    var json: String? {
        guard let data = self.jsonData else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

extension OpenWeatherMapModels.Temp {
    init?(data: Data) {
        guard let me = try? JSONDecoder().decode(OpenWeatherMapModels.Temp.self, from: data) else { return nil }
        self = me
    }

    init?(_ json: String, using encoding: String.Encoding = .utf8) {
        guard let data = json.data(using: encoding) else { return nil }
        self.init(data: data)
    }

    init?(fromURL url: String) {
        guard let url = URL(string: url) else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        self.init(data: data)
    }

    var jsonData: Data? {
        return try? JSONEncoder().encode(self)
    }

    var json: String? {
        guard let data = self.jsonData else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

extension OpenWeatherMapModels.Weather {
    init?(data: Data) {
        guard let me = try? JSONDecoder().decode(OpenWeatherMapModels.Weather.self, from: data) else { return nil }
        self = me
    }

    init?(_ json: String, using encoding: String.Encoding = .utf8) {
        guard let data = json.data(using: encoding) else { return nil }
        self.init(data: data)
    }

    init?(fromURL url: String) {
        guard let url = URL(string: url) else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        self.init(data: data)
    }

    var jsonData: Data? {
        return try? JSONEncoder().encode(self)
    }

    var json: String? {
        guard let data = self.jsonData else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
