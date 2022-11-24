//
//  NetworkStockInfoManager.swift
//  ViFinance Only Portfolio
//
//  Created by Vitaliy Sergeevich on 16.11.2022.
//  Copyright © 2022 Vitaliy Iakushev. All rights reserved.
//

import Foundation

class NetworkStockManager {
    
    func fetchStockPrice(forCompany ticker: String, completionHandler: @escaping (CurrentStockPrice) -> Void) {
        let urlString = "https://financialmodelingprep.com/api/v3/quote-short/\(ticker)?apikey=\(apiKeyfinancialmodelingprep)"
        guard let url = URL(string: urlString) else { return }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data, response, error in
            if let data = data {
                if let currentStockPrice = self.parsePriceJSON(withData: data) {
                    completionHandler(currentStockPrice)
                }
            }
        }
        task.resume()
    }
    
    //
    func fetchStockMarketCapitalization(forCompany ticker: String, completionHandler: @escaping (CurrentStockMarketCap) -> Void) {
        let urlString = "https://financialmodelingprep.com/api/v3/market-capitalization/\(ticker)?apikey=\(apiKeyfinancialmodelingprep)"
        guard let url = URL(string: urlString) else { return }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data, response, error in
            if let data = data {
                if let currentStockMarketCap = self.parseMarketCapJSON(withData: data) {
                    completionHandler(currentStockMarketCap)
                }
            }
        }
        task.resume()
    }
    
    func parsePriceJSON(withData data: Data) -> CurrentStockPrice? {
        let decoder = JSONDecoder()
        do {
            let currentStockPriceData = try decoder.decode(CurrentStockPriceData.self, from: data)
            guard let currentStockprice = CurrentStockPrice(currentStockPriceData: currentStockPriceData) else { return nil }
            print(currentStockPriceData.first!.price)
            return currentStockprice
        } catch let error as NSError {
            print(error)
            return nil
        }
    }
    
    func parseMarketCapJSON(withData data: Data) -> CurrentStockMarketCap? {
        let decoder = JSONDecoder()
        do {
            let currentStockMarketCapData = try decoder.decode(CurrentStockMarketCapData.self, from: data)
            guard let currentStockMarketCap = CurrentStockMarketCap(currentStockMarketCapData: currentStockMarketCapData) else { return nil }
            //            print(currentStockMarketCapData.first!.marketCap)
            return currentStockMarketCap
            
        } catch let error as NSError {
            print(error)
            return nil
        }
    }
}
