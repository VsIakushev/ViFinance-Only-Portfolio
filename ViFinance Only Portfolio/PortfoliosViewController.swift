//
//  PortfoliosViewController.swift
//  ViFinance Only Portfolio
//
//  Created by Vitaliy Sergeevich on 16.10.2022.
//  Copyright © 2022 Vitaliy Iakushev. All rights reserved.
//

import UIKit

var amountOfPortfolio = 15000

class CustomCell: UITableViewCell {
    
    @IBOutlet weak var tickerLabel: UILabel!
    @IBOutlet weak var shareLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var QuantityLabel: UILabel!
    
}
///////

struct PortfolioModel {
    var ticker : String
    var share : Double
    var amount : Double
    var price : Double
    var quantity : Int

    
    static  let arrayOfTickers = ["AAPL", "MSFT", "GOOG", "BRK.B", "META", "NVDA"]
    static let arrayOfShares = [21.15, 17.22, 11.30, 6.55, 4.35, 3.47 ]
    static var arrayOfAmounts = [0.0]
    static  let arrayOfPrices = [153.12, 247.42, 120.57, 330.14, 140.32, 160.58]
    static  let arrayOfNubmerOfStocks = [45, 22, 16, 13, 7, 6]
    
    static func getPortfolio() -> [PortfolioModel] {
        var Portfolio = [PortfolioModel]()
        arrayOfAmounts.removeAll()
        
        
        for i in 0..<arrayOfTickers.count {
            arrayOfAmounts.append(round((Double(amountOfPortfolio) * arrayOfShares[i] / 100)*10)/10)
//            arrayOfAmounts.append((10000 * arrayOfShares[i]) / 100)
        }
        
        for i in 0..<arrayOfTickers.count {
            Portfolio.append(PortfolioModel(ticker: arrayOfTickers[i], share: arrayOfShares[i], amount: arrayOfAmounts[i], price: arrayOfPrices[i], quantity: Int(arrayOfAmounts[i] / arrayOfPrices[i])))
            
        }
        return Portfolio
    }
}

///////
class PortfoliosViewController: UIViewController {

    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var calculateButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var stocksInPortfolio = PortfolioModel.getPortfolio()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        amountLabel.text = String(amountOfPortfolio)
       
        
        tableView.tableFooterView = UIView() //скрыл разлиновку таблицы ниже, последнего элемента портфеля.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func calculatePressed(_ sender: UIButton) {
        amountLabel.text = amountTextField.text ?? String(0)
        amountOfPortfolio = Int(amountLabel.text!)!
        
        stocksInPortfolio = PortfolioModel.getPortfolio()
        tableView.reloadData()
        
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
        
        // вставить параметры, после создания модели
        
        return cell
    }
    
    
}
