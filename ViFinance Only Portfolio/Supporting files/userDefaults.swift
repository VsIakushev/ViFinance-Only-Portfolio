//
//  userDefaults.swift
//  ViFinance Only Portfolio
//
//  Created by Vitaliy Sergeevich on 20.10.2022.
//  Copyright © 2022 Vitaliy Iakushev. All rights reserved.
//

import Foundation

final class UserSettings {
    
    private enum SettingsKeys: String {
        case amount
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
}
 
