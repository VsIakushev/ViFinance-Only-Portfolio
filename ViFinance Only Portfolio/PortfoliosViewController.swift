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

struct PortfolioModel {
    
    var ticker : String
    var share : String
    var amount : String
    var price : Double
    var quantity : Int
    
    static var summOfMarketCaps = 0
//    static var arrayOfSharesNew = [0.0]
//    static var arrayOfMarketCap = [0.0]
    
    static let arrayOfTickers = ["AAPL", "MSFT", "GOOG", "BRK.B"]
//    static let arrayOfMarketCapAPI = [2332.0, 2033.0, 1109.0, 713.0] // TODO: АвтоЗаполение
//    static let arrayOfPricesAPI = [153.12, 247.42, 120.57, 330.14] // TODO: АвтоЗаполение

//    static var PortfolioAmountNew = 10000.0

    static var dictOfMarketCap = [String:Double]()
    static var dictOfShares = [String:Double]()
    static var dictOfPrices = [String:Double]()
    static var dictOfAmounts = [String:Double]()
    static var dictOfNubmerOfStocks = [String:Double]()

    
    // TODO: - Перенести функции сюда из PortfolioModelOld, а так же добавить остальные функции автоматического расчета из Playground
    
    // Функция 1: Считаем сумму капитализации всех компаний и наполнение dictOfMarketCap
    static func totalMarketCapCalculationAndDictOfMarketCapFiling(){
        // делаю в одной функции, чтобы не дублировать запрос к API
        PortfolioModel.summOfMarketCaps = 0
//        PortfolioModel.dictOfMarketCap.removeAll()
        for i in 0..<PortfolioModel.arrayOfTickers.count {
            networkStockInfoManager.fetchStockMarketCapitalization(forCompany: arrayOfTickers[i]) {  currentStockMarketCap in
                PortfolioModel.summOfMarketCaps += currentStockMarketCap.marketCapInt
                PortfolioModel.dictOfMarketCap[arrayOfTickers[i]] = currentStockMarketCap.marketCap
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            print("Sum of Market Cap after Delay is : \(PortfolioModel.summOfMarketCaps)")
        }
    }
    
    // Функция 2: // наполнение dictOfPrices
    static func stockPricesDictionaryFilling() {
//        PortfolioModel.dictOfPrices.removeAll()
        for i in 0..<arrayOfTickers.count {
            networkStockInfoManager.fetchStockPrice(forCompany: arrayOfTickers[i]) { currentStockPrice in
                PortfolioModel.dictOfPrices[arrayOfTickers[i]] = currentStockPrice.price
            }
        }
        
    }
    
    // Функция 3: наполнение dictOfShares
    static func stockSharesDictionaryFilling() {
//        PortfolioModel.dictOfShares.removeAll()
        // Задержка 3 сек, чтобы успеть получить данные (API)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            for i in 0..<dictOfMarketCap.count {
                if let value = dictOfMarketCap[arrayOfTickers[i]] {
                    dictOfShares[arrayOfTickers[i]] = round(Double(value / Double( summOfMarketCaps))*10000)/10000
                }
            }
            
        }
    }
    
     // Функция 4: наполнение dictOfAmounts
    static func dictOfAmountsFilling() {
        //PortfolioModel.dictOfAmounts.removeAll()
        // Задержка 3 сек, чтобы успеть получить данные (API)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            for i in 0..<dictOfShares.count {
                if let value = dictOfShares[arrayOfTickers[i]] {
                    dictOfAmounts[arrayOfTickers[i]] = value*PortfolioAmount
                }
            }
        }
    }
    
     // Функция 5: наполнение dictOfNumberOfStocks
    static func dictOfNumberOfStocksFilling() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            // PortfolioModel.dictOfNubmerOfStocks.removeAll()
            // Задержка 3 сек, чтобы успеть получить данные (API)
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
        for i in 0..<arrayOfTickers.count {
            if let valueShare = dictOfShares[arrayOfTickers[i]], let valueAmount = dictOfAmounts[arrayOfTickers[i]], let valuePrice = dictOfPrices[arrayOfTickers[i]], let valueNumberOfStocks = dictOfNubmerOfStocks[arrayOfTickers[i]] {
                portfolio.append(PortfolioModel(ticker: arrayOfTickers[i], share: String(valueShare*100) + "%", amount: String(format: "%.2f", valueAmount) + "$", price: valuePrice, quantity: Int(valueNumberOfStocks)))
            }
            
        }
        return portfolio
    }
    
    
}

