//
//  CountryDetailViewController.swift
//  REST_Exercise
//
//  Created by Dominik Polzer on 16.11.20.
//  Copyright © 2020 Dominik Polzer. All rights reserved.
//

import UIKit

class CountryDetailViewController: UIViewController {
    
    var countries: Country?
    
    @IBOutlet weak var capitalLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var nativLabel: UILabel!
    @IBOutlet weak var continentLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var createdTimeLabel: UILabel!
    @IBOutlet weak var updatedTimeLabel: UILabel!
    @IBOutlet weak var languageLanel: UILabel!
    @IBOutlet weak var detailedStackView: UIStackView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let countryDetail = countries {
            
            let languageCount = countryDetail.languages.count
            
            self.title = countryDetail.name
            capitalLabel.text = "Capital City: \(countryDetail.capital)"
            currencyLabel.text = "Currency in that country: \(countryDetail.currency)"
            nativLabel.text = "Native: \(countryDetail.native)"
            continentLabel.text = "Continent: \(countryDetail.continent)"
            phoneNumberLabel.text = "Phone: +\(countryDetail.phone)"
            createdTimeLabel.text = "Created Time: \(countryDetail.createTime)"
            updatedTimeLabel.text = "Updated Time: \(countryDetail.updateTime)"
            languageLanel.text = "Languages spoken in that Country: "
            
            for index in 0..<(languageCount){
                let languageLabel = UILabel()
                if let countryLanguage = countries{
                    languageLabel.text = "Language \(index+1): \(countryLanguage.languages[index])"
                    detailedStackView.addArrangedSubview(languageLabel)
                }
                
            }
        }
    }
}
