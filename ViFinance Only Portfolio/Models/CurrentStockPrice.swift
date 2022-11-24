//
//  CurrentStockPrice.swift
//  ViFinance Only Portfolio
//
//  Created by Vitaliy Sergeevich on 24.11.2022.
//  Copyright © 2022 Vitaliy Iakushev. All rights reserved.
//

import Foundation

struct CurrentStockPrice {
    let price: Double
    
    var stockPriceString : String {
        return "\(price)"
    }
    
    init?(currentStockPriceData: CurrentStockPriceData) {
        price = currentStockPriceData.first!.price
    }
}
