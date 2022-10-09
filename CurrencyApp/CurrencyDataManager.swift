//
//  CurrencyDataManager.swift
//  CurrencyApp
//
//  Created by Rahul Parthasarathy on 7/10/22.
//

import Foundation
import UIKit

class CurrencyDataManager {

    private let baseUrlString = "https://v6.exchangerate-api.com/v6/9546b93fbc0e3a3ca0075468/latest/"
    
    var countryList: [String] = []
    var currencyConversionMap: [String: Float] = [:]
    
    public init() {}
 
   
}

