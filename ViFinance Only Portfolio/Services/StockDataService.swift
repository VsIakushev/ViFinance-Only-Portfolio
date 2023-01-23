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
    func getStockData(for amount: Decimal) async throws -> Portfolio
}

struct StockDataServiceFake: StockDataService {
    func getStockData(for amount: Decimal) async throws -> Portfolio {
        try await Task.sleep(nanoseconds: 500 * 1000)
        return .init(
            stocks: [
                .init(ticker: "MSFT", share: 0.6, amount: amount * 0.6, price: 25, quantity: 20),
                .init(ticker: "APPL", share: 0.4, amount: amount * 0.4, price: 30, quantity: 10),
            ],
            amount: amount
        )
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
    
    func getStockData(for amount: Decimal) async throws -> Portfolio {
        async let caps = getAllMarketCaps()
        async let prices = getAllPrices()
        
        return calculatePortfolio(for: amount, caps: try await caps, prices: try await prices)
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
    
    private func getAllMarketCaps() async throws -> [String: CurrentStockMarketCap] {
        var caps: [String: CurrentStockMarketCap] = [:]
        
        for ticker in tickers {
            caps[ticker] = try await networkStockManager.fetchStockMarketCapitalization(forCompany: ticker)
        }
        
        return caps
    }
    
    private func getAllPrices() async throws -> [String: CurrentStockPrice] {
        var prices: [String: CurrentStockPrice] = [:]
        
        for ticker in tickers {
            prices[ticker] = try await networkStockManager.fetchStockPrice(forCompany: ticker)
        }
        
        return prices
    }
}
