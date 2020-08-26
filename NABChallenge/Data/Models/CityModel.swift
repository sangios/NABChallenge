//
//  CityModel.swift
//  NABChallenge
//
//  Created by user on 8/24/20.
//  Copyright © 2020 Sang Nguyen. All rights reserved.
//

import UIKit

struct CityModel {
    var name: String
}

extension CityModel {
    static func create(from entity: CityEntity?) -> CityModel? {
        guard let entity = entity else { return nil }
        return CityModel(name: entity.name ?? "No Name")
    }
}
