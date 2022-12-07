//
//  PortfolioModel.swift
//  ViFinance Only Portfolio
//
//  Created by Vitaliy Sergeevich on 04.12.2022.
//  Copyright © 2022 Vitaliy Iakushev. All rights reserved.
//

import Foundation

struct PortfolioModel {
    
    var ticker : String
    var share : String
    var amount : String
    var price : String
    var quantity : Int
    
    
    static let arrayOfTickers = ["AAPL", "MSFT", "GOOG"]
    // ["AAPL", "MSFT", "GOOG", "BRK.B", "JNJ", "V", "NVDA", "JPM", "MA", "META", "WFC", "DIS", "TXN", "SCHW", "ADBE", "SPGI", "AXP", "BLK", "INTU", "PYPL"]
    
    static var summOfMarketCaps = 0
    
    static var dictOfMarketCap = [String:Double]()
    static var dictOfShares = [String:Double]()
    static var dictOfPrices = [String:Double]()
    static var dictOfAmounts = [String:Double]()
    static var dictOfNubmerOfStocks = [String:Double]()
    
    static var syncQueue: DispatchQueue = .init(label: "sync", qos: .background, attributes: .concurrent)
    
    // Функция 1: Считаем сумму капитализации всех компаний и наполнение dictOfMarketCap
    static func totalMarketCapCalculationAndDictOfMarketCapFilingAPI(completion: @escaping (Result<Void, PortfolioFetchError>) -> Void){
        // делаю в одной функции, чтобы не дублировать запрос к API
        PortfolioModel.summOfMarketCaps = 0
        var errors: [Error] = []
        
        let group = DispatchGroup()
        
        for ticker in PortfolioModel.arrayOfTickers {
            group.enter()
            networkStockInfoManager.fetchStockMarketCapitalization(forCompany: ticker) { currentStockMarketCap in
                syncQueue.async(flags: .barrier) {
                    switch currentStockMarketCap {
                    case let .success(cap):
                        PortfolioModel.summOfMarketCaps += cap.marketCapInt
                        PortfolioModel.dictOfMarketCap[ticker] = cap.marketCap
                    case let .failure(error):
                        errors.append(error)
                    }
                    
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            print("Sum of Market Cap after Delay is : \(PortfolioModel.summOfMarketCaps)")
            if errors.isEmpty {
                completion(.success(()))
            } else {
                completion(.failure(PortfolioFetchError(errors: errors)))
            }
        }
    }
    
    // Функция 2: // наполнение dictOfPrices
    static func stockPricesDictionaryFillingAPI(completion: @escaping (Result<Void, PortfolioFetchError>) -> Void) {
        let group = DispatchGroup()
        var errors: [Error] = []
        
        for ticker in arrayOfTickers {
            group.enter()
            networkStockInfoManager.fetchStockPrice(forCompany: ticker) { currentStockPrice in
                syncQueue.async(flags: .barrier) {
                    switch currentStockPrice {
                    case let .success(price):
                        PortfolioModel.dictOfPrices[ticker] = price.price
                    case let .failure(error):
                        errors.append(error)
                    }
                    
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) {
            if errors.isEmpty {
                completion(.success(()))
            } else {
                completion(.failure(.init(errors: errors)))
            }
        }
    }
    
    // Функция 3: наполнение dictOfShares
    static func stockSharesDictionaryFilling() {
        syncQueue.sync(flags: .barrier) {
            for i in 0..<dictOfMarketCap.count {
                if let value = dictOfMarketCap[arrayOfTickers[i]] {
                    dictOfShares[arrayOfTickers[i]] = round(Double(value / Double( summOfMarketCaps))*10000)/10000
                }
            }
        }
    }
    
    // Функция 4: наполнение dictOfAmounts
    static func dictOfAmountsFilling() {
        syncQueue.sync(flags: .barrier) {
            for i in 0..<dictOfShares.count {
                if let value = dictOfShares[arrayOfTickers[i]] {
                    dictOfAmounts[arrayOfTickers[i]] = value*PortfolioAmount
                }
            }
        }
    }
    
    // Функция 5: наполнение dictOfNumberOfStocks
    static func dictOfNumberOfStocksFilling() {
        syncQueue.sync(flags: .barrier) {
            for i in 0..<dictOfAmounts.count {
                if let valueAmount = dictOfAmounts[arrayOfTickers[i]], let valuePrice = dictOfPrices[arrayOfTickers[i]] {
                    dictOfNubmerOfStocks[arrayOfTickers[i]] = round(( valueAmount / valuePrice )*1)/1
                    // добавил 1/1 для целых акций, чтобы потом сделать 10/10 для дополнительного функционала с дробными акциями.
                }
            }
        }
    }
    
    // Функция 6: Составление портфеля
    static func getPortfolio() -> [PortfolioModel] {
        var portfolio = [PortfolioModel]()
        for ticker in arrayOfTickers {
            if
                let valueShare = dictOfShares[ticker],
                let valueAmount = dictOfAmounts[ticker],
                let valuePrice = dictOfPrices[ticker],
                let valueNumberOfStocks = dictOfNubmerOfStocks[ticker]
            {
                portfolio.append(PortfolioModel(
                    ticker: ticker,
                    share: String(format: "%.2f", valueShare*100) + "%",
                    amount: String(format: "%.2f", valueAmount) + "$",
                    price: String(format: "%.2f", valuePrice),
                    quantity: Int(valueNumberOfStocks)
                ))
            }
        }
        // сортировка по доле компании в портфеле
        portfolio = portfolio.sorted(by: {$0.share > $1.share })
        return portfolio
    }
    
    static func getMarketCapAndPriceDataAPIandFillAllDictionaries(using completionHandler: @escaping (Result<Void, PortfolioFetchError>) -> Void) {
        totalMarketCapCalculationAndDictOfMarketCapFilingAPI { marketCapResult in
            stockPricesDictionaryFillingAPI { pricesResult in
                var errors: [Error] = []
                if case let .failure(error) = marketCapResult {
                    errors.append(contentsOf: error.errors)
                }
                if case let .failure(error) = pricesResult {
                    errors.append(contentsOf: error.errors)
                }
                if errors.isEmpty {
                    completionHandler(.success(()))
                } else {
                    completionHandler(.failure(.init(errors: errors)))
                }
            }
        }
    }
}
