//
//  CurrentStockData.swift
//  ViFinance Only Portfolio
//
//  Created by Vitaliy Sergeevich on 17.11.2022.
//  Copyright © 2022 Vitaliy Iakushev. All rights reserved.
//

import Foundation

struct CurrentStockPriceDatum: Codable {
//    let symbol: String
    let price: Double
//    let volume: Int

}

typealias CurrentStockPriceData = [CurrentStockPriceDatum]

