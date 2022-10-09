//
//  ErrorType.swift
//  CurrencyApp
//
//  Created by Rahul Parthasarathy on 9/10/22.
//

import Foundation

public enum CustomErrorType {
    case noConversionRateFound
    case invalidInput
    case incorrectCredentials
    
    var errorMessage: String {
        switch self {
        case .noConversionRateFound:
            return "Did not find a conversion rate for the selected countries"
        case .invalidInput:
            return "The input needs to be a valid number with only '.' character allowed type, please reenter"
        case .incorrectCredentials:
            return "Username or password incorrect"
        default:
            return "Unknown Error"
        }
    }
}
