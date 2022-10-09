//
//  PickerModel.swift
//  CurrencyApp
//
//  Created by Rahul Parthasarathy on 7/10/22.
//

import Foundation


struct ConversionModel: Codable {
    let conversionRates: [String:Float]
    private enum CodingKeys: String, CodingKey {
        case conversionRates = "conversion_rates"
    }

}
