//
//  CountriesViewController.swift
//  REST_Exercise
//
//  Created by Dominik Polzer on 04.11.20.
//  Copyright © 2020 Dominik Polzer. All rights reserved.
//

import UIKit


class CountriesViewController: UIViewController {
    
    var networking = Networking()
    var countries: [Country]?
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var loadingStatus: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Countries"
        networking.getCountryData { (country, error) in
            if country != nil {
                self.countries = country
                self.tableView.reloadData()
            }else if let error = error { 
                switch (error){
                case .authenticateError:
                    self.showAlertControllerWindow(title: "Error", message: "Authentification Failed", actionTitle: "Cancel")
                    break
                case .permissionError:
                    self.showAlertControllerWindow(title: "Error", message: "Permission Denied", actionTitle: "Cancel")
                    break
                case .unknownError:
                    self.showAlertControllerWindow(title: "Error", message: "Sry an unknown error accured", actionTitle: "Cancel")
                    break
                case .requestError:
                    self.showAlertControllerWindow(title: "Error", message: "Bad request", actionTitle: "Cancel")
                    break
                case .notFoundError:
                    self.showAlertControllerWindow(title: "Error", message: "Server not found", actionTitle: "Cancel")
                    break
                case .noInternetError:
                    self.showAlertControllerWindow(title: "Error", message: "Instable or No Internet Connection", actionTitle: "Cancel")
                    break
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let indexPath = tableView.indexPathForSelectedRow{
            tableView.deselectRow(at: indexPath, animated: true)
        }
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let detailViewController = segue.destination as? CountryDetailViewController, let index = tableView.indexPathForSelectedRow?.row else {
            return
        }
        if let country = countries {
            detailViewController.countries = country[index]
        }
    }
    
    func showAlertControllerWindow(title: String, message: String, actionTitle: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .cancel))
        self.present(alert, animated: true)
    }
}

extension CountriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(indexPath.row)
//        if let index =  tableView.indexPathForSelectedRow{
//            print(index)
//        }
        self.performSegue(withIdentifier: "detailedCountryView", sender: nil)
    }
}



extension CountriesViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let country = countries {
            loadingStatus.stopAnimating()
            return country.count
        }else {
            loadingStatus.startAnimating()
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let country = countries {
            let reuseIdentifier = "Countries"
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) ?? UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
            let countryy = country[indexPath.row]
            cell.textLabel?.text = countryy.name
            return cell
        }else {
            return UITableViewCell()
        }
        
    }
}



