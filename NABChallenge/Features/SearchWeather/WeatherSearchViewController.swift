//
//  WeatherSearchViewController.swift
//  NABChallenge
//
//  Created by user on 8/23/20.
//  Copyright © 2020 Sang Nguyen. All rights reserved.
//

import UIKit

protocol WeatherSearchViewModelProtocol {
    typealias UpdateHandler = (() -> Void)
    
    var count: Int { get }
    subscript (index: Int) -> WeatherViewModel? { get }
    
    var cityName: String { get }
    var errorMessage: String? { get }
    
    var changeHandler: UpdateHandler? { get set }
    
    func search(city: String)
}

class WeatherSearchViewController: UIViewController {
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchViewModel: WeatherSearchViewModelProtocol = WeatherSearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "WeatherViewCell", bundle: nil)
        self.searchTableView.register(nib, forCellReuseIdentifier: "WeatherViewCell")
        self.searchTableView.tableFooterView = UIView(frame: .zero)
        
        searchViewModel.changeHandler = { [unowned self] in
            self.updateUI()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:
            UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func updateUI() {
        self.cityLabel.text = searchViewModel.cityName
        self.errorLabel.text = searchViewModel.errorMessage
        self.searchTableView.reloadData()
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
           return
        }
      
        searchTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
    }

    @objc func keyboardWillHide(_ notification: NSNotification) {
        searchTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

extension WeatherSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchViewModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherViewCell") as! WeatherViewCell
        
        if let weatherVM = searchViewModel[indexPath.row] {
            cell.bind(weatherVM)
        }
        
        return cell
    }
}

extension WeatherSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let city = searchText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        searchViewModel.search(city: city)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
