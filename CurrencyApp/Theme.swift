//
//  Theme.swift
//  CurrencyApp
//
//  Created by RahulMacbook on 30/1/23.
//

import Foundation
import UIKit

class Theme {
    class Color {
        
        public static var planetsLightGreenColor: UIColor {
            return UIColor(0xDDD8B8)
        }
        
        public static var planetsDarkGreenColor: UIColor {
            return UIColor(0x0D7355)
        }
        
        public static var soberGrayColor: UIColor {
            return UIColor(0xB9B9B9)
        }
        
        public static var creamLightColor: UIColor {
            return UIColor(0xEDEBDB)
        }
        
    }
    class Font {
        
        public static var headlineFont: UIFont {
            return UIFont(name: "Rubik-Regular", size: UIFont.labelFontSize)!
        }
        
    }
    class Images {}
    class Constants {}
}
extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(_ rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}
