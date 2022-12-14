//
//  PortfoliosViewController.swift
//  ViFinance Only Portfolio
//
//  Created by Vitaliy Sergeevich on 16.10.2022.
//  Copyright © 2022 Vitaliy Iakushev. All rights reserved.
//

import UIKit

var PortfolioAmount = 0.0 // перенести в Settings

struct PortfolioFetchError: Error {
    var errors: [Error]
}

class PortfoliosViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dayChangeLabel: UILabel!
    @IBOutlet weak var testLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // TODO: Куда убрать?
    // Функция расчета изменения стоимости портфеля за текущий день.
    func calculateDayChangeInPercent() {
        
        let dayChangeInPercent = ((UserSettings.portfolioAmount/UserSettings.previousDayPortfolioAmount)-1)*100
        print("Day change is: \(String(format: "%.1f", dayChangeInPercent))%")
        self.dayChangeLabel.text = "(\(String(format: "%.1f", dayChangeInPercent))%)"
        print("Day change is: \(String(format: "%.1f", dayChangeInPercent))%")
        if dayChangeInPercent > 0 {
            self.dayChangeLabel.textColor = UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
        } else if dayChangeInPercent < 0 {
            self.dayChangeLabel.textColor = UIColor(red: 0.7, green: 0.0, blue: 0.0, alpha: 1.0)
        } else {
            self.dayChangeLabel.textColor = .gray
        }
    }
    
    var testString = "0"
    
    @IBAction func testButton(_ sender: UIButton) {
        print(stocksInPortfolio)
    }
    @IBAction func testButton2(_ sender: UIButton) {
        stocksInPortfolio.sorted(by: {$0.share > $1.share })
        
    }
//    {$0.share > $1.share }
    
    // MARK: Editing Amount
    @IBAction func editPortfolioAmount(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Edit Portfolio Amount", message: "Enter your Portfolio amount", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            let tf = alertController.textFields?.first
            if let newPortfolioAmount = tf?.text {
                
                PortfolioAmount = Double(newPortfolioAmount) ?? 0.0
                if PortfolioAmount == Double(newPortfolioAmount) {
                    PortfolioAmount = round(Double(PortfolioAmount)*100)/100
                    UserSettings.portfolioAmount = PortfolioAmount
                    self.amountLabel.text = String(format: "%.2f", newPortfolioAmount)  + "$"
                    self.activityIndicator.isHidden = false
                    StocksDataManager.getMarketCapAndPriceDataAPIandFillAllDictionaries { result in
                        PortfolioAmount = UserSettings.portfolioAmount
                        StocksDataManager.stockSharesDictionaryFilling()
                        StocksDataManager.dictOfAmountsFilling()
                        StocksDataManager.dictOfNumberOfStocksFilling()
                        
                        //Сохраняем dictOfNumberOfStocks в userDefaults для использования при построения этого портфеля в дальнейшем
                        StocksDataManager.saveNumberOfStocksInUserDefaults()
                        self.activityIndicator.isHidden = true
                        
                        // Загрузка суммы портфеля
                        self.amountLabel.text = String(PortfolioAmount)
                        self.stocksInPortfolio = StocksDataManager.getPortfolio()
                        self.tableView.reloadData()
                        
                        // Расчет изменения стоимости портфеля за текущий день в %
                        StocksDataManager.pastStockPricesDictionaryFillingAPI { _ in
                            StocksDataManager.calculatePreviousDayPortfolioAmountAndSaveValueInUserDefaults()
                            self.calculateDayChangeInPercent()
                        }
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
    
    var stocksInPortfolio = StocksDataManager.getPortfolio()
    
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
    // скрытие клавиатуры после ввода по тапу на пустое поле
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    let networkStockInfoManager = NetworkStockManager()
    
    
    
    // MARK : viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testLabel.textColor = .red
        
        
        tableView.refreshControl = tableViewRefreshControl
        
        StocksDataManager.loadNumberOfStocksFromUserDefaults()
        
        StocksDataManager.getOnlyPriceDataAPIandRefreshAllDictionaries { result in
            StocksDataManager.refreshDictOfAmountsAndPortfolioAmount()
            StocksDataManager.refreshDictOfShares()
            PortfolioAmount = UserSettings.portfolioAmount
            self.activityIndicator.isHidden = true
            
            // Загрузка суммы портфеля и отображение таблицы
            self.amountLabel.text = String(format: "%.2f", PortfolioAmount) + "$"
            self.stocksInPortfolio = StocksDataManager.getPortfolio()
            self.tableView.reloadData()
            
            // Расчет изменения стоимости портфеля за текущий день в %
            StocksDataManager.pastStockPricesDictionaryFillingAPI { _ in
                StocksDataManager.calculatePreviousDayPortfolioAmountAndSaveValueInUserDefaults()
                self.calculateDayChangeInPercent()
            }
        }
        
        
        
        
        // Добавляю свайп, по которому убирается клавиатура
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.hideKeyboardOnSwipeDown))
        swipeDown.delegate = self
        swipeDown.direction =  UISwipeGestureRecognizer.Direction.down
        self.tableView.addGestureRecognizer(swipeDown)
        
        tableView.tableFooterView = UIView() //скрыл разлиновку таблицы ниже, последнего элемента портфеля.
    }
    
    @objc private func refresh(sender: UIRefreshControl) {
        StocksDataManager.getOnlyPriceDataAPIandRefreshAllDictionaries { result in
            StocksDataManager.refreshDictOfAmountsAndPortfolioAmount()
            StocksDataManager.refreshDictOfShares()
            PortfolioAmount = UserSettings.portfolioAmount
            self.activityIndicator.isHidden = true
            
            // Загрузка суммы портфеля и отображение таблицы
            self.amountLabel.text = String(format: "%.2f", PortfolioAmount)  + "$"
            self.stocksInPortfolio = StocksDataManager.getPortfolio()
            self.tableView.reloadData()
            
            // Расчет изменения стоимости портфеля за текущий день в %
            StocksDataManager.pastStockPricesDictionaryFillingAPI { _ in
                StocksDataManager.calculatePreviousDayPortfolioAmountAndSaveValueInUserDefaults()
                self.calculateDayChangeInPercent()
            }
        }
        sender.endRefreshing()
    }
}

extension PortfoliosViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stocksInPortfolio.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "Cell", for: indexPath
            ) as! CompanyCell
        
        let info = self.stocksInPortfolio[indexPath.row]
        cell.configure(with: info)
        
        return cell
    }
    
}
