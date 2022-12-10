//
//  CompanyCell.swift
//  ViFinance Only Portfolio
//
//  Created by Vitaliy Sergeevich on 04.12.2022.
//  Copyright © 2022 Vitaliy Iakushev. All rights reserved.
//

import UIKit

final class CompanyCell: UITableViewCell {
    
    @IBOutlet private weak var tickerLabel: UILabel!
    @IBOutlet private weak var shareLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var quantityLabel: UILabel!
    
    func configure(with info: CompanyInfoModel) {
        tickerLabel.text = info.ticker
        shareLabel.text = String(info.share)
        amountLabel.text = String(info.amount)
        priceLabel.text = String(info.price)
        quantityLabel.text = String(info.quantity)
    }
    
}

// TODO: результаты за день в %, зеленый если +, красный если -, и сравнение с S&P500
//

// Пример архитектуры

// Model - описание модели
// Network Class - создание URL сессий и получение данных с бэка (указали URL, создали сессию и получили данные или обработали ошибки
// StocksManager - обработка и сортировка полученных данных
// ViewModel - подготовили модели для отображения
// ViewController - оображение этих данных
//
//final class NWManager {
//    
//    static let shared = NWManager()
//    
//    private init() {}
//    
//    func getData(from url: URL, completion: @escaping (Any) -> Void) {
//        let dataFromBackend = ""
//        completion(dataFromBackend)
//    }
//    
//}
//
//final class StocksManager {
//    
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
//    
//}
//
//final class ViewController: UIViewController {
//    
//    private let stocksManager = StocksManager()
//    private var models: [Any] = []
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        stocksManager.receiveStocks { [weak self] models in
//            guard let self = self else { return }
//            self.models = models
//
//            DispatchQueue.main.async {
//                //self.tableView.reloadData()
//            }
//        }
//    }
//    
//}
