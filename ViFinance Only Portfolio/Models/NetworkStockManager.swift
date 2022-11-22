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
             let currentStockPriceData = self.parsePriceJSON(withData: data)
            }
        }
        task.resume()
    }
    
    //
    func fetchStockMarketCapitalization(forCompany ticker: String, completionHandler: @escaping (CurrentStockMarketCapData) -> Void) {
        let urlString = "https://financialmodelingprep.com/api/v3/market-capitalization/\(ticker)?apikey=\(apiKeyfinancialmodelingprep)"
        guard let url = URL(string: urlString) else { return }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data, response, error in
            if let data = data {
                if let currentStockMarketCapData = self.parseMarketCapJSON(withData: data) {
                completionHandler(currentStockMarketCapData)
                }
            }
        }
        task.resume()
    }
    
    func parsePriceJSON(withData data: Data) {
        let decoder = JSONDecoder()
        do {
            let currentStockPriceData = try decoder.decode(CurrentStockPriceData.self, from: data)
            print(currentStockPriceData.first!.price)
        } catch let error as NSError {
            print(error)
        }
    }
    
    func parseMarketCapJSON(withData data: Data) -> CurrentStockMarketCapData? {
        let decoder = JSONDecoder()
        do {
            let currentStockMarketCapData = try decoder.decode(CurrentStockMarketCapData.self, from: data)
            print(currentStockMarketCapData.first!.marketCap)
            return currentStockMarketCapData
            
        } catch let error as NSError {
            print(error)
            return nil
        }
    }
}
