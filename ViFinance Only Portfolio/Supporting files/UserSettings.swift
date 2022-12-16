//
//  userDefaults.swift
//  ViFinance Only Portfolio
//
//  Created by Vitaliy Sergeevich on 20.10.2022.
//  Copyright © 2022 Vitaliy Iakushev. All rights reserved.
//

import Foundation

final class UserSettings {
    
    // portfolioAmount - сумма портфеля клиента
    
    private enum SettingsKeys: String {
        case amount
        case previousDayAmount
        case numberOfStocks
    }
    
    static var portfolioAmount: Double! {
        get {
            return UserDefaults.standard.double(forKey: SettingsKeys.amount.rawValue)
        } set {
            let defaults = UserDefaults.standard
            let key = SettingsKeys.amount.rawValue
            if let amount = newValue {
                defaults.set(amount, forKey: key)
                
            }
        }
    }
    
    static var previousDayportfolioAmount: Double! {
        get {
            return UserDefaults.standard.double(forKey: SettingsKeys.previousDayAmount.rawValue)
        } set {
            let defaults = UserDefaults.standard
            let key = SettingsKeys.previousDayAmount.rawValue
            if let amount = newValue {
                defaults.set(amount, forKey: key)
                
            }
        }
    }
    
    // TODO:  Протестировать такое сохранение!
    static var testDictOfNumbers: [String:Double]! {
        get {
            return UserDefaults.standard.dictionary(forKey: SettingsKeys.numberOfStocks.rawValue) as? [String : Double]
        }
        set {
            let defaults = UserDefaults.standard
            let key = SettingsKeys.numberOfStocks.rawValue
            if let numberOfStocks = newValue {
                defaults.set(numberOfStocks, forKey: key)
            }
        }
    }
}

