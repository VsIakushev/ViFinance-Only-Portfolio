//
//  CurrentStockMarketCap.swift
//  ViFinance Only Portfolio
//
//  Created by Vitaliy Sergeevich on 22.11.2022.
//  Copyright © 2022 Vitaliy Iakushev. All rights reserved.
//

import Foundation

struct CurrentStockMarketCap {
    let marketCap: Double
    
    var marketCapInt : Int {
        return Int(marketCap)
    }
    
    var marketCapDecimal: Decimal {
        return Decimal(marketCap)
    }
    
    var marketCapString : String {
        return "\(marketCap)"
    }
}

extension CurrentStockMarketCap {
    init(currentStockMarketCapData: CurrentStockMarketCapData) {
        marketCap = currentStockMarketCapData.first!.marketCap
    }
}

