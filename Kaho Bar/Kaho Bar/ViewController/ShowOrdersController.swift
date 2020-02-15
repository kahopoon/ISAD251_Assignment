//
//  ShowOrdersController.swift
//  Kaho Bar
//
//  Created by Johnson on 13/2/2020.
//  Copyright © 2020 Johnson. All rights reserved.
//

import UIKit

class ShowOrdersViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var ordersVCTitle: UILabel!
    @IBOutlet weak var ordersTableView: UITableView!
    var refreshControl:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ordersTableView.rowHeight = UITableView.automaticDimension
        ordersTableView.estimatedRowHeight = 300
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(pullRefreshTrigger), for: .valueChanged)
        
        self.refreshTableView { (_) in
            self.ordersTableView.addSubview(self.refreshControl)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let currentUser = CacheManager.sharedInstance.currentUser {
            DispatchQueue.main.async {
                self.ordersVCTitle.text = currentUser.role == .administrator ? "Client Orders" : "Your Orders"
            }
        }
    }
    
    func refreshTableView(completion: @escaping(_ done: Bool) -> Void) {
        if let currentUser = CacheManager.sharedInstance.currentUser {
            Orders().get(currentUser: currentUser) { (Orders) in
                CacheManager.sharedInstance.orders = Orders
                DispatchQueue.main.async {
                    self.ordersTableView.reloadData()
                    completion(true)
                }
            }
        } else {
            completion(false)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CacheManager.sharedInstance.orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let orderCell = tableView.dequeueReusableCell(withIdentifier: "ShowOrdersTableViewCell", for: indexPath) as! ShowOrdersTableViewCell
        orderCell.initWithOrder(CacheManager.sharedInstance.orders[indexPath.row])
        return orderCell
    }

    @objc func pullRefreshTrigger(_ sender: Any) {
        refreshTableView { (_) in
            self.refreshControl.endRefreshing()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let order = CacheManager.sharedInstance.orders[indexPath.row]
        self.showEditOrderDialog(order: order)
    }
    
    func showEditOrderDialog(order: Order) {
        let alertController = UIAlertController(title: "Order action", message: "What do you want with this order?", preferredStyle: .actionSheet)
        let alertEdit = UIAlertAction(title: "Add more items", style: .default) { (action) in
            CacheManager.sharedInstance.cartUpdateOrderId = order.id
            self.showOrderUpdateDialog()
        }
        let alertCancel = UIAlertAction(title: "Cancel order", style: .destructive) { (action) in
            if let currentUser = CacheManager.sharedInstance.currentUser {
                Orders().remove(currentUser: currentUser, orderId: order.id) { (removedOrder) in
                    self.refreshTableView { (_) in
                        self.showOrderRemovedDialog(success: removedOrder != nil && removedOrder!.errorCode == nil)
                    }
                }
            }
            
        }
        let alertInProgress = UIAlertAction(title: "Order in progress", style: .default) { (action) in
            if let currentUser = CacheManager.sharedInstance.currentUser {
                Orders().update(currentUser: currentUser, orderId: order.id, orderStatus: Order.Status.inProgress, orderProducts: []) { (inProgressOrder) in
                    self.refreshTableView { (_) in
                        self.showOrderUpdateStatusDialog(success: inProgressOrder != nil && inProgressOrder!.errorCode == nil, status: "In Progress")
                    }
                }
            }
        }
        let alertDelivered = UIAlertAction(title: "Order delivered", style: .default) { (action) in
            if let currentUser = CacheManager.sharedInstance.currentUser {
                Orders().update(currentUser: currentUser, orderId: order.id, orderStatus: Order.Status.delivered, orderProducts: []) { (deliveredOrder) in
                    self.refreshTableView { (_) in
                        self.showOrderUpdateStatusDialog(success: deliveredOrder != nil && deliveredOrder!.errorCode == nil, status: "Delivered")
                    }
                }
            }
        }
        let alertDismiss = UIAlertAction(title: "Close", style: .cancel) { (action) in
        }
        if let currentUser = CacheManager.sharedInstance.currentUser {
            if currentUser.role == .administrator {
                alertController.addAction(alertInProgress)
                alertController.addAction(alertDelivered)
            } else {
                alertController.addAction(alertEdit)
            }
        }
        alertController.addAction(alertCancel)
        alertController.addAction(alertDismiss)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showOrderRemovedDialog(success: Bool) {
        let alertController = UIAlertController(title: "Cancel Order", message: success ? "Your order has been cancelled":"Your cancel request cannot be proceed, please try again", preferredStyle: .alert)
        let alertOk = UIAlertAction(title: "Okay", style: .default) { (action) in
        }
        alertController.addAction(alertOk)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showOrderUpdateDialog() {
        let alertController = UIAlertController(title: "Edit Order", message: "Pleaase go to menu to choose items that you would like to add into this order, and then checkout as usual.", preferredStyle: .alert)
        let alertOk = UIAlertAction(title: "Okay", style: .default) { (action) in
            DispatchQueue.main.async {
                self.tabBarController?.selectedIndex = 0
            }
        }
        alertController.addAction(alertOk)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showOrderUpdateStatusDialog(success: Bool, status: String) {
        let alertController = UIAlertController(title: "Order update", message: success ? "Order has been set to \"\(status)\"":"Order cannot been set to \"\(status)\", please try again.", preferredStyle: .alert)
        let alertOk = UIAlertAction(title: "Okay", style: .default) { (action) in
        }
        alertController.addAction(alertOk)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }

}
