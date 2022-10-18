//
//  PortfolioModel.swift
//  ViFinance Only Portfolio
//
//  Created by Vitaliy Sergeevich on 17.10.2022.
//  Copyright © 2022 Vitaliy Iakushev. All rights reserved.
//

import Foundation

// сделать передачу amountPortfolio между свифт-файлами, сюда, для расчета

//struct PortfolioModel {
//    var ticker : String
//    var share : Double
//    var amount : Double
//    var price : Double
//    var quantity : Int
//
//    
//    static  let arrayOfTickers = ["AAPL", "MSFT", "GOOG", "BRK.B", "META", "NVDA"]
//    static let arrayOfShares = [21.15, 17.22, 11.30, 6.55, 4.35, 3.47 ]
//    static var arrayOfAmounts = [0.0]
//    static  let arrayOfPrices = [153.12, 247.42, 120.57, 330.14, 140.32, 160.58]
//    static  let arrayOfNubmerOfStocks = [45, 22, 16, 13, 7, 6]
//    
//    static func getPortfolio() -> [PortfolioModel] {
//        var Portfolio = [PortfolioModel]()
//        arrayOfAmounts.removeAll()
//        
//        
//        for i in 0..<arrayOfTickers.count {
//            arrayOfAmounts.append((10000 * arrayOfShares[i]) / 100)        }
//        
//        for i in 0..<arrayOfTickers.count {
//            Portfolio.append(PortfolioModel(ticker: arrayOfTickers[i], share: arrayOfShares[i], amount: arrayOfAmounts[i], price: arrayOfPrices[i], quantity: Int(arrayOfAmounts[i] / arrayOfPrices[i])))
//            
//        }
//        return Portfolio
//    }
//}

