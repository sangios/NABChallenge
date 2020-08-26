//
//  WeatherViewCell.swift
//  NABChallenge
//
//  Created by user on 8/23/20.
//  Copyright © 2020 Sang Nguyen. All rights reserved.
//

import UIKit

protocol WeatherViewCellProtocol {
    var date: String { get }
    var temperature: String { get }
    var pressure: String { get }
    var humidity: String { get }
    var descriptionString: String { get }
}

class WeatherViewCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bind(_ viewModel: WeatherViewCellProtocol) {
        dateLabel.text = viewModel.date
        temperatureLabel.text = viewModel.temperature
        pressureLabel.text = viewModel.pressure
        humidityLabel.text = viewModel.humidity
        descriptionLabel.text = viewModel.descriptionString        
    }
}
