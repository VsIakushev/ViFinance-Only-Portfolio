//
//  StockDataManager.swift
//  ViFinance Only Portfolio
//
//  Created by Vitaliy Sergeevich on 07.12.2022.
//  Copyright © 2022 Vitaliy Iakushev. All rights reserved.
//

import Foundation



let networkStockInfoManager = NetworkStockManager()

// StockDataManager обрабатывает данные, получаемые от NetworkStockManager, составляет словари, необходимые для составления TableView, формирует итоговый массив структур

final class StocksDataManager {
    
    static var summOfMarketCaps = 0
    
    //    let networkStockInfoManager = NetworkStockManager()
    
    static var dictOfMarketCap = [String:Double]()
    static var dictOfShares = [String:Double]()
    static var dictOfPrices = [String:Double]()
    static var dictOfPastPrices = [String:Double]()
    static var dictOfAmounts = [String:Double]()
    static var dictOfNubmerOfStocks = [String:Double]()
    
    // Создаем очередь
    static var syncQueue: DispatchQueue = .init(label: "sync", qos: .background, attributes: .concurrent)
    
    // Функция 1: Считаем сумму капитализации всех компаний и наполнение dictOfMarketCap
    static func totalMarketCapCalculationAndDictOfMarketCapFilingAPI(completion: @escaping (Result<Void, PortfolioFetchError>) -> Void){
        // делаю в одной функции, чтобы не дублировать запрос к API
        self.summOfMarketCaps = 0
        var errors: [Error] = []
        
        let group = DispatchGroup()
        
        for ticker in arrayOfTickers {
            group.enter()
            networkStockInfoManager.fetchStockMarketCapitalization(forCompany: ticker) { currentStockMarketCap in
                syncQueue.async(flags: .barrier) {
                    switch currentStockMarketCap {
                    case let .success(cap):
                        self.summOfMarketCaps += cap.marketCapInt
                        self.dictOfMarketCap[ticker] = cap.marketCap
                    case let .failure(error):
                        errors.append(error)
                    }
                    
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            print("Sum of Market Cap after Delay is : \(self.summOfMarketCaps)")
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
                        self.dictOfPrices[ticker] = price.price
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
    
    // Функция: Сохранение новой даты вчерашних цен в UserDefaults
    static func savePastPriceDateToUserDefaults() {
        let group = DispatchGroup()
        var errors: [Error] = []
        group.enter()
        networkStockInfoManager.fetchPastStockPrice(forCompany: "AAPL") { (dateOfPastStockPrice) in
            syncQueue.async(flags: .barrier) {
                switch dateOfPastStockPrice {
                case let .success(datePastPrice):
                    if let date = datePastPrice.date {
                        UserSettings.previousDayDate = date
                    }
                case let .failure(error):
                    errors.append(error)
                }
                group.leave()
            }
        }
    }
    
    // TODO: !!!!!!!!!!!!!!!! Сделать возврат не Bool а escaping closure (Completion: ()->(Bool) ) проверить
    
    // Функция: Проверка актуальноcти даты вчерашних цен
    static func pastPricesUpToDate() -> Bool {
        let group = DispatchGroup()
        var errors: [Error] = []
        group.enter()
        var dateOfRequest = "" // UserSettings.previousDayDate
        networkStockInfoManager.fetchPastStockPrice(forCompany: "AAPL") { (dateOfPastStockPrice) in
            syncQueue.async(flags: .barrier) {
                switch dateOfPastStockPrice {
                case let .success(datePastPrice):
                    if let date = datePastPrice.date {
                        dateOfRequest = date
                        print("Date, recieved in check: \(date)")
                    }
                case let .failure(error):
                    errors.append(error)
                }
                group.leave()
            }
        }
        // выполняется в любом случае раньше запроса! Как исполнить после?
        if dateOfRequest == UserSettings.previousDayDate {
            print("PastData date is up to date")
            return true
        } else {
            print("PastData isn't up to date, need to update PastPrice Data")
            return false
        }
    }
    
    
    
    // Функция : // наполнение dictOfPastPrices - цены закрытия прошлого дня
    static func pastStockPricesDictionaryFillingAPI(completion: @escaping (Result<Void, PortfolioFetchError>) -> Void) {
        let group = DispatchGroup()
        var errors: [Error] = []
        // TODO: добавить проверку на ДАТУ, чтобы пропустить запрос, если уже есть данные на эту дату
//        group.enter()
//        var dateOfRequest = ""
//        networkStockInfoManager.fetchPastStockPrice(forCompany: "AAPL") { (dateOfPastStockPrice) in
//            syncQueue.async(flags: .barrier) {
//                switch dateOfPastStockPrice {
//                case let .success(datePastPrice):
//                    if let date = datePastPrice.date {
//                        dateOfRequest = date
//                        UserSettings.previousDayDate = dateOfRequest
//                    }
//                    //и сохранить в юзердефалтс
//                case let .failure(error):
//                    errors.append(error)
//                }
//
//                group.leave()
//            }
//        }
        if pastPricesUpToDate() {
            return
        } else {
            print("Updating past prices...")
            for ticker in arrayOfTickers {
                group.enter()
                networkStockInfoManager.fetchPastStockPrice(forCompany: ticker) { pastStockPrice in
                    syncQueue.async(flags: .barrier) {
                        switch pastStockPrice {
                        case let .success(pastPrice):
                            self.dictOfPastPrices[ticker] = pastPrice.close
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
    }
    
     // TODO: !!!!!!!!!!!!!!!!!!!!!!!!
    // Функция : считаем размер портфеля на закрытии прошлого дня и сохраняем в память
    static func calculatePreviousDayPortfolioAmountAndSaveValueInUserDefaults() {
        syncQueue.sync(flags: .barrier) {
            // считаем значение размера портфеля на конец предыдущего дня
            var previousDayPortfolioAmount = 0.0
            for ticker in arrayOfTickers {
                if
                    let number = dictOfNubmerOfStocks[ticker],
                    let price = dictOfPastPrices[ticker]
                {
                    let oldAmount = round(Double(number) * Double(price)*10)/10
                    previousDayPortfolioAmount += oldAmount
                }

            }
            UserSettings.previousDayPortfolioAmount = previousDayPortfolioAmount
        }
    }
    
    // Функция: Получение данных, расчет в одной функции.
//    static func 
    
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
                    dictOfNubmerOfStocks[arrayOfTickers[i]] = round(Double( valueAmount / valuePrice )*10)/10
                }
            }
        }
    }
    
    // Функция 6: Cохранение dictOfNumberOfStocks в память телефона (в UserDefaults)
    static func saveNumberOfStocksInUserDefaults() {
        UserDefaults.standard.set(StocksDataManager.dictOfNubmerOfStocks, forKey: "numberOfStocks")
    }
    
    // Функция 7: Загрузка dictOfNumberOfStocks из памяти телефона (из UserDefaults)
    static func loadNumberOfStocksFromUserDefaults() {
           if let numberOfStocks = UserDefaults.standard.dictionary(forKey: "numberOfStocks") as? [String : Double] {
               dictOfNubmerOfStocks = numberOfStocks
           }
       }
    
    // Функция Получение данных о ценах и капитализации при указании размера портфеля (Первичное указание значения, или его изменение в дальнейшем)
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
    
    // Функция Получения данных о ценах при обновлении портфеля (Обновляем только цену акции)
    static func getOnlyPriceDataAPIandRefreshAllDictionaries(using completionHandler: @escaping (Result<Void, PortfolioFetchError>) -> Void) {
        stockPricesDictionaryFillingAPI { pricesResult in
            var errors: [Error] = []
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
    
    // Функция обновления словарей при обновлении только цены акций
    static func refreshDictOfAmountsAndPortfolioAmount() {
        syncQueue.sync(flags: .barrier) {
            // считаем новое значение размера портфеля
            var newPortfolioAmount = 0.0
            for ticker in arrayOfTickers {
                if
                    let number = dictOfNubmerOfStocks[ticker],
                    let price = dictOfPrices[ticker]
                {
                    let newAmount = round(Double(number) * Double(price)*10)/10
                    dictOfAmounts[ticker] = newAmount
                    newPortfolioAmount += newAmount
                }

            }
            UserSettings.portfolioAmount = newPortfolioAmount
        }
    }
    
    static func refreshDictOfShares() {
        syncQueue.sync(flags: .barrier) {
            for ticker in arrayOfTickers {
                if
                    let amount = dictOfAmounts[ticker],
                    let portfolioAmount = UserSettings.portfolioAmount
                {
                    dictOfShares[ticker] = round(Double(amount / portfolioAmount)*10000)/10000
                }
            }
        }
    }
    
    // Функция 8: Построение портфеля для отображения в TableView
    static func getPortfolio() -> [CompanyInfoModel] {
        var portfolio = [CompanyInfoModel]()
        for ticker in arrayOfTickers {
            if
                let valueShare = dictOfShares[ticker],
                let valueAmount = dictOfAmounts[ticker],
                let valuePrice = dictOfPrices[ticker],
                let valueNumberOfStocks = dictOfNubmerOfStocks[ticker]
            {
                portfolio.append(CompanyInfoModel(
                    ticker: ticker,
                    share: String(format: "%.2f", valueShare*100) + "%",
                    amount: String(format: "%.2f", valueAmount) + "$",
                    price: String(format: "%.2f", valuePrice),
                    quantity: String(format: "%.1f", valueNumberOfStocks)
                ))
            }
        }
        // сортировка по доле компании в портфеле
        portfolio = portfolio.sorted(by: {$0.share > $1.share })
        return portfolio
    }
    
}
