//
//  PastStockPrice.swift
//  ViFinance Only Portfolio
//
//  Created by Vitaliy Sergeevich on 15.12.2022.
//  Copyright © 2022 Vitaliy Iakushev. All rights reserved.
//

import Foundation

struct PastStockPrice {
    let close: Double
    let date: String?
    
    var stockPreviousPriceString : String {
        return "\(close)"
    }
    
    init?(pastStockPriceData: PastStockPriceData) {
        close = pastStockPriceData.historical.first!.close
        date = pastStockPriceData.historical.first?.date
    }
    
    
}
