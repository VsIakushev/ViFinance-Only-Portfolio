//
//  NetworkStockInfoManager.swift
//  ViFinance Only Portfolio
//
//  Created by Vitaliy Sergeevich on 16.11.2022.
//  Copyright © 2022 Vitaliy Iakushev. All rights reserved.
//

import Foundation

struct NetworkStockManager {
    func fetchStockPrice(forCompany ticker: String) {
        let urlString = "https://financialmodelingprep.com/api/v3/quote-short/\(ticker)?apikey=\(apiKeyfinancialmodelingprep)"
        guard let url = URL(string: urlString) else { return }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data, response, error in
            if let data = data {
                let dataString = String(data: data, encoding: .utf8)
                print(dataString!)
            }
        }
        task.resume()
    }
    
    
    func fetchStockMarketCapitalization(forCompany ticker: String) {
        let urlString = "https://financialmodelingprep.com/api/v3/market-capitalization/\(ticker)?apikey=\(apiKeyfinancialmodelingprep)"
        guard let url = URL(string: urlString) else { return }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data, response, error in
            if let data = data {
                let dataString = String(data: data, encoding: .utf8)
                print(dataString!)
            }
        }
        task.resume()
    }
}
