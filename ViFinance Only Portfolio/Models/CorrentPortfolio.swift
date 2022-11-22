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



struct CompanyInfo {
    var ticker : String
    var share : String // доля  портфеле в %
    var amount : Double // сумма позиции в портфеле в $
    var price : Double // цена акции
    var quantity : Int // количество акций в портфеле
}



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
    
    
    
    static func recieveMarketCapData(forCompany company: String) {
        //тест получения данных об акции с помощью API
        
//        networkStockInfoManager.fetchStockMarketCapitalization(forCompany: company)
    
    }
    
    // Доли компаний в портфеле - в зависимости от капитализации. Равна капитализации конкретной компании / Сумма капитализации всех компаний. 1) Расчитать сумму капитализации всех компаний. 2) Расчитать долю каждой компании и добавить значение в массив
    func calculateShares() {
        var markerCapSumm = 0
//        for company in staticArrayOfTickers {
//        markerCapSumm += networkStockInfoManager.fetchStockMarketCapitalization(forCompany: company)
//
//        }
    }
    
    
    
    static func getPortfolio() -> [CompanyInfo] {
        var Portfolio = [CompanyInfo]()
        arrayOfAmounts.removeAll()
        
        for i in 0..<arrayOfTickers.count {
            arrayOfAmounts.append(round((Double(amountOfPortfolio) * arrayOfShares[i] / 100)*10)/10)
            
        }
        
        for i in 0..<arrayOfTickers.count {
            Portfolio.append(CompanyInfo(ticker: arrayOfTickers[i], share: String(arrayOfShares[i]) + "%", amount: arrayOfAmounts[i], price: arrayOfPrices[i], quantity: Int(arrayOfAmounts[i] / arrayOfPrices[i])))
        }
        return Portfolio
    }
}
