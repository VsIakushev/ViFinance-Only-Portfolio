//
//  CorrentPortfolio.swift
//  ViFinance Only Portfolio
//
//  Created by Vitaliy Sergeevich on 19.11.2022.
//  Copyright © 2022 Vitaliy Iakushev. All rights reserved.
//

import Foundation


struct PortfolioModelTest {
    let arrayOfTickersTest = ["BIIB", "MA", "AMAT", "SCHW"]
    
    func PortfolioModelCountTest() -> Int {
        return arrayOfTickersTest.count
    }
}

// Создаю новую структуру/класс с Компанией (отдельный Класс от Портфеля?), ее тикером, долей, суммой, ценой и количеством. Далее из таких Компаний будет сформирован Портфель (Массив), его можно будет отсортировать по сумме в портфеле.
// 1. Расчет доли: получаем MarketCap API каждой компании из списка, суммируем, находим долю каждой компании, и добавляем в массив в том же порядке, что и компании.
// 2. Аналогичным образом получаем Price API и добавляем в массив в той же последовательности.
//
// Функция getPortfolio запускает функции 1(MarcetCap API + array) и 2 (Price API + array), и строит/обновляет портфель при запуске приложения, или при изменении заданной суммы портфеля.

// !!! Портфель должен сохранять количество акций, которое получилось при вводе портфеля. Когда клиент заходит в следующий раз - должна расчитываться актуальная стоимость портфеля, и указываться в Portfolio Amount. Поэтому функция построения портфеля с нуля на основании Portfolio Amount должна быть не при каждом вводе.
// создать 2 функции: CreatePortfolio и RefreshPortfolio. Первая применяется при вводе суммы портфеля вручную. Вторая - при открытии приложения, если сумма портфеля не 0.
// хранить данные о существующем количестве акций для обновления портфеля в userDefaults

// MarketCap обновляется только при изменении суммы портфеля вручную, чтобы расчитать пропорции. При обновлении при открытии (во viewDidLoad) подгружать только цену, и умножать на прежнее количество акций(сохраненное в userDefaults) = получим Portfolio amount
// Добавить ActivityIndicator в момент первой загрузки, и при обновлении PortfolioAmount


struct CompanyInfo {
    var ticker : String
    var share : String // доля  портфеле в %
    var amount : Double // сумма позиции в портфеле в $
    var price : Double // цена акции
    var quantity : Int // количество акций в портфеле
}


var testValue: Int = 0
let networkStockInfoManager = NetworkStockManager()
let staticArrayOfTickers = ["BIIB", "WFC", "DIS", "BLK", "JPM"]

struct PortfolioModelTestNew {
//    var ticker : String
//    var share : String // доля  портфеле в %
//    var amount : Double // сумма позиции в портфеле в $
//    var price : Double // цена акции
//    var quantity : Int // количество акций в портфеле

    
    static  let arrayOfTickers = ["AAPL", "MSFT", "GOOG", "BRK.B", "META", "NVDA"]
    static var arrayOfShares = [21.15, 17.22, 11.31, 6.55, 4.35, 3.47 ]
    static var arrayOfAmounts = [0.0]
    static  let arrayOfPrices = [153.12, 247.42, 120.57, 330.14, 140.32, 160.58]
    static  let arrayOfNubmerOfStocks = [45, 22, 16, 13, 7, 6]
    
    // получение данных через API и заполнение массивов
    
    
    
//    static func recieveMarketCapData(forCompany company: String) -> Int {
        //тест получения данных об акции с помощью API
//        testValue = networkStockInfoManager.fetchStockMarketCapitalization(forCompany: "AAPL") { currentStockMarketCapData in
//
//        }
//
//    }
    
    // Доли компаний в портфеле - в зависимости от капитализации. Равна капитализации конкретной компании / Сумма капитализации всех компаний. 1) Расчитать сумму капитализации всех компаний. 2) Расчитать долю каждой компании и добавить значение в массив
//    func apiToInt(company: String) -> Int {
//        networkStockInfoManager.fetchStockMarketCapitalization(forCompany: company) { currentStockMarketCap in
//        currentStockMarketCap.marketCap
//            return currentStockMarketCap.marketCap
//            }
//        }
    
//    func creatingMarketCapInt() {
//        networkStockInfoManager.fetchStockMarketCapitalization(forCompany: "AAPL") { [weak self] currentStockMarketCap in
//                print(currentStockMarketCap.marketCap)
//                guard let self = self else { return }
//                self.updateInterface(marketCap: currentStockMarketCap)
//            }
//    }
//    
//    func updateInterface(marketCap: CurrentStockMarketCap){
//        DispatchQueue.main.async {
//            self.testLabel.text = marketCap.marketCapString
//        }
//
//    }
    
    func calculateShares() {
        var markerCapSumm = 0
        
        
        
//        for company in staticArrayOfTickers {
//            let currentStockMarketCap =  networkStockInfoManager.fetchStockMarketCapitalization(forCompany: company) { currentStockMarketCap in
//                currentStockMarketCap.marketCap
//            }
//        }
    }
    
    
    
    static func getPortfolio() -> [CompanyInfo] {
        var Portfolio = [CompanyInfo]()
        arrayOfAmounts.removeAll()
        
        for i in 0..<arrayOfTickers.count {
            arrayOfAmounts.append(round((Double(PortfolioAmount) * arrayOfShares[i] / 100)*10)/10)
            
        }
        
        for i in 0..<arrayOfTickers.count {
            Portfolio.append(CompanyInfo(ticker: arrayOfTickers[i], share: String(arrayOfShares[i]) + "%", amount: arrayOfAmounts[i], price: arrayOfPrices[i], quantity: Int(arrayOfAmounts[i] / arrayOfPrices[i])))
        }
        return Portfolio
    }
}
