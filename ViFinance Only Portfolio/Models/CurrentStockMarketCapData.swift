//
//  CurrentStockMarketCapitalizationData.swift
//  ViFinance Only Portfolio
//
//  Created by Vitaliy Sergeevich on 17.11.2022.
//  Copyright © 2022 Vitaliy Iakushev. All rights reserved.
//

import Foundation

struct CurrentStockMarketCapDatum: Codable {
//    let symbol, date: String
    let marketCap: Double
}

typealias CurrentStockMarketCapData = [CurrentStockMarketCapDatum]
