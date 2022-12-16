//
//  NetworkStockInfoManager.swift
//  ViFinance Only Portfolio
//
//  Created by Vitaliy Sergeevich on 16.11.2022.
//  Copyright © 2022 Vitaliy Iakushev. All rights reserved.
//

import Foundation

class NetworkStockManager {
    private let session: URLSession = .shared
    
    func fetchStockPrice(forCompany ticker: String, completionHandler: @escaping (Result<CurrentStockPrice, Error>) -> Void) {
        let urlString = "https://financialmodelingprep.com/api/v3/quote-short/\(ticker)?apikey=\(apiKeyfinancialmodelingprep)"
        guard let url = URL(string: urlString) else { return }
        
        let task = session.dataTask(with: url) { data, response, error in
            if let data = data, let currentStockPrice = self.parsePriceJSON(withData: data) {
                completionHandler(.success(currentStockPrice))
            } else if let error = error {
                completionHandler(.failure(error))
            } else {
//                fatalError()
            }
        }
        task.resume()
    }
    
    // new func fetch PastPrice
    func fetchPastStockPrice(forCompany ticker: String, completionHandler: @escaping (Result<PastStockPrice, Error>) -> Void) {
            let urlString = "https://financialmodelingprep.com/api/v3/historical-price-full/\(ticker)?apikey=\(apiKeyfinancialmodelingprep)"
            guard let url = URL(string: urlString) else { return }
            
            let task = session.dataTask(with: url) { data, response, error in
                if let data = data, let pastStockPrice = self.parsePastPriceJSON(withData: data) {
                    completionHandler(.success(pastStockPrice))
                } else if let error = error {
                    completionHandler(.failure(error))
                } else {
    //                fatalError()
                }
            }
            task.resume()
        }
    
    
    //
    func fetchStockMarketCapitalization(forCompany ticker: String, completionHandler: @escaping (Result<CurrentStockMarketCap, Error>) -> Void) {
        let urlString = "https://financialmodelingprep.com/api/v3/market-capitalization/\(ticker)?apikey=\(apiKeyfinancialmodelingprep)"
        guard let url = URL(string: urlString) else { return }
        
        let task = session.dataTask(with: url) { data, response, error in
            if let data = data, let currentStockMarketCap = self.parseMarketCapJSON(withData: data) {
                completionHandler(.success(currentStockMarketCap))
            } else if let error = error {
                completionHandler(.failure(error))
            } else {
//                fatalError()
            }
        }
        task.resume()
    }
    
    func parsePriceJSON(withData data: Data) -> CurrentStockPrice? {
        let decoder = JSONDecoder()
        do {
            let currentStockPriceData = try decoder.decode(CurrentStockPriceData.self, from: data)
            guard let currentStockprice = CurrentStockPrice(currentStockPriceData: currentStockPriceData) else { return nil }
//            print(currentStockPriceData.first!.price)
            return currentStockprice
        } catch {
            print(error)
            return nil
        }
    }
    
    // new func to parse PastPrice
    func parsePastPriceJSON(withData data: Data) -> PastStockPrice? {
        let decoder = JSONDecoder()
        do {
            let pastStockPriceData = try decoder.decode(PastStockPriceData.self, from: data)
            guard let pastStockPrice = PastStockPrice(pastStockPriceData: pastStockPriceData) else { return nil }
//            print("Previous day close price: \(pastStockPriceData.historical.first!.close)")
            return pastStockPrice
        } catch {
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
            
        } catch {
            print(error)
            return nil
        }
    }
}
