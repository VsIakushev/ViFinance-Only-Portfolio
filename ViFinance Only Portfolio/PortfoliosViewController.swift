//
//  PortfoliosViewController.swift
//  ViFinance Only Portfolio
//
//  Created by Vitaliy Sergeevich on 16.10.2022.
//  Copyright © 2022 Vitaliy Iakushev. All rights reserved.
//

import UIKit

var amountOfPortfolio = 0.0

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
    var amount : Double
    var price : Double
    var quantity : Int

    
    static  let arrayOfTickers = ["AAPL", "MSFT", "GOOG", "BRK.B", "META", "NVDA"]
    static var arrayOfShares = [21.15, 17.22, 11.31, 6.55, 4.35, 3.47 ]
    static var arrayOfAmounts = [0.0]
    static  let arrayOfPrices = [153.12, 247.42, 120.57, 330.14, 140.32, 160.58]
    static  let arrayOfNubmerOfStocks = [45, 22, 16, 13, 7, 6]
    
    static func getPortfolio() -> [PortfolioModel] {
        var Portfolio = [PortfolioModel]()
        arrayOfAmounts.removeAll()
        
        for i in 0..<arrayOfTickers.count {
            arrayOfAmounts.append(round((Double(amountOfPortfolio) * arrayOfShares[i] / 100)*10)/10)
            
        }
        
        for i in 0..<arrayOfTickers.count {
            Portfolio.append(PortfolioModel(ticker: arrayOfTickers[i], share: String(arrayOfShares[i]) + "%", amount: arrayOfAmounts[i], price: arrayOfPrices[i], quantity: Int(arrayOfAmounts[i] / arrayOfPrices[i])))
        }
        return Portfolio
    }
}


class PortfoliosViewController: UIViewController, UIGestureRecognizerDelegate {

    
    @IBOutlet weak var amountLabel: UILabel!
    
    // MARK: Editing Amount
    @IBAction func editPortfolioAmount(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Edit Portfolio Amount", message: "Enter your Portfolio amount", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            let tf = alertController.textFields?.first
            if let newPortfolioAmount = tf?.text {
               
                amountOfPortfolio = Double(newPortfolioAmount) ?? 0.0
                if amountOfPortfolio == Double(newPortfolioAmount) {
                    UserSettings.portfolioAmount = amountOfPortfolio
                    self.amountLabel.text = newPortfolioAmount
                    self.stocksInPortfolio = PortfolioModel.getPortfolio()
                    self.tableView.reloadData()
                } else {
                    self.amountLabel.text = "Bad value!"
                    self.stocksInPortfolio = PortfolioModel.getPortfolio()
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
    
    var stocksInPortfolio = PortfolioModel.getPortfolio()
    
    // MARK : viewDidLoad
    
//    override func viewWillAppear(_ animated: Bool) {
//    super.viewWillAppear(animated)
//        amountOfPortfolio = UserSettings.portfolioAmount
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        amountOfPortfolio = UserSettings.portfolioAmount
        amountLabel.text = String(amountOfPortfolio)
        self.stocksInPortfolio = PortfolioModel.getPortfolio()
        self.tableView.reloadData()
        // обновление таблицы при загрузке, чтобы сразу были видны значения
        
        
    // Добавляю свайп, по которому убирается клавиатура
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.hideKeyboardOnSwipeDown))
        swipeDown.delegate = self
        swipeDown.direction =  UISwipeGestureRecognizer.Direction.down
        self.tableView.addGestureRecognizer(swipeDown)
        
        
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
    
//    @IBAction func calculatePressed(_ sender: UIButton) {
//
//        if let _ = Int(amountTextField.text!) {
//            amountLabel.text = amountTextField.text ?? String(0)
//            amountOfPortfolio = Int(amountLabel.text!)!
//
//            stocksInPortfolio = PortfolioModel.getPortfolio()
//            tableView.reloadData()
//            // обновление таблицы после нажатия кнопки
//        } else {
//            let alert = UIAlertController(title: "Wrong format!", message: "Enter your portfolio amount", preferredStyle: .alert)
//            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//            alert.addAction(okAction)
//            present(alert, animated: true, completion: nil)
//            print("Wrong amount format!")
//        }
//    }
    
    
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


// This extension turns on ability to add "Done" Button to NumPad-keyboard (in Attributes Inspector)
// Have to find out how to make connection between Done-button and calculations in class.

extension UITextField{
    @IBInspectable var doneAccessory: Bool{
        get{
            return self.doneAccessory
        }
        set (hasDone) {
            if hasDone{
                addDoneButtonOnKeyboard()
            }
        }
    }

    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        self.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction() {
        
        print("Done button action works")
        
        self.resignFirstResponder()
        
    }
}

