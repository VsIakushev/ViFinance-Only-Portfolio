//
//  StockDataManager.swift
//  ViFinance Only Portfolio
//
//  Created by Vitaliy Sergeevich on 07.12.2022.
//  Copyright © 2022 Vitaliy Iakushev. All rights reserved.
//

import Foundation

// перенести сюда функции получения и обработки данных (1-6)

final class StocksDataManager {
    
//    private var sortedStocks: [Any] = []
//
//    private let networkManager: NWManager
//
//    private var firstArray: [String: Any] = [:]
//    private var secondArray: [String: Any] = [:]
//
//    // здесь создать глобальную диспатч группу
//
//    init(networkManager: NWManager = NWManager.shared) {
//        self.networkManager = networkManager
//    }
//
//    func receiveStocks(completion: @escaping (([Any]) -> Void)) {
//        guard let urlOne = URL(string: "https://google.com"),
//            let urlTwo = URL(string: "https://google.com") else {
//            return
//        }
//
//        // оба запроса надо закинуть в dispatchGroup
//        networkManager.getData(from: urlOne) { [weak self] someData in
//            self?.firstArray = ["oneKey": "SomeData"]
//        }
//
//        networkManager.getData(from: urlTwo) { [weak self] someData in
//            self?.secondArray = ["secondKey": "SomeData"]
//        }
//
//        // как только отработают эти методы внутри диспатч группы, реализуем сортировку этих массивов:
//        sortStocks()
//
//        completion(sortedStocks)
//    }
//
//    private func sortStocks() {
//        // тут происзодит сортиовка
//        sortedStocks.append("Stock")
//    }
}
