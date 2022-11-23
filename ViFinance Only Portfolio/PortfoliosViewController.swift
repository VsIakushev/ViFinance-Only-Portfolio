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
    
    let arrayOfTickers = ["AAPL", "MSFT", "GOOG", "BRK.B"]
    let arrayOfMarketCapAPI = [2332.0, 2033.0, 1109.0, 713.0]
    let arrayOfPricesAPI = [153.12, 247.42, 120.57, 330.14]

    var PortfolioAmountNew = 10000.0

    var dictOfMarketCap = [String:Double]()
    var dictOfShares = [String:Double]()
    var dictOfPrices = [String:Double]()
    var dictOfAmounts = [String:Double]()
    var dictOfNubmerOfStocks = [String:Double]()

    var summOfMarketCaps = 0
    
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
        print("Total market cap: \(PortfolioModelOld.summOfMarketCaps)")
        print("Array of market cap: \(PortfolioModelOld.arrayOfMarketCap)")
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
        
        totalMarketCapCalculation()
        stockSharesCalculation()
        
    
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
    
    func totalMarketCapCalculation(){
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
