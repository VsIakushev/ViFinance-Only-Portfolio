//
//  PastStockPriceData.swift
//  ViFinance Only Portfolio
//
//  Created by Vitaliy Sergeevich on 15.12.2022.
//  Copyright © 2022 Vitaliy Iakushev. All rights reserved.
//

import Foundation

struct PastStockPriceData: Codable {
    let symbol: String
    let historical: [Historical]
}

// MARK: - Historical
struct Historical: Codable {
    let date: String
    let historicalOpen, high, low, close: Double
    let adjClose: Double
    let volume, unadjustedVolume: Int
    let change, changePercent, vwap: Double
    let label: String
    let changeOverTime: Double

    enum CodingKeys: String, CodingKey {
        case date
        case historicalOpen = "open"
        case high, low, close, adjClose, volume, unadjustedVolume, change, changePercent, vwap, label, changeOverTime
    }
}

//
//
//struct PastStockPriceDatum: Codable {
//    let close: Double
//}
//
//typealias PastStockPriceData = [PastStockPriceDatum]
