//
//  ShowCartViewController.swift
//  Kaho Bar
//
//  Created by Johnson on 13/2/2020.
//  Copyright © 2020 Johnson. All rights reserved.
//

import UIKit

class ShowCartViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var cartVCTitle: UILabel!
    @IBOutlet weak var cartTableView: UITableView!
    @IBOutlet weak var cartTotalPrice: UILabel!
    @IBOutlet weak var tabBarIcon: UINavigationItem!
    
    var refreshControl:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cartTableView.rowHeight = UITableView.automaticDimension
        cartTableView.estimatedRowHeight = 200
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(pullRefreshTrigger), for: .valueChanged)
        self.cartTableView.addSubview(self.refreshControl)
        
        self.refreshTableView { (_) in
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if CacheManager.sharedInstance.cartUpdateOrderId != nil {
            self.cartVCTitle.text = "Edit Order"
        } else {
            self.cartVCTitle.text = "Cart"
        }
        self.refreshTableView { (_) in
        }
    }
    
    func refreshTableView(completion: @escaping(_ done: Bool) -> Void) {
        DispatchQueue.main.async {
            self.cartTableView.reloadData()
            self.recalculateTotalPrice()
            completion(true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CacheManager.sharedInstance.cartOrderProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let productCell = tableView.dequeueReusableCell(withIdentifier: "ShowCartTableViewCell", for: indexPath) as! ShowCartTableViewCell
        productCell.initWithOrderProduct(CacheManager.sharedInstance.cartOrderProducts[indexPath.row])
        productCell.cartUpdated = { _ in
            CacheManager.sharedInstance.cartOrderProducts = CacheManager.sharedInstance.cartOrderProducts.filter({ $0.quantity > 0 })

            if CacheManager.sharedInstance.cartOrderProducts.isEmpty {
                self.tabBarItem.badgeValue = nil
            } else {
                self.tabBarItem.badgeValue = "\(CacheManager.sharedInstance.cartOrderProducts.map({$0.quantity}).reduce(0, +))"
            }
            
            self.recalculateTotalPrice()
            self.refreshTableView { (_) in
            }
        }
        return productCell
    }

    @objc func pullRefreshTrigger(_ sender: Any) {
        refreshTableView { (_) in
            self.refreshControl.endRefreshing()
        }
    }
    
    func recalculateTotalPrice() {
        var totalPrice:Double = 0.00
        for orderProduct in CacheManager.sharedInstance.cartOrderProducts {
            if let productPrice = orderProduct.product?.price {
                totalPrice += (productPrice * Double(orderProduct.quantity))
            }
        }
        DispatchQueue.main.async {
            self.cartTotalPrice.text = "‎£\(String(format: "%.02f", totalPrice))"
        }
    }
    
    @IBAction func checkoutAction(_ sender: Any) {
        let alertController = UIAlertController(title: "Order Submission", message: "Are you sure to submit the order?", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.submitOrder()
        }
        let alertCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        alertController.addAction(alertAction)
        alertController.addAction(alertCancel)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func submitOrder() {
        if let tabItems = self.tabBarController?.tabBar.items {
            let tabItem = tabItems[1]
            tabItem.badgeValue = nil
        }
        if let currentUser = CacheManager.sharedInstance.currentUser {
            if let updateOrderId = CacheManager.sharedInstance.cartUpdateOrderId {
                Orders().update(currentUser: currentUser, orderId: updateOrderId, orderStatus: nil, orderProducts: CacheManager.sharedInstance.cartOrderProducts) { (orderResult) in
                    if let order = orderResult, order.errorCode == nil {
                        CacheManager.sharedInstance.cartOrderProducts.removeAll()
                        CacheManager.sharedInstance.cartUpdateOrderId = nil
                        
                        self.refreshTableView { (_) in
                            self.recalculateTotalPrice()
                            self.showDialog(success: true)
                        }
                    } else {
                        if let tabItems = self.tabBarController?.tabBar.items {
                            let tabItem = tabItems[1]
                            tabItem.badgeValue = "\(CacheManager.sharedInstance.cartOrderProducts.map({$0.quantity}).reduce(0, +))"
                        }
                        self.showDialog(success: false)
                    }
                }
            } else {
                Orders().create(currentUser: currentUser, orderProducts: CacheManager.sharedInstance.cartOrderProducts) { (orderResult) in
                    if let order = orderResult, order.errorCode == nil {
                        CacheManager.sharedInstance.cartOrderProducts.removeAll()
                        self.showDialog(success: true)
                    } else {
                        self.showDialog(success: false)
                    }
                }
            }
        }
    }
    
    func showDialog(success: Bool) {
        let alertController = UIAlertController(title: success ? "Order success!":"Order failure!", message: success ? "Your order has been submitted, click OK to go to order details":"Your order has NOT been submitted, please retry again!", preferredStyle: .alert)
        let alertSuccessOk = UIAlertAction(title: "Okay", style: .default) { (action) in
            DispatchQueue.main.async {
                self.tabBarController?.selectedIndex = 2
            }
        }
        let alertFailureOk = UIAlertAction(title: "Okay", style: .default) { (action) in
        }
        if success {
            alertController.addAction(alertSuccessOk)
        } else {
            alertController.addAction(alertFailureOk)
        }
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }

}