struct PortfolioModelOld {
    var ticker : String
    var share : String
    var amount : String
    var price : Double
    var quantity : Int

    static var summOfMarketCaps = 0
    static var arrayOfSharesNew = [0.0]
    static var arrayOfMarketCap = [0.0]

    static  let arrayOfTickers = ["AAPL", "MSFT", "GOOG", "BRK.B", "META", "NVDA"]
    static var arrayOfShares = [21.15, 17.22, 11.31, 6.55, 4.35, 3.47 ]
    static var arrayOfAmounts = [0.0]
    static  let arrayOfPrices = [153.12, 247.42, 120.57, 330.14, 140.32, 160.58]
    static  let arrayOfNubmerOfStocks = [45, 22, 16, 13, 7, 6]

    static func totalMarketCapCalculation(){
        PortfolioModelOld.summOfMarketCaps = 0
        PortfolioModelOld.arrayOfMarketCap.removeAll()
        for company in PortfolioModelOld.arrayOfTickers {
            networkStockInfoManager.fetchStockMarketCapitalization(forCompany: company) {  currentStockMarketCap in
                PortfolioModelOld.summOfMarketCaps += currentStockMarketCap.marketCapInt
                PortfolioModelOld.arrayOfMarketCap.append(currentStockMarketCap.marketCap)
                //+= marketCap.marketCapInt
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            print("Sum of Market Cap after Delay is : \(PortfolioModelOld.summOfMarketCaps)")

        }
    }

    static func stockSharesCalculation() {
        PortfolioModelOld.arrayOfSharesNew.removeAll()

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            for i in 0..<PortfolioModelOld.arrayOfMarketCap.count {

                let stockShare = (PortfolioModelOld.arrayOfMarketCap[i] / Double(PortfolioModelOld.summOfMarketCaps))
                PortfolioModelOld.arrayOfSharesNew.append(stockShare)
            }
        }
        print(PortfolioModelOld.arrayOfSharesNew)
    }


    static func getPortfolio() -> [PortfolioModelOld] {
        var Portfolio = [PortfolioModelOld]()
        arrayOfAmounts.removeAll()

        for i in 0..<arrayOfTickers.count {
            arrayOfAmounts.append(round((Double(PortfolioAmount) * arrayOfShares[i] / 100)*10)/10)

        }

        for i in 0..<arrayOfTickers.count {
            Portfolio.append(PortfolioModelOld(ticker: arrayOfTickers[i], share: String(arrayOfShares[i]) + "%", amount: String(format: "%.2f", arrayOfAmounts[i]) + "$", price: arrayOfPrices[i], quantity: Int(arrayOfAmounts[i] / arrayOfPrices[i])))
        }
        return Portfolio
    }
}


class PortfoliosViewController: UIViewController, UIGestureRecognizerDelegate {
    
    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var testLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var testString = "0"
    
    
    // MARK: Editing Amount
    // возможно нужно будет добавить [unowned self] перед клоужером, когда его создам
    
