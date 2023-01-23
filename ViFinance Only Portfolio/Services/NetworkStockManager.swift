//
//  NetworkStockInfoManager.swift
//  ViFinance Only Portfolio
//
//  Created by Vitaliy Sergeevich on 16.11.2022.
//  Copyright © 2022 Vitaliy Iakushev. All rights reserved.
//

import Foundation

protocol NetworkStockManager {
    @available(*, renamed: "fetchStockPrice(forCompany:)")
    func fetchStockPrice(
        forCompany ticker: String,
        completionHandler: @escaping (Result<CurrentStockPrice, Error>) -> Void
    )
    
    func fetchStockPrice(forCompany ticker: String) async throws -> CurrentStockPrice
    
    @available(*, renamed: "fetchPastStockPrice(forCompany:)")
    func fetchPastStockPrice(
        forCompany ticker: String,
        completionHandler: @escaping (Result<PastStockPrice, Error>) -> Void
    )
    
    func fetchPastStockPrice(forCompany ticker: String) async throws -> PastStockPrice
    
    @available(*, renamed: "fetchStockMarketCapitalization(forCompany:)")
    func fetchStockMarketCapitalization(
        forCompany ticker: String,
        completionHandler: @escaping (Result<CurrentStockMarketCap, Error>) -> Void
    )
    
    func fetchStockMarketCapitalization(forCompany ticker: String) async throws -> CurrentStockMarketCap
}

final class NetworkStockManagerFake: NetworkStockManager {
    @available(*, renamed: "fetchStockPrice(forCompany:)")
    func fetchStockPrice(forCompany ticker: String, completionHandler: @escaping (Result<CurrentStockPrice, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            completionHandler(.success(.init(price: .random(in: 10...20))))
        }
    }
    
    func fetchStockPrice(forCompany ticker: String) async throws -> CurrentStockPrice {
        try await Task.sleep(nanoseconds: 500 * 1000 * 1000)
        return .init(price: .random(in: 10...20))
    }
    
    @available(*, renamed: "fetchPastStockPrice(forCompany:)")
    func fetchPastStockPrice(forCompany ticker: String, completionHandler: @escaping (Result<PastStockPrice, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            completionHandler(.success(.init(close: .random(in: 30...100), date: nil)))
        }
    }
    
    func fetchPastStockPrice(forCompany ticker: String) async throws -> PastStockPrice {
        try await Task.sleep(nanoseconds: 500 * 1000 * 1000)
        return .init(close: .random(in: 30...100), date: nil)
    }
    
    
    @available(*, renamed: "fetchStockMarketCapitalization(forCompany:)")
    func fetchStockMarketCapitalization(forCompany ticker: String, completionHandler: @escaping (Result<CurrentStockMarketCap, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            completionHandler(.success(.init(marketCap: .random(in: 1000...5000))))
        }
    }
    
    func fetchStockMarketCapitalization(forCompany ticker: String) async throws -> CurrentStockMarketCap {
        try await Task.sleep(nanoseconds: 500 * 1000 * 1000)
        return .init(marketCap: .random(in: 1000...5000))
    }    
}

final class NetworkStockManagerImpl: NetworkStockManager {
    private let session: URLSession = .shared
    
    func fetchStockPrice(forCompany ticker: String) async throws -> CurrentStockPrice {
        let urlString = "https://financialmodelingprep.com/api/v3/quote-short/\(ticker)?apikey=\(apiKeyfinancialmodelingprep)"
        let url = URL(string: urlString)!
        
        let (data, _) = try await session.data(from: url)
        
        return try self.parsePriceJSON(withData: data)
    }
    
    // new func fetch PastPrice
    func fetchPastStockPrice(forCompany ticker: String) async throws -> PastStockPrice {
        let urlString = "https://financialmodelingprep.com/api/v3/historical-price-full/\(ticker)?apikey=\(apiKeyfinancialmodelingprep)"
        let url = URL(string: urlString)!
        
        let (data, _) = try await session.data(from: url)
        return try self.parsePastPriceJSON(withData: data)
    }
    
    
    //
    func fetchStockMarketCapitalization(forCompany ticker: String) async throws -> CurrentStockMarketCap {
        let urlString = "https://financialmodelingprep.com/api/v3/market-capitalization/\(ticker)?apikey=\(apiKeyfinancialmodelingprep)"
        let url = URL(string: urlString)!
        
        let (data, _) = try await session.data(from: url)
        return try self.parseMarketCapJSON(withData: data)
    }
    
    func fetchStockPrice(forCompany ticker: String, completionHandler: @escaping (Result<CurrentStockPrice, Error>) -> Void) {
        let urlString = "https://financialmodelingprep.com/api/v3/quote-short/\(ticker)?apikey=\(apiKeyfinancialmodelingprep)"
        guard let url = URL(string: urlString) else { return }
        
        let task = session.dataTask(with: url) { data, response, error in
            if let data = data {
                let result = Result {
                    try self.parsePriceJSON(withData: data)
                }
                completionHandler(result)
            } else if let error = error {
                completionHandler(.failure(error))
            } else {
                fatalError()
            }
        }
        task.resume()
    }
    
    // new func fetch PastPrice
    func fetchPastStockPrice(forCompany ticker: String, completionHandler: @escaping (Result<PastStockPrice, Error>) -> Void) {
            let urlString = "https://financialmodelingprep.com/api/v3/historical-price-full/\(ticker)?apikey=\(apiKeyfinancialmodelingprep)"
            guard let url = URL(string: urlString) else { return }
            
            let task = session.dataTask(with: url) { data, response, error in
                if let data = data {
                    let result = Result {
                        try self.parsePastPriceJSON(withData: data)
                    }
                    completionHandler(result)
                } else if let error = error {
                    completionHandler(.failure(error))
                } else {
                    fatalError()
                }
            }
            task.resume()
        }
    
    
    //
    func fetchStockMarketCapitalization(forCompany ticker: String, completionHandler: @escaping (Result<CurrentStockMarketCap, Error>) -> Void) {
        let urlString = "https://financialmodelingprep.com/api/v3/market-capitalization/\(ticker)?apikey=\(apiKeyfinancialmodelingprep)"
        guard let url = URL(string: urlString) else { return }
        
        let task = session.dataTask(with: url) { data, response, error in
            if let data = data {
                let result = Result {
                    try self.parseMarketCapJSON(withData: data)
                }
                completionHandler(result)
            } else if let error = error {
                completionHandler(.failure(error))
            } else {
                fatalError()
            }
        }
        task.resume()
    }
    
    func parsePriceJSON(withData data: Data) throws -> CurrentStockPrice {
        let decoder = JSONDecoder()
        
        let currentStockPriceData = try decoder.decode(CurrentStockPriceData.self, from: data)
        let currentStockprice = CurrentStockPrice(currentStockPriceData: currentStockPriceData)
        
        return currentStockprice
    }
    
    // new func to parse PastPrice
    func parsePastPriceJSON(withData data: Data) throws -> PastStockPrice {
        let decoder = JSONDecoder()
        
        let pastStockPriceData = try decoder.decode(PastStockPriceData.self, from: data)
        let pastStockPrice = PastStockPrice(pastStockPriceData: pastStockPriceData)
        
        return pastStockPrice
    }
    
    func parseMarketCapJSON(withData data: Data) throws -> CurrentStockMarketCap {
        let decoder = JSONDecoder()
        
        let currentStockMarketCapData = try decoder.decode(CurrentStockMarketCapData.self, from: data)
        let currentStockMarketCap = CurrentStockMarketCap(currentStockMarketCapData: currentStockMarketCapData)

        return currentStockMarketCap
        
    }
}
