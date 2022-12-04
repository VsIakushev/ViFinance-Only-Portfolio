//
//  PortfoliosViewController.swift
//  ViFinance Only Portfolio
//
//  Created by Vitaliy Sergeevich on 16.10.2022.
//  Copyright © 2022 Vitaliy Iakushev. All rights reserved.
//

import UIKit

var PortfolioAmount = 0.0

class CustomCell: UITableViewCell {
    
    @IBOutlet weak var tickerLabel: UILabel!
    @IBOutlet weak var shareLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var QuantityLabel: UILabel!
    
}

struct PortfolioFetchError: Error {
    var errors: [Error]
}

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


class PortfoliosViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var testLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var testString = "0"
    
    @IBAction func testButton(_ sender: UIButton) {
        //        print("Total market cap: \(PortfolioModel.summOfMarketCaps)")
    }
    
    // MARK: Editing Amount
    
    @IBAction func editPortfolioAmount(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Edit Portfolio Amount", message: "Enter your Portfolio amount", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            let tf = alertController.textFields?.first
            if let newPortfolioAmount = tf?.text {
                
                PortfolioAmount = Double(newPortfolioAmount) ?? 0.0
                if PortfolioAmount == Double(newPortfolioAmount) {
                    UserSettings.portfolioAmount = PortfolioAmount
                    self.amountLabel.text = newPortfolioAmount
                    self.activityIndicator.isHidden = false
                    
                    PortfolioModel.getMarketCapAndPriceDataAPIandFillAllDictionaries { result in
                        PortfolioAmount = UserSettings.portfolioAmount
                        PortfolioModel.stockSharesDictionaryFilling()
                        PortfolioModel.dictOfAmountsFilling()
                        PortfolioModel.dictOfNumberOfStocksFilling()
                        self.activityIndicator.isHidden = true
                        
                        // Загрузка суммы портфеля
                        self.amountLabel.text = String(PortfolioAmount)
                        self.stocksInPortfolio = PortfolioModel.getPortfolio()
                        self.tableView.reloadData()
                    }
                } else {
                    self.amountLabel.text = "Bad value!"
                    
                    //                    PortfolioModel.totalMarketCapCalculationAndDictOfMarketCapFilingAPI()
                    //                    PortfolioModel.stockPricesDictionaryFillingAPI()
                    //                    PortfolioModel.stockSharesDictionaryFilling()
                    //                    PortfolioModel.dictOfAmountsFilling()
                    //                    PortfolioModel.dictOfNumberOfStocksFilling()
                    //
                    //                    self.stocksInPortfolio = PortfolioModel.getPortfolio()
                    //                    self.tableView.reloadData()
                    
                    let alert = UIAlertController(title: "Wrong format!", message: "Enter your portfolio amount", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        alertController.addTextField { _ in }
        alertController.textFields?.first?.keyboardType = .decimalPad
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    let tableViewRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        
        return refreshControl
    }()
    
    // две функции, для скрытия клавиатуры
    // по свайпу вниз
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    @objc func hideKeyboardOnSwipeDown() {
        view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    } // скрытие клавиатуры после ввода по тапу на пустое поле
    
    var stocksInPortfolio = PortfolioModel.getPortfolio()
    
    let networkStockInfoManager = NetworkStockManager()
    
    // MARK : viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.refreshControl = tableViewRefreshControl
        
        PortfolioModel.getMarketCapAndPriceDataAPIandFillAllDictionaries { result in
            PortfolioAmount = UserSettings.portfolioAmount
            PortfolioModel.stockSharesDictionaryFilling()
            PortfolioModel.dictOfAmountsFilling()
            PortfolioModel.dictOfNumberOfStocksFilling()
            self.activityIndicator.isHidden = true
            
            // Загрузка суммы портфеля
            self.amountLabel.text = String(PortfolioAmount)
            self.stocksInPortfolio = PortfolioModel.getPortfolio()
            self.tableView.reloadData()
        }
        
//        self.tableView.reloadData()
        // обновление таблицы при загрузке, чтобы сразу были видны значения
        
        // Добавляю свайп, по которому убирается клавиатура
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.hideKeyboardOnSwipeDown))
        swipeDown.delegate = self
        swipeDown.direction =  UISwipeGestureRecognizer.Direction.down
        self.tableView.addGestureRecognizer(swipeDown)
        
        tableView.tableFooterView = UIView() //скрыл разлиновку таблицы ниже, последнего элемента портфеля.
        
    }
    
    @objc private func refresh(sender: UIRefreshControl) {
        PortfolioModel.getMarketCapAndPriceDataAPIandFillAllDictionaries { result in
            PortfolioAmount = UserSettings.portfolioAmount
            PortfolioModel.stockSharesDictionaryFilling()
            PortfolioModel.dictOfAmountsFilling()
            PortfolioModel.dictOfNumberOfStocksFilling()
            self.activityIndicator.isHidden = true
            
            // Загрузка суммы портфеля
            self.amountLabel.text = String(PortfolioAmount)
            self.stocksInPortfolio = PortfolioModel.getPortfolio()
            self.tableView.reloadData()
        }
        sender.endRefreshing()
    }
}

extension PortfoliosViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stocksInPortfolio.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomCell
        cell.tickerLabel.text = stocksInPortfolio[indexPath.row].ticker
        cell.shareLabel.text = String(stocksInPortfolio[indexPath.row].share)
        cell.amountLabel.text = String(stocksInPortfolio[indexPath.row].amount)
        cell.priceLabel.text = String(stocksInPortfolio[indexPath.row].price)
        cell.QuantityLabel.text = String(stocksInPortfolio[indexPath.row].quantity)
        
        return cell
    }
}