    @IBAction func testButton(_ sender: UIButton) {
        print("Total market cap: \(PortfolioModel.summOfMarketCaps)")
        print("Dict of market cap: \(PortfolioModel.dictOfMarketCap)")
        print("Array of shares: \(PortfolioModelOld.arrayOfSharesNew)")
        
    }
    
    
    @IBAction func editPortfolioAmount(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Edit Portfolio Amount", message: "Enter your Portfolio amount", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            let tf = alertController.textFields?.first
            if let newPortfolioAmount = tf?.text {
                
                PortfolioAmount = Double(newPortfolioAmount) ?? 0.0
                if PortfolioAmount == Double(newPortfolioAmount) {
                    UserSettings.portfolioAmount = PortfolioAmount
                    self.amountLabel.text = newPortfolioAmount
                    self.stocksInPortfolio = PortfolioModelOld.getPortfolio()
                    self.tableView.reloadData()
                } else {
                    self.amountLabel.text = "Bad value!"
                    self.stocksInPortfolio = PortfolioModelOld.getPortfolio()
                    self.tableView.reloadData()
                    
                    let alert = UIAlertController(title: "Wrong format!", message: "Enter your portfolio amount", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        alertController.addTextField { _ in }
        alertController.textFields?.first?.keyboardType = .decimalPad
        // можно сделать клавиатуру .decimalPad, но только после проверки соответствия введенного значения Double
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        present(alertController, animated: true, completion: nil)
        
        //        UserSettings.portfolioAmount = amountOfPortfolio
        
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    // две функции, для скрытия клавиатуры по свайпу
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    @objc func hideKeyboardOnSwipeDown() {
        view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    } // скрытие клавиатуры после ввода по тапу на пустое поле
    
    var stocksInPortfolio = PortfolioModelOld.getPortfolio()
    
    // MARK : viewDidLoad
    
    let networkStockInfoManager = NetworkStockManager()
    
    //    override func viewWillAppear(_ animated: Bool) {
    //    super.viewWillAppear(animated)
    //        amountOfPortfolio = UserSettings.portfolioAmount
    //    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) {_ in
            self.activityIndicator.isHidden = true
        }
        PortfolioModel.totalMarketCapCalculationAndDictOfMarketCapFiling()
        PortfolioModelOld.stockSharesCalculation()
        
//        totalMarketCapCalculation()
//        stockSharesCalculation()
        
    
        // Загрузка суммы портфеля
        PortfolioAmount = UserSettings.portfolioAmount
        amountLabel.text = String(PortfolioAmount)
        
        self.stocksInPortfolio = PortfolioModelOld.getPortfolio()
        self.tableView.reloadData()
        // обновление таблицы при загрузке, чтобы сразу были видны значения
        
        // Добавляю свайп, по которому убирается клавиатура
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.hideKeyboardOnSwipeDown))
        swipeDown.delegate = self
        swipeDown.direction =  UISwipeGestureRecognizer.Direction.down
        self.tableView.addGestureRecognizer(swipeDown)
        
        
        tableView.tableFooterView = UIView() //скрыл разлиновку таблицы ниже, последнего элемента портфеля.
        
    }
    
    func updateInterface(marketCap: CurrentStockMarketCap){
        DispatchQueue.main.async {
            self.testLabel.text = marketCap.marketCapString
            self.testString = marketCap.marketCapString
            print(self.testString)
        }
        
    }
    
//    TODO: дублирую в структуру, потом удалить
//    func totalMarketCapCalculation(){
//        PortfolioModelOld.summOfMarketCaps = 0
//        PortfolioModelOld.arrayOfMarketCap.removeAll()
//        for company in PortfolioModelOld.arrayOfTickers {
//            networkStockInfoManager.fetchStockMarketCapitalization(forCompany: company) {  currentStockMarketCap in
//                PortfolioModelOld.summOfMarketCaps += currentStockMarketCap.marketCapInt
//                PortfolioModelOld.arrayOfMarketCap.append(currentStockMarketCap.marketCap)
//                //+= marketCap.marketCapInt
//            }
//        }
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            print("Sum of Market Cap after Delay is : \(PortfolioModelOld.summOfMarketCaps)")
//
//        }
//    }
    
    func stockSharesCalculation() {
        PortfolioModelOld.arrayOfSharesNew.removeAll()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            for i in 0..<PortfolioModelOld.arrayOfMarketCap.count {
                
                let stockShare = (PortfolioModelOld.arrayOfMarketCap[i] / Double(PortfolioModelOld.summOfMarketCaps))
                PortfolioModelOld.arrayOfSharesNew.append(stockShare)
            }
        }
        print(PortfolioModelOld.arrayOfSharesNew)
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
