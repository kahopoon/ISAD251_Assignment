//
//  ShowProductsViewController.swift
//  Kaho Bar
//
//  Created by Johnson on 13/2/2020.
//  Copyright © 2020 Johnson. All rights reserved.
//

import UIKit

class ShowProductsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var productVCTitle: UILabel!
    @IBOutlet weak var productCreateButton: UIButton!
    @IBOutlet weak var productsTableView: UITableView!
    var refreshControl:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        productsTableView.rowHeight = UITableView.automaticDimension
        productsTableView.estimatedRowHeight = 120
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(pullRefreshTrigger), for: .valueChanged)
        
        self.refreshTableView { (_) in
            self.productsTableView.addSubview(self.refreshControl)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let currentUser = CacheManager.sharedInstance.currentUser {
            DispatchQueue.main.async {
                self.productVCTitle.text = currentUser.role == .administrator ? "Products" : "Menu"
                self.productCreateButton.isHidden = currentUser.role == .administrator ? false : true
                self.tabBarItem.title = currentUser.role == .administrator ? "Products" : "Menu"
            }
        }
    }
    
    func refreshTableView(completion: @escaping(_ done: Bool) -> Void) {
        if let currentUser = CacheManager.sharedInstance.currentUser {
            Products().get(currentUser: currentUser) { (products) in
                CacheManager.sharedInstance.products = products
                DispatchQueue.main.async {
                    self.productsTableView.reloadData()
                    completion(true)
                }
            }
        } else {
            completion(false)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CacheManager.sharedInstance.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let productCell = tableView.dequeueReusableCell(withIdentifier: "ShowProductsTableViewCell", for: indexPath) as! ShowProductsTableViewCell
        productCell.initWithProduct(CacheManager.sharedInstance.products[indexPath.row])
        return productCell
    }

    @objc func pullRefreshTrigger(_ sender: Any) {
        refreshTableView { (_) in
            self.refreshControl.endRefreshing()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = CacheManager.sharedInstance.products[indexPath.row]
        
        if let currentUser = CacheManager.sharedInstance.currentUser {
            if currentUser.role == .administrator {
                self.showEditProductDialog(product)
            } else {
                switch product.status {
                case .active:
                    let orderProduct = OrderProduct(id: product.id, quantity: 1, product: product)
                    CacheManager.sharedInstance.cartOrderProducts.append(orderProduct)
                    
                    if let tabItems = tabBarController?.tabBar.items {
                        let tabItem = tabItems[1]
                        tabItem.badgeValue = "\(CacheManager.sharedInstance.cartOrderProducts.map({$0.quantity}).reduce(0, +))"
                    }
                    
                    self.tabBarController?.selectedIndex = 1
                default:
                    self.showUnavailableDialog(product)
                }
            }
        }
    }

    func showEditProductDialog(_ product: Product) {
        let alertController = UIAlertController(title: "Edit Product", message: "What do you want to edit with this product?", preferredStyle: .actionSheet)
        let alertName = UIAlertAction(title: "Edit name", style: .default) { (action) in
            self.showEditTextFieldDialog(.name, product: product)
        }
        let alertDescription = UIAlertAction(title: "Edit description", style: .default) { (action) in
            self.showEditTextFieldDialog(.description, product: product)
        }
        let alertImage = UIAlertAction(title: "Edit image", style: .default) { (action) in
            self.showEditTextFieldDialog(.imagePath, product: product)
        }
        let alertPrice = UIAlertAction(title: "Edit price", style: .default) { (action) in
            self.showEditTextFieldDialog(.price, product: product)
        }
        let alertRemove = UIAlertAction(title: "Remove from sale", style: .destructive) { (action) in
            if let currentUser = CacheManager.sharedInstance.currentUser {
                Products().remove(currentUser: currentUser, productId: product.id) { (removedProduct) in
                    self.refreshTableView { (_) in
                        self.productRemovedDialog(success: removedProduct != nil && removedProduct?.errorCode == nil)
                    }
                }
            }
        }
        let alertDismiss = UIAlertAction(title: "Close", style: .cancel) { (action) in
        }
        alertController.addAction(alertName)
        alertController.addAction(alertDescription)
        alertController.addAction(alertImage)
        alertController.addAction(alertPrice)
        alertController.addAction(alertRemove)
        alertController.addAction(alertDismiss)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    enum EditType {
        case name
        case description
        case imagePath
        case price
    }
    
    func showEditTextFieldDialog(_ type: EditType, product: Product) {
        var typeString = ""
        switch type {
        case .name:
            typeString = "name"
        case .description:
            typeString = "description"
        case .imagePath:
            typeString = "image path"
        default:
            typeString = "price"
        }
        
        var updatedName:String?
        var updatedDescription:String?
        var updatedImagePath:String?
        var updatedPrice:String?
        
        let alertController = UIAlertController(title: "Update \(typeString)", message: "", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Enter new \(typeString)"
            textField.textAlignment = .left
        }
        let cancelAction = UIAlertAction(title: "Cancel Edit", style: .cancel) { _ in
        }
        let confirmAction = UIAlertAction(title: "Okay", style: .default) { _ in
            if let userInputText = alertController.textFields?.first?.text, userInputText.count > 0 {
                switch type {
                case .name:
                    updatedName = userInputText
                case .description:
                    updatedDescription = userInputText
                case .imagePath:
                    updatedImagePath = userInputText
                default:
                    updatedPrice = userInputText
                }
                if let currentUser = CacheManager.sharedInstance.currentUser {
                    Products().update(currentUser: currentUser, productId: product.id, name: updatedName, type: nil, description: updatedDescription, imagePath: updatedImagePath, price: updatedPrice == nil ? nil : Double(updatedPrice!)) { (updatedProduct) in
                        self.refreshTableView { (_) in
                            self.productUpdatedDialog(type, success: updatedProduct != nil && updatedProduct!.errorCode == nil)
                        }
                    }
                }
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)

        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func productUpdatedDialog(_ type:EditType, success: Bool) {
        var typeString = ""
        switch type {
        case .name:
            typeString = "Name"
        case .description:
            typeString = "Description"
        case .imagePath:
            typeString = "Image path"
        default:
            typeString = "Price"
        }
        let alertController = UIAlertController(title: "Edit Action", message: success ? "\(typeString) updated successfully":"\(typeString) cannot be update, please try again.", preferredStyle: .alert)
        let alertOk = UIAlertAction(title: "Okay", style: .default) { (_) in
        }
        alertController.addAction(alertOk)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func productRemovedDialog(success: Bool) {
        let alertController = UIAlertController(title: "Remove Action", message: success ? "Product has been removed successfully":"Product cannot be remove, please try again.", preferredStyle: .alert)
        let alertOk = UIAlertAction(title: "Okay", style: .default) { (_) in
        }
        alertController.addAction(alertOk)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func productCreatedDialog(success: Bool) {
        let alertController = UIAlertController(title: "Create Action", message: success ? "Product has been created successfully":"Product cannot be create, please try again.", preferredStyle: .alert)
        let alertOk = UIAlertAction(title: "Okay", style: .default) { (_) in
        }
        alertController.addAction(alertOk)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showCreateProductDialog() {
        let alertController = UIAlertController(title: "Create Product", message: "Please enter following fields for create a product", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Name"
            textField.textAlignment = .left
        }
        alertController.addTextField { textField in
            textField.placeholder = "Description"
            textField.textAlignment = .left
        }
        alertController.addTextField { textField in
            textField.placeholder = "Image path"
            textField.textAlignment = .left
        }
        alertController.addTextField { textField in
            textField.placeholder = "Price"
            textField.textAlignment = .left
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
        }
        let confirmAction = UIAlertAction(title: "Okay", style: .default) { _ in
            let name = alertController.textFields?[0].text ?? ""
            let description = alertController.textFields?[1].text ?? ""
            let imagePath = alertController.textFields?[2].text ?? ""
            let price = alertController.textFields?[3].text ?? "0"
            
            if let currentUser = CacheManager.sharedInstance.currentUser {
                Products().create(currentUser: currentUser, name: name, type: Product.ProductType.alcohol, description: description, imagePath: imagePath, price: Double(price)!) { (createdProduct) in
                    self.refreshTableView { (_) in
                        self.productCreatedDialog(success: createdProduct != nil && createdProduct?.errorCode == nil)
                    }
                }
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)

        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showUnavailableDialog(_ product: Product) {
        let alertController = UIAlertController(title: "Ooosh...", message: "\(product.name) is unavailable at the moment, please choose other drinks/snack.", preferredStyle: .alert)
        let alertOK = UIAlertAction(title: "Okay", style: .cancel) { (_) in
        }
        alertController.addAction(alertOK)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func addProductAction(_ sender: Any) {
        self.showCreateProductDialog()
    }
    
}
