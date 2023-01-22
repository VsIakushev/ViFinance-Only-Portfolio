//
//  StockDataService.swift
//  ViFinance Only Portfolio
//
//  Created by Vitaliy Iakushev on 22.01.2023.
//  Copyright © 2023 Vitaliy Iakushev. All rights reserved.
//

import Foundation

struct CompanyInfo {
    var ticker: String
    
    var share: Decimal
    var amount: Decimal
    
    var price: Decimal
    var quantity: Decimal
}

struct Portfolio {
    var stocks: [CompanyInfo]
    var amount: Decimal
    
    init(stocks: [CompanyInfo], amount: Decimal) {
        self.stocks = stocks
        self.amount = amount
    }
}

protocol StockDataService {
    func getStockData(
        for amount: Decimal,
        completion: @escaping (Result<Portfolio, Error>) -> Void
    )
}

struct StockDataServiceFake: StockDataService {
    func getStockData(for amount: Decimal, completion: @escaping (Result<Portfolio, Error>) -> Void)  {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            completion(.success(.init(
                stocks: [
                    .init(ticker: "MSFT", share: 0.6, amount: amount * 0.6, price: 25, quantity: 20),
                    .init(ticker: "APPL", share: 0.4, amount: amount * 0.4, price: 30, quantity: 10),
                ],
                amount: amount
            )))
        }
    }
}

final class StockDataServiceImpl: StockDataService {
    private let networkStockManager: NetworkStockManager
    private let tickers: [String]
    private var syncQueue: DispatchQueue = .init(label: "sync", qos: .background, attributes: .concurrent)
    
    init(
        tickers: [String] = arrayOfTickers,
        networkStockManager: NetworkStockManager = NetworkStockManagerImpl()
    ) {
        self.tickers = tickers
        self.networkStockManager = networkStockManager
    }
    
    func getStockData(
        for amount: Decimal,
        completion: @escaping (Result<Portfolio, Error>) -> Void
    ) {
        self.getAllMarketCaps { capsResult in
            self.getAllPrices { pricesResult in
                if case .failure(let failure) = capsResult {
                    return completion(.failure(failure))
                }
                if case .failure(let failure) = pricesResult {
                    return completion(.failure(failure))
                }

                if case .success(let caps) = capsResult, case .success(let prices) = pricesResult {
                    let portfolio = self.calculatePortfolio(for: amount, caps: caps, prices: prices)
                    completion(.success(portfolio))
                }
            }
        }
    }
    
    private func calculatePortfolio(
        for amount: Decimal,
        caps: [String: CurrentStockMarketCap],
        prices: [String: CurrentStockPrice]
    ) -> Portfolio {
        let summOfMarketCaps = caps
            .map { $0.value.marketCapInt }
            .map { Decimal($0) }
            .reduce(0, +)
        
        let shares = caps.mapValues { cap in
            cap.marketCapDecimal / summOfMarketCaps
        }
        
        let amounts = shares.mapValues { share in
            share * amount
        }
        
        let quantities = Dictionary(
            uniqueKeysWithValues: amounts.keys
                .compactMap {
                    zip($0, amounts[$0], prices[$0])
                }
                .map { ticker, amount, price in
                    (ticker, amount / price.priceDecimal)
                }
        )
        
        let stocks = caps.keys
            .compactMap { ticker in
                zip(
                    ticker,
                    shares[ticker],
                    amounts[ticker],
                    prices[ticker]?.priceDecimal,
                    quantities[ticker]
                )
            }
            .map(CompanyInfo.init)
            .sorted { $0.share > $1.share }
            
        return Portfolio(
            stocks: stocks,
            amount: amount
        )
    }
    
    private func getAllMarketCaps(completion: @escaping (Result<[String: CurrentStockMarketCap], PortfolioFetchError>) -> Void){
        var caps: [String: CurrentStockMarketCap] = [:]
        var errors: [Error] = []
        
        let group = DispatchGroup()
        
        for ticker in tickers {
            group.enter()
            networkStockManager.fetchStockMarketCapitalization(forCompany: ticker) { currentStockMarketCap in
                self.syncQueue.async(flags: .barrier) {
                    switch currentStockMarketCap {
                    case let .success(cap):
                        caps[ticker] = cap
                    case let .failure(error):
                        errors.append(error)
                    }
                    
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            if errors.isEmpty {
                completion(.success(caps))
            } else {
                completion(.failure(PortfolioFetchError(errors: errors)))
            }
        }
    }
    
    private func getAllPrices(completion: @escaping (Result<[String: CurrentStockPrice], PortfolioFetchError>) -> Void) {
        let group = DispatchGroup()
        var prices: [String: CurrentStockPrice] = [:]
        var errors: [Error] = []
        
        for ticker in tickers {
            group.enter()
            networkStockManager.fetchStockPrice(forCompany: ticker) { currentStockPrice in
                self.syncQueue.async(flags: .barrier) {
                    switch currentStockPrice {
                    case let .success(price):
                        prices[ticker] = price
                    case let .failure(error):
                        errors.append(error)
                    }
                    
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) {
            if errors.isEmpty {
                completion(.success(prices))
            } else {
                completion(.failure(.init(errors: errors)))
            }
        }
    }
}
